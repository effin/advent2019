defmodule Day11 do
  def run1(input) do
    input
    |> getPainting(0)
    |> Map.keys()
    |> Enum.count()
  end

  def run2(input) do
    input
    |> getPainting(1)
    |> buildImage()
  end

  defp getPainting(input, f) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(
         fn line ->
           {integer, _left_over} = Integer.parse(line)
           integer
         end
       )
    |> Stream.with_index(0)
    |> Enum.reduce(%{}, fn ({v, k}, acc) -> Map.put(acc, k, v) end)
    |> paint(0, %{}, 0, :up, 0, 0, nil, f)
  end

  defp buildImage(painting) do
    {minx, maxx, miny, maxy} = painting
                               |> Map.keys()
                               |> Enum.map(fn s -> String.split(s, "|") end)
                               |> Enum.map(
                                    fn a ->
                                      a
                                      |> Enum.map(fn s -> String.to_integer(s) end)
                                    end
                                  )
                               |> Enum.reduce(
                                    {1000, -1000, 1000, -1000},
                                    fn elem, {minx, maxx, miny, maxy} ->
                                      x = Enum.at(elem, 0)
                                      y = Enum.at(elem, 1)
                                      {min(x, minx), max(x, maxx), min(y, miny), max(y, maxy)}
                                    end
                                  )
    miny..maxy
    |> Enum.map(
         fn y ->
           minx..maxx
           |> Enum.map(
                fn x ->
                  key = Integer.to_string(x) <> "|" <> Integer.to_string(y)
                  if Map.has_key?(painting, key) do
                    if painting[key] == 1, do: "X", else: " "
                  else
                    " "
                  end
                end
              )
           |> Enum.join()
         end
       )
    |> Enum.join("\n")
  end

  defp paint(p, index, painting, r, dir, x, y, output, f) do
    {op, ops} = getOp(p, index, r)
    case op do
      99 -> painting
      3 ->
        key = Integer.to_string(x) <> "|" <> Integer.to_string(y)
        input = if Map.has_key?(painting, key), do: painting[key], else: (if x == 0 && y == 0, do: f, else: 0)
        {p, index} = operate(3, {input, elem(ops, 0)}, p, index)
        paint(p, index, painting, r, dir, x, y, output, f)
      4 ->
        if output == nil do
          key = Integer.to_string(x) <> "|" <> Integer.to_string(y)
          newpainting = Map.put(painting, key, elem(ops, 0))
          paint(p, index + 2, newpainting, r, dir, x, y, elem(ops, 0), f)
        else
          {newdir, newx, newy} = case {dir, elem(ops, 0)} do
            {:up, 0} -> {:left, x - 1, y}
            {:up, 1} -> {:right, x + 1, y}
            {:down, 0} -> {:right, x + 1, y}
            {:down, 1} -> {:left, x - 1, y}
            {:left, 0} -> {:down, x, y + 1}
            {:left, 1} -> {:up, x, y - 1}
            {:right, 0} -> {:up, x, y - 1}
            {:right, 1} -> {:down, x, y + 1}
          end
          paint(p, index + 2, painting, r, newdir, newx, newy, nil, f)
        end
      9 -> paint(p, index + 2, painting, r + elem(ops, 0), dir, x, y, output, f)
      _ ->
        {p, index} = operate(op, ops, p, index)
        paint(p, index, painting, r, dir, x, y, output, f)
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

  [input_file] ->
    input_file
    |> File.read!()
    |> Day11.run1()
    |> IO.inspect(label: "output")
    input_file
    |> File.read!()
    |> Day11.run2()
    |> IO.puts()

  _ ->
    IO.puts :stderr, "we expected an input file"
    System.halt(1)
end
