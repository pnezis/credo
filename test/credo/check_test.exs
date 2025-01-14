defmodule Credo.CheckTest do
  use Credo.Test.Case

  alias Credo.Check

  @generated_lines 1000
  test "it should determine the correct scope for long modules in reasonable time" do
    source_file =
      """
      # some_file.ex
      defmodule AliasTest do
        def test do
          [
      #{for _ <- 1..@generated_lines, do: "      :a,\n"}
            :a
          ]

          Any.Thing.test()
        end
      end
      """
      |> to_source_file

    {time_in_microseconds, result} =
      :timer.tc(fn ->
        Check.scope_for(source_file, line: @generated_lines + 9)
      end)

    # Ensures that there are no speed pitfalls like reported here:
    # https://github.com/rrrene/credo/issues/702
    assert time_in_microseconds < 1_000_000
    assert {:def, "AliasTest.test"} == result
  end

  defmodule DocsUriTestCheck do
    use Credo.Check, docs_uri: "https://example.org"

    def run(%SourceFile{} = _source_file, _params \\ []) do
      []
    end
  end

  test "it should generate a docs_uri" do
    assert DocsUriTestCheck.docs_uri() == "https://example.org"

    assert Credo.Check.Readability.ModuleDoc.docs_uri() ==
             "https://hexdocs.pm/credo/Credo.Check.Readability.ModuleDoc.html"
  end
end
