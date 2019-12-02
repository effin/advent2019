defmodule Day2 do
  def run(input) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(fn line -> String.to_integer(line) end)
    |> process(0)
    |> Enum.at(0)
  end

  def replaceAndRun(input, noun \\ 12, verb \\ 2) do
    input
    |> String.split(",", trim: true)
    |> Enum.map(
         fn line ->
           {integer, _left_over} = Integer.parse(line)
           integer
         end
       )
    |> List.replace_at(1, noun)
    |> List.replace_at(2, verb)
    |> process(0)
    |> Enum.at(0)
  end

  def findNounVerb(input, nounverb \\ 0) do
    if nounverb > 9999  do
      -1
    else
      noun = div(nounverb, 100)
      verb = nounverb - 100 * noun
      if replaceAndRun(input, noun, verb) == 19690720 do
        100 * noun + verb
      else
        findNounVerb(input, nounverb + 1)
      end
    end
  end

  defp process(p, index) do
    op = Enum.at(p, index)
    if op == 99 do
      p
    else
      res = operate(op, Enum.at(p, Enum.at(p, index + 1)), Enum.at(p, Enum.at(p, index + 2)))
      process(List.replace_at(p, Enum.at(p, index + 3), res), index + 4)
    end
  end

  defp operate(op, op1, op2) do
    if op == 1 do
      op1 + op2
    else
      op1 * op2
    end
  end

end

case System.argv() do
  ["--test"] ->

    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import Day2

      test "example0" do
        assert run("1,9,10,3,2,3,11,0,99,30,40,50") == 3500
      end

      test "example1" do
        assert run("1,0,0,0,99") == 2
      end

      test "example2" do
        assert run("2,3,0,3,99") == 2
      end

      test "example3" do
        assert run("2,4,4,5,99,0") == 2
      end

      test "example4" do
        assert run("1,1,1,4,99,5,6,0,99") == 30
      end
    end

  [input_file] ->
    input_file
    |> File.read!()
    |> (&(Integer.to_string(Day2.replaceAndRun(&1)) <> " " <> Integer.to_string(Day2.findNounVerb(&1)))).()
    |> IO.puts

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
