defmodule Krotos do
  use HTTPoison.Base, Poison
  @moduledoc """
  Client for using the Napster Api.
  Relies on the system enviroment variable NAPSTER_API_KEY to issue the requests.
  """
  @baseURL "https://api.napster.com/v2.1/"

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
    url = if limit > 0 and limit <= 200 do
       url <> "?limit=#{limit}"
    end

    case HTTPoison.get url, [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Krotos.ResponseHandler.handleResponse(:getTopTracksForGenre, body)
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

    def buildGenreList(dict) do
      Enum.map(dict["genres"], fn(x) -> {x["id"], x["name"], x["links"]["childGenres"]["ids"]} end)
    end

    def buildTracksList(dict) do
      Enum.map(dict["tracks"], fn(x) -> {x["id"], x["name"], x["artistName"], x["albumName"], x["previewURL"]} end)
    end
  end
end
