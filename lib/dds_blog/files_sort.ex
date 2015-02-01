defmodule Files.Sort do
  use Timex

  def newest(list) do
    extract_filename(list |> convert_files_and_dates
                          |> Enum.sort_by &(Map.get(&1, :timestamp)))
  end

  def extract_filename([]), do: []

  def extract_filename([head|tail]) do
    [head[:filename]] ++ extract_filename(tail)
  end

  def convert_files_and_dates([]), do: []

  def convert_files_and_dates([head|tail]) do
    %File.Stat{mtime: mtime} = File.stat!("priv/contents/" <> head)
    from = Date.from(mtime)
    timestamp = Date.convert(from, :secs)

    filename = head
    state = [%{filename: filename, timestamp: timestamp}]
    state ++ convert_files_and_dates(tail)
  end
end
