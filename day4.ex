defmodule Day4 do
  def run(low, high), do: run(low, high, &isPassword/1)
  def run2(low, high), do: run(low, high, &isPassword2/1)

  defp run(low, high, f),
       do: low..high
           |> Enum.filter(f)
           |> Enum.count()

  defp isPassword(i) do
    v = div(i, 10)
    m = i - 10 * v
    check(v, m, false)
  end

  defp check(v, m, b) do
    if v < 10 do
      v <= m && (b || v == m)
    else
      nextv = div(v, 10)
      nextm = v - 10 * nextv
      if nextm > m do
        false
      else
        check(nextv, nextm, b || nextm == m)
      end
    end
  end

  defp isPassword2(i) do
    v = div(i, 10)
    m = i - 10 * v
    check2(v, m, false, 0)
  end

  defp check2(v, m, b, c) do
    if v < 10 do
      v <= m && (b || (c == 0 && v == m) || (c == 1 && v != m))
    else
      nextv = div(v, 10)
      nextm = v - 10 * nextv
      if nextm > m do
        false
      else
        nextc = if nextm == m, do: c + 1, else: 0
        nextb = b || (c == 1 && nextm != m)
        check2(nextv, nextm, nextb, nextc)
      end
    end
  end

end

IO.puts Day4.run(197487, 673251)
IO.puts Day4.run2(197487, 673251)
