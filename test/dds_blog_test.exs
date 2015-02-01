defmodule DdsBlogTest do
  use ExUnit.Case

  test "sort one element" do
     assert Files.Sort.newest(["filename.md"]) == ["filename.md"]
  end

  test "sort two elements based on mtime" do
    files = Files.Sort.newest(["filename.md", "basicfp.md"])
    assert files == ["filename.md", "basicfp.md"]
  end

  test "sort three elements based on mtime" do
    files = Files.Sort.newest(["filename.md", "basicfp.md", "elixirdose_flatfileblog.md"])
    assert files == ["filename.md", "basicfp.md", "elixirdose_flatfileblog.md"]
  end

end
