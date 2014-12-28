defmodule Obiwan do
  def parse(path) do
    path
    |> expand
    |> get_files
    |> Enum.map(&parse_file/1)
  end

  def parse_file(path) do
    path
    |> File.read!
    |> extract_comments
    |> Enum.map(&parse_comment_block/1)
  end

  defp parse_comment_block([comment | _]) do
    comment
    |> String.split("\n")
    |> sanitize_block
    |> extract_examples
    |> extract_options
    |> extract_description
  end

  defp expand(path) do
    fullpath = Path.expand(path)
    {fullpath, case File.dir?(fullpath) do
        false -> :file?
        true  -> :directory?
      end
    }
  end

  defp get_files({path, :directory?}),  do: Path.wildcard("#{path}/**/*")
  defp get_files({path, :file?}),       do: [path]

  defp extract_comments(text) do
    Regex.scan(~r/\/\*\*.*?\*\//s, text)
  end

  defp sanitize_block(lines) do
    Enum.filter_map(lines, &(Regex.match?(~r/[\w]/,&1)), fn(line) ->
      Regex.replace(~r/^\s*\*\s*/, line, "")
    end)
  end

  defp extract_examples(lines), do: {lines, []}

  # This technically works, but we want the lines result to be those that do
  # NOT include the examples. We probably need to use Enum.split_while here.

  #defp extract_examples(lines), do: {lines, _extract_examples(lines, [])}

  #defp _extract_examples([], result), do: result
  #defp _extract_examples(["@example" <> head | tail], result) do
  #  _copy_example(tail, result, [head])
  #end
  #defp _extract_examples([head | tail], result), do: _extract_examples(tail, result)

  #defp _copy_example([], result, example_lines), do: result ++ example_lines
  #defp _copy_example(["@" <> newSelector | tail], result, example_lines) do
  #  _extract_examples(["@" <> newSelector] ++ tail, result ++ example_lines)
  #end
  #defp _copy_example([head | tail], result, example_lines) do
  #  _copy_example(tail, result, example_lines ++ head)
  #end


  defp extract_options(tuple), do: tuple
  defp extract_description(tuple), do: tuple

end
