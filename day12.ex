defmodule PrimeFactors do
  def of(num) do
    prime_factors(num)
  end
  def prime_factors(num, next \\ 2)
  def prime_factors(num, 2) do
    cond do
      rem(num, 2) == 0 -> [2 | prime_factors(div(num, 2))]
      4 > num -> [num]
      true -> prime_factors(num, 3)
    end
  end
  def prime_factors(num, next) do
    cond do
      rem(num, next) == 0 -> [next | prime_factors(div(num, next))]
      next + next > num -> [num]
      true -> prime_factors(num, next + 2)
    end
  end
end

defmodule Day12 do

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> Regex.named_captures(~r/<x=(?<x>-*\d+), y=(?<y>-*\d+), z=(?<z>-*\d+)>/, line) end)
    |> Enum.map(
         fn m ->
           %{
             0 => String.to_integer(m["x"]),
             1 => String.to_integer(m["y"]),
             2 => String.to_integer(m["z"]),
             3 => 0,
             4 => 0,
             5 => 0
           }
         end
       )
  end

  def run1(input, n) do
    parse(input)
    |> step(n)
    |> energy()
  end

  def run2(input) do
    parse(input)
    |> findStepsUntilEqual()
  end

  defp findStepsUntilEqual(startmoons) do
    0..2
    |> Enum.map(fn i -> findStepsUntilEqual(startmoons, startmoons, i) end)
    |> findLowestFactor()
  end

  defp findLowestFactor(x) do
    primes = Enum.map(x, fn x -> PrimeFactors.of(x) end)
    primesCountMap = Enum.map(primes, fn p -> mapCount(p, %{}) end)
    primesCountMax = uniquePrimesAndMax(primesCountMap, %{})
    Map.keys(primesCountMax)
    |> Enum.map(fn p -> pow(p, primesCountMax[p]) end)
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  defp pow(x, n) when n == 1, do: x
  defp pow(x, n), do: x * pow(x, n - 1)

  defp uniquePrimesAndMax([], uniqueAndMax), do: uniqueAndMax
  defp uniquePrimesAndMax([head | tail], uniqueAndMax) do
    newUnique = Enum.reduce(
      Map.keys(head),
      uniqueAndMax,
      fn k, acc ->
        n = head[k]
        if Map.has_key?(acc, k) do
          %{acc | k => max(n, acc[k])}
        else
          Map.put(acc, k, n)
        end
      end
    )
    uniquePrimesAndMax(tail, newUnique)
  end

  defp mapCount([], m), do: m
  defp mapCount([head | tail], m) do
    newm = if Map.has_key?(m, head) do
      %{m | head => m[head] + 1}
    else
      Map.put(m, head, 1)
    end
    mapCount(tail, newm)
  end

  defp findStepsUntilEqual(startmoons, moons, d, n \\ 0) do
    newmoons = step(moons, 1)
    samex = Enum.reduce(
      0..3,
      true,
      fn i, acc ->
        m = Enum.at(newmoons, i)
        acc && m[d + 3] == 0 && Enum.at(startmoons, i)[d] == m[d]
      end
    )
    if samex do
      n + 1
    else
      findStepsUntilEqual(startmoons, newmoons, d, n + 1)
    end
  end

  defp step(moons, 0), do: moons
  defp step(moons, n) do
    step(move(updateVelocities(moons)), n - 1)
  end

  defp updateVelocities(moons) do
    0..3
    |> Enum.map(
         fn i1 ->
           m = Enum.at(moons, i1)
           updateVelocities(m, moons, i1)
         end
       )
  end

  defp updateVelocities(m, moons, i1, i \\ 0)
  defp updateVelocities(m, _moons, _i1, 4), do: m
  defp updateVelocities(m, moons, i1, i) do
    if i1 == i do
      updateVelocities(m, moons, i1, i + 1)
    else
      o = Enum.at(moons, i)
      newm = updateVelocity(m, o)
      updateVelocities(newm, moons, i1, i + 1)
    end
  end

  defp updateVelocity(m, o, a \\ 0)
  defp updateVelocity(m, _o, 3), do: m
  defp updateVelocity(m, o, a) do
    change = if o[a] > m[a], do: 1, else: if o[a] < m[a], do: -1, else: 0
    newm = %{m | a + 3 => m[a + 3] + change}
    updateVelocity(newm, o, a + 1)
  end

  defp move(moons) do
    Enum.map(moons, fn m -> moveOne(m) end)
  end

  defp moveOne(m, a \\ 0)
  defp moveOne(m, 3), do: m
  defp moveOne(m, a) do
    newm = %{m | a => m[a] + m[a + 3]}
    moveOne(newm, a + 1)
  end

  defp energy(moons) do
    moons
    |> Enum.map(
         fn m ->
           {
             0..2
             |> Enum.map(fn i -> abs(m[i]) end)
             |> Enum.sum(),
             3..5
             |> Enum.map(fn i -> abs(m[i]) end)
             |> Enum.sum()
           }
         end
       )
    |> Enum.map(fn {pot, kin} -> pot * kin end)
    |> Enum.sum()
  end

end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day12Test do
      use ExUnit.Case

      import Day12

      test "test0" do
        assert run1(
                 """
                 <x=-1, y=0, z=2>
                 <x=2, y=-10, z=-7>
                 <x=4, y=-8, z=8>
                 <x=3, y=5, z=-1>
                 """,
                 10
               ) == 179
      end

      test "test1" do
        assert run2(
                 """
                 <x=-1, y=0, z=2>
                 <x=2, y=-10, z=-7>
                 <x=4, y=-8, z=8>
                 <x=3, y=5, z=-1>
                 """
               ) == 2772
      end

      @tag timeout: :infinity
      test "test2" do
        assert run2(
                 """
                 <x=-8, y=-10, z=0>
                 <x=5, y=5, z=10>
                 <x=2, y=-7, z=3>
                 <x=9, y=-8, z=-3>
                 """
               ) == 4686774924
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day12.run1(1000)
    |> IO.puts
    input_file
    |> File.read!()
    |> Day12.run2()
    |> IO.puts

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
