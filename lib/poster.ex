import JSON

defmodule Poster do
  @api_key "4vwhkrxc7amvwtevvcxzgjq7"

  def fetch(titles) do
    titles |> do_fetch_links |> do_download_files
  end

  def do_download_files(links) do
    Enum.map links, do_parallel_fetch_files(&1, self)
    do_collect_files(length(links))
  end

  def do_parallel_fetch_files(link, parent_pid) do
    spawn fn ->
      download_file(link)
      parent_pid <- { :ok }
    end
  end

  def download_file(link) do
    :inets.start()
    {:ok, {  _, _, content }} = :httpc.request String.to_char_list!(link)
    File.write(link, "content")
  end

  def do_collect_files(0) do
    :ok
  end
  def do_collect_files(count) do
    receive do
      { :ok } -> do_collect_files(count - 1)
      after 5000 -> IO.puts "Download timed out"
    end
  end

  def do_fetch_links(titles) do
    Enum.map titles, do_parallel_fetch_links(&1, self)
    do_collect_links(length(titles), [])
  end

  def do_parallel_fetch_links(title, parent_pid) do
    spawn fn ->
      parent_pid <- { :link, get_link(title) }
    end
  end

  def do_collect_links(0, acc) do
    acc
  end
  def do_collect_links(count, acc) do
    receive do
      { :link, link } -> do_collect_links(count - 1, [link|acc])
    end
  end

  defp get_link(title) do
    :inets.start()
    {:ok, {  _, _, content }} = :httpc.request create_uri(title)
    scrape content
  end

  defp create_uri(title) do
    'http://api.rottentomatoes.com/api/public/v1.0/movies.json?apikey=#{@api_key}&q=#{URI.encode(title)}&page_limit=1'
  end

  defp scrape(content) do
    {:ok, contents} = JSON.decode content
    Enum.first(contents |> HashDict.get("movies")) |> HashDict.get("posters") |> HashDict.get("original")
  end
end
