defmodule Krotos do
  use HTTPoison.Base, Poison
  @moduledoc """
  Client for using the Napster Api.
  Relies on the system enviroment variable NAPSTER_API_KEY to issue the requests.
  """
  @baseURL "https://api.napster.com/v2.1/"



  def getGameSongs do
    genreIds = getMainGenreMap()
    topSongs = Enum.take_random(getTop100Tracks(), 2)
    filmSongs = Enum.take_random(getTopTracksForGenre(genreIds[:Filmmusic], 60), 2)
    popSongs = Enum.take_random(getTopTracksForGenre(genreIds[:Pop], 100), 2)
    rockSongs = Enum.take_random(getTopTracksForGenre(genreIds[:Rock], 100), 2)
    oldieSong = Enum.random(getTopTracksForGenre(genreIds[:Oldies], 100))
    randomPool = getRandomGenrePool()
    {genreName,randomGenre} = Enum.at(randomPool, :rand.uniform(length(randomPool) -1))
    randomSong = Enum.random(getTopTracksForGenre(randomGenre, 50))
    res = topSongs ++ filmSongs ++ popSongs ++ rockSongs ++ [oldieSong] ++ [randomSong]
    IO.puts("Random Genre: " <> to_string(genreName))
    Enum.shuffle(res)
  end

  def getNTopTracks(n) do
    case n do
      1 -> [Enum.random(getTop100Tracks())]
      _ ->
        [Enum.random(getTop100Tracks())] ++ getNTopTracks(n-1)
    end
  end


  def getMainGenreMap do
    %{:Filmmusic => "g.246", :Pop => "g.115", :Rock => "g.5", :Oldies => "g.4"}
  end

  def getRandomGenrePool do
    [{:Jazz, "g.299"}, {:Electronics, "g.71"}, {:Classical, "g.21"}, {:Raggae, "g.383"}, {:Country, "g.407"}, {:Rap, "g.146"}]
  end

  @doc """
  API key used for the requests.
  """
  def key do
    to_string System.get_env("NAPSTER_API_KEY")
  end

  def listGenres do
    url = @baseURL <> "genres"
    #headers = [apikey: key()]
    case HTTPoison.get url, [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Krotos.ResponseHandler.handleResponse(:listGenres, body)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect reason
      _ -> IO.puts "Unknown Error"
    end
  end

  def getTopTracksForGenre(genre) do
    getTopTracksForGenre(genre, 0)
  end

  def getTopTracksForGenre(genre, limit) do
    url = @baseURL <> "genres/" <> genre <> "/tracks/top"
    url =
      if limit > 0 and limit <= 200 do
        url <> "?limit=#{limit}"
      else
        url
      end
    IO.puts "Url: " <> url

    case HTTPoison.get url, [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Krotos.ResponseHandler.handleResponse(:getTopTracksForGenre, body)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect reason
      _ -> IO.puts "Unknown Error"
    end
  end

  def getTop100Tracks do
    url = @baseURL <> "tracks/top?limit=100"
    #headers = [apikey: key()]
    case HTTPoison.get url, [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Krotos.ResponseHandler.handleResponse(:getTop100Tracks, body)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect reason
      _ -> IO.puts "Unknown Error"
    end
  end

  defmodule ResponseHandler do
    def decode(json) do
      Poison.decode json
    end

    def handleResponse(:listGenres, body) do
      case decode body do
        {:ok, dict} ->
          buildGenreList dict
        #_ -> IO.puts "Error decoding the json"
      end
    end

    def handleResponse(:getTopTracksForGenre, body) do
      case decode body do
        {:ok, dict} -> buildTracksList dict
      end
    end

    def handleResponse(:getTop100Tracks, body) do
      case decode body do
        {:ok, dict} -> buildTop100Info dict
        {:error, r} -> r
      end
    end

    def buildTop100Info(dict) do
      Enum.map(dict["tracks"], fn(x) -> {
        :id => x["id"],
        :title => x["name"],
        :artist => x["artistName"],
        :album => x["albumName"],
        :songUrl => x["previewURL"]}
      end)
    end

    def buildGenreList(dict) do
      Enum.map(dict["genres"], fn(x) -> {
        :id => x["id"],
        :title => x["name"],
        :subgenreList => x["links"]["childGenres"]["ids"]}
      end)
    end

    def buildTracksList(dict) do
      Enum.map(dict["tracks"], fn(x) -> {
        :id => x["id"],
        :title => x["name"],
        :artist => x["artistName"],
        :album => x["albumName"],
        :songUrl => x["previewURL"]}
      end)
    end
  end
end
