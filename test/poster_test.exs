defmodule PosterTest do
  use ExUnit.Case

  test "fetching a movies rating from Rotten tomatoes" do
    # links = Poster.fetch(["Toy Story", "The Rock", "The GodFather", "Wizard of Oz", "The Hangover"])
    Poster.do_download_files(["http://content7.flixster.com/movie/11/16/67/11166717_ori.jpg"])
    # assert length(links) == 5
  end
end
