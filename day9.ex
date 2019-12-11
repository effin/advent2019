defmodule Day9 do
  def run(input, f3) do
    x = input
        |> String.split(",", trim: true)
        |> Enum.map(
             fn line ->
               {integer, _left_over} = Integer.parse(line)
               integer
             end
           )
        |> Stream.with_index(0)
        |> Enum.reduce(%{}, fn ({v, k}, acc) -> Map.put(acc, k, v) end)
        |> process(0, f3, 0, [])
    Enum.reverse(x)
  end

  defp process(p, index, f3, r, output) do
    {op, ops} = getOp(p, index, r)
    case op do
      99 -> output
      3 ->
        input = f3.()
        {p, index} = operate(3, {input, elem(ops, 0)}, p, index)
        process(p, index, nil, r, output)
      4 -> process(p, index + 2, f3, r, [elem(ops, 0) | output])
      9 -> process(p, index + 2, f3, r + elem(ops, 0), output)
      _ ->
        {p, index} = operate(op, ops, p, index)
        process(p, index, f3, r, output)
    end
  end

  defp getOp(p, index, r) do
    v = p[index]
    op = rem(v, 100)
    ops = case op do
      1 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false), opval(v, 3, p, index, r, true)}
      2 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false), opval(v, 3, p, index, r, true)}
      4 -> {opval(v, 1, p, index, r, false)}
      5 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false)}
      6 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false)}
      7 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false), opval(v, 3, p, index, r, true)}
      8 -> {opval(v, 1, p, index, r, false), opval(v, 2, p, index, r, false), opval(v, 3, p, index, r, true)}
      9 -> {opval(v, 1, p, index, r, false)}
      3 -> {opval(v, 1, p, index, r, true)}
      99 -> {}
    end
    {op, ops}
  end

  defp opval(v, c, p, index, r, target) do
    mode = rem(div(v, pow(10, 1 + c)), 10)
    x = case mode do
      0 -> if target, do: p[index + c], else: p[p[index + c]]
      1 -> p[index + c]
      2 -> if target, do: p[index + c] + r, else: p[r + p[index + c]]
    end
    if x == nil, do: 0, else: x
  end

  #  :math.pow(2,3) |> round
  defp pow(x, n) when n == 1, do: x
  defp pow(x, n), do: x * pow(x, n - 1)

  defp operate(op, ops, p, index) do
    case op do
      1 -> {Map.put(p, elem(ops, 2), elem(ops, 1) + elem(ops, 0)), index + 4}
      2 -> {Map.put(p, elem(ops, 2), elem(ops, 1) * elem(ops, 0)), index + 4}
      3 -> {Map.put(p, elem(ops, 1), elem(ops, 0)), index + 2}
      5 -> {p, if(elem(ops, 0) != 0, do: elem(ops, 1), else: index + 3)}
      6 -> {p, if(elem(ops, 0) == 0, do: elem(ops, 1), else: index + 3)}
      7 -> {Map.put(p, elem(ops, 2), (if elem(ops, 0) < elem(ops, 1), do: 1, else: 0)), index + 4}
      8 -> {Map.put(p, elem(ops, 2), (if elem(ops, 0) == elem(ops, 1), do: 1, else: 0)), index + 4}
    end
  end

end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day9Test do
      use ExUnit.Case

      import Day9

      test "example0" do
        assert run("109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99", nil) == [
                 109,
                 1,
                 204,
                 -1,
                 1001,
                 100,
                 1,
                 100,
                 1008,
                 100,
                 16,
                 101,
                 1006,
                 101,
                 0,
                 99
               ]
      end

      test "example1" do
        assert run("1102,34915192,34915192,7,4,7,99,0", nil) == [1219070632396864]
      end

      test "example2" do
        assert run("104,1125899906842624,99", nil) == [1125899906842624]
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> Day9.run(fn -> 1 end)
    |> IO.inspect(label: "output")
    input_file
    |> File.read!()
    |> Day9.run(fn -> 2 end)
    |> IO.inspect(label: "output")

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
