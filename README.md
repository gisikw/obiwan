# Obiwan Style Guide Generator

** This is a code spike. It's bad. Don't use this. Seriously. You've been warned. **

This is designed to extract JSdoc-like comments, and extract them into a JSON/JSONP file, so they can be independently managed into some sort of styleguide. A really primitive proof-of-concept for the eventual frontend can be found at [http://gisikw.com/obiwan/](http://gisikw.com/obiwan/).

The frontend exists solely as a flat file, and can be found in the gh-pages branch (it was done in another spike when I was working on this in Ruby). The code you're seeing here is my first attempt at comment extraction via Elixir.

Again...don't use this. I'm not very familiar with Elixir, and relatively new to thinking in a functional programming way.

## Example Usage

Eventually, this should be wrapped in a bin, but for the time being, if you've got Elixir set up, you can clone the repository, run `iex -S mix`, and execute

```elixir
Obiwan.parse('test/doc_files')
```

That will crawl two example files, and generate an output.json and output.jsonp file with the extracted comments and their metadata.
