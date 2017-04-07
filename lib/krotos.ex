defmodule Krotos do
  use HTTPoison.Base
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
    headers = [apikey: key()]
    case HTTPoison.get url, [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        #IO.puts ("Success: " <> body)
        handleResponse(:listGenres, body)
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect reason
      _ -> IO.puts "Unknown Error"
    end
  end

  def handleResponse(:listGenres, body) do
    :listGenres
  end

  def handleResponse(:getTopTracksForGenre) do

  end
end
