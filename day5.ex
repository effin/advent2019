defmodule Day5 do
  def run(input, f3) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(
         fn line ->
           {integer, _left_over} = Integer.parse(line)
           integer
         end
       )
    |> process(0, f3)
    input
  end

  defp process(p, index, f3) do
    {op, ops} = getOp(p, index, f3)
    if op == 99 do
      p
    else
      {p, index} = operate(op, ops, p, index)
      process(p, index, f3)
    end
  end

  defp getOp(p, index, f3) do
    v = Enum.at(p, index)
    op = rem(v, 100)
    ops = case op do
      1 -> {opval(v, 1, p, index), opval(v, 2, p, index), Enum.at(p, index + 3)}
      2 -> {opval(v, 1, p, index), opval(v, 2, p, index), Enum.at(p, index + 3)}
      3 -> {f3.(), Enum.at(p, index + 1)}
      4 -> {opval(v, 1, p, index)}
      5 -> {opval(v, 1, p, index), opval(v, 2, p, index)}
      6 -> {opval(v, 1, p, index), opval(v, 2, p, index)}
      7 -> {opval(v, 1, p, index), opval(v, 2, p, index), Enum.at(p, index + 3)}
      8 -> {opval(v, 1, p, index), opval(v, 2, p, index), Enum.at(p, index + 3)}
      99 -> {0}
    end
    {op, ops}
  end

  defp opval(v, c, p, index) do
    case rem(div(v, pow(10, 1 + c)), 10) do
      0 -> Enum.at(p, Enum.at(p, index + c))
      1 -> Enum.at(p, index + c)
    end
  end

  defp pow(x, n) when n == 1, do: x
  defp pow(x, n), do: x * pow(x, n - 1)

  defp operate(op, ops, p, index) do
    case op do
      1 -> {List.replace_at(p, elem(ops, 2), elem(ops, 1) + elem(ops, 0)), index + 4}
      2 -> {List.replace_at(p, elem(ops, 2), elem(ops, 1) * elem(ops, 0)), index + 4}
      3 -> {List.replace_at(p, elem(ops, 1), elem(ops, 0)), index + 2}
      4 ->
        IO.inspect(elem(ops, 0), label: "OUTPUT")
        {p, index + 2}
      5 -> {p, if(elem(ops, 0) != 0, do: elem(ops, 1), else: index + 3)}
      6 -> {p, if(elem(ops, 0) == 0, do: elem(ops, 1), else: index + 3)}
      7 -> {List.replace_at(p, elem(ops, 2), (if elem(ops, 0) < elem(ops, 1), do: 1, else: 0)), index + 4}
      8 -> {List.replace_at(p, elem(ops, 2), (if elem(ops, 0) == elem(ops, 1), do: 1, else: 0)), index + 4}
    end
  end

end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day5Test do
      use ExUnit.Case

      import Day5

      test "example0" do
        assert run("1002,4,3,4,33", fn -> 0 end) == "1002,4,3,4,33"
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day5.run(fn -> 1 end)
    |> Day5.run(fn -> 5 end)

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
