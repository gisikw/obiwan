# Obiwan.parse('test/doc_files')

defmodule Obiwan do
  def parse(path) do
    path
    |> expand
    |> get_files
    |> Enum.flat_map(&parse_file/1)
    |> write
  end

  # Very temporary code, just used to validate that the output is correct until
  # tests happen.
  ###############################################################################
  def write(comments) do
    {:ok, file} = File.open("output.json", [:write])
    IO.binwrite(file, elem(JSON.encode(comments),1))
    File.close(file)
    {:ok, file} = File.open("output.jsonp", [:write])
    IO.binwrite(file, "obiwanData(" <> elem(JSON.encode(comments),1) <> ")")
    File.close(file)
  end
  ###############################################################################

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
    # Before this comment, we're dealing with [lines]. After this comment,
    # we're dealing with {[lines], [json partial keyword list]}. Is that bad?
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


  # Find all code that begins with @example <optional title>, and match until
  # "@" or empty, create and maintain a keyword list that includes [examples: []]
  #####################################################################################################
  defp extract_examples(lines), do: _find_examples(lines, [], [])

  defp _find_examples([], examples, rem), do: {rem, [examples: examples]}
  defp _find_examples(lines, examples, rem) do
    {clean, start} = Enum.split_while(lines, fn(line) -> !String.starts_with?(line, "@example") end)
    _extract_example(start, examples, rem ++ clean)
  end

  defp _extract_example([], examples, rem), do: {rem, [examples: examples]}
  defp _extract_example(["@example" <> caption | tail], examples, rem) do
    {code, next} = Enum.split_while(tail, fn(line) -> !String.starts_with?(line,"@") end)
    example = [caption: String.strip(caption), code: Enum.join(code,"\n")]
    _find_examples(next, examples ++ [example], rem)
  end
  #####################################################################################################


  # Match all @key\s+values; toss 'em in the keyword list.
  #####################################################################################################
  defp extract_options({lines, keylist}), do: _extract_options(lines, keylist, [])

  defp _extract_options([], keylist, rem), do: {rem, keylist}
  defp _extract_options(["@" <> head | tail], keylist, rem) do
    [key | value] = String.split(head)
    _extract_options(tail, keylist ++ [{String.to_atom(key), Enum.join(value, " ")}], rem)
  end
  defp _extract_options([head | tail], keylist, rem), do: _extract_options(tail, keylist, rem ++ [head])
  #####################################################################################################


  # Take any remaining comment text as the description, toss the description in the keyword list.
  defp extract_description({lines, keylist}) do
    keylist ++ [description: Enum.join(lines, " ")]
  end

end
