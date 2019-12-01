defmodule Day1 do
  def total_fuel(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.to_integer(line) end)
    |> Enum.map(fn mass -> fuel(mass) end)
    |> Enum.sum()
  end

  defp fuel(mass) when mass <= 6 do
    0
  end

  defp fuel(mass) do
    div(mass, 3) - 2
  end

  def total_fuel_2(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.to_integer(line) end)
    |> Enum.map(fn mass -> fuel(mass) end)
    |> Enum.map(fn mass -> mass + mass_fuel(mass, 0) end)
    |> Enum.sum()
  end

  defp mass_fuel(mass, acc) when mass <= 0 do
    acc
  end

  defp mass_fuel(mass, acc) do
    f = fuel(mass)
    mass_fuel(f, acc + f)
  end
end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import Day1

      test "total_fuel" do
        assert total_fuel(
                 """
                 12
                 14
                 1969
                 100756
                 """
               ) == 2 + 2 + 654 + 33583
      end

      test "total_fuel_2" do
        assert total_fuel_2(
                 """
                 12
                 14
                 1969
                 100756
                 """
               ) == 2 + 2 + 966 + 50346
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> (&(Integer.to_string(Day1.total_fuel(&1)) <> " " <> Integer.to_string(Day1.total_fuel_2(&1)))).()
    |> IO.puts

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
