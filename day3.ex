defmodule Day3 do
  def run(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.split(line, ",", trim: true) end)
    |> (fn x -> {walkFirst(Enum.at(x, 0)), Enum.at(x, 1)} end).()
    |> walkSecond()
  end

  def walkFirst(input) do
    Enum.reduce(
      input,
      [5000050000],
      fn w, acc -> walk(String.to_integer(String.slice(w, 1..-1)), acc, getDirection(w)) end
    )
  end

  defp walkSecond({map, second}) do
    {_pos, nearest, minSteps, _currentSteps} = Enum.reduce(
      second,
      {5000050000, 1000000, 1000000, 0},
      fn w, pos -> walkWithCheck(String.to_integer(String.slice(w, 1..-1)), pos, map, getDirection(w)) end
    )
    {nearest, minSteps}
  end

  defp getDirection(w) do
    case String.at(w, 0) do
      "R" -> &walkOneRight/1
      "U" -> &walkOneUp/1
      "D" -> &walkOneDown/1
      "L" -> &walkOneLeft/1
    end
  end

  defp calculateManhattan(pos) do
    x = div(pos, 100000)
    d = abs(x - 50000) + abs(pos - x * 100000 - 50000)
    d
  end

  defp walkWithCheck(n, {pos, nearest, minSteps, currentSteps}, map, f) do
    if n == 0 do
      {pos, nearest, minSteps, currentSteps}
    else
      newPos = f.(pos)
      if Enum.member?(map, newPos) do
        newNearest = min(nearest, calculateManhattan(newPos))
        firstSteps = Enum.count(map) - Enum.find_index(map, fn x -> x == newPos end) - 1
        newMinSteps = min(minSteps, currentSteps + firstSteps + 1)
        walkWithCheck(n - 1, {newPos, newNearest, newMinSteps, currentSteps + 1}, map, f)
      else
        walkWithCheck(n - 1, {newPos, nearest, minSteps, currentSteps + 1}, map, f)
      end
    end
  end

  defp walk(n, acc, _f) when n == 0, do: acc
  defp walk(n, acc, f)  do
    walk(n - 1, [f.(Enum.at(acc, 0)) | acc], f)
  end

  defp walkOneRight(pos) do
    x = div(pos, 100000)
    y = pos - x * 100000
    (x + 1) * 100000 + y
  end
  defp walkOneLeft(pos) do
    x = div(pos, 100000)
    y = pos - x * 100000
    (x - 1) * 100000 + y
  end
  defp walkOneUp(pos), do: pos - 1
  defp walkOneDown(pos), do: pos + 1
end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      import Day3

      test "example0" do
        assert run(
                 """
                 R8,U5,L5,D3
                 U7,R6,D4,L4
                 """
               ) == {6, 30}
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day3.run
    |> IO.inspect(label: "answer")

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
