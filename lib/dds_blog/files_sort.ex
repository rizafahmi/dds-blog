defmodule Files.Sort do
  use Timex

  def newest(list) do
    list |> convert_files_and_dates
         |> sort
         |> List.flatten
  end

  def convert_files_and_dates([]), do: []

  def convert_files_and_dates([head|tail]) do
    %File.Stat{mtime: mtime} = File.stat!("priv/contents/" <> head)
    from = Date.from(mtime)
    timestamp = Date.convert(from, :secs)

    state = %{filename: head, timestamp: timestamp}
    [state | convert_files_and_dates(tail)]
  end

  def sort([]), do: []

  def sort([a, b | tail]) do
    timestamp1 = a[:timestamp]
    timestamp2 = b[:timestamp]

    if timestamp1 < timestamp2 do
      swap = [a[:filename], b[:filename]]
    else
      swap = [b[:filename], a[:filename]]
    end

    [swap | sort(tail)]
  end

end
