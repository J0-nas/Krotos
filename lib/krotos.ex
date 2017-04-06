defmodule Krotos do
  use HTTPoison.Base
  @moduledoc """
  Client for using the Napster Api.
  Relies on keys.txt file containing the API keys.
  """

  #Base URL used for all API requests
  @baseURL "https://api.napster.com/v2.1/"

  @doc """
  API key used for the requests.
  """
  def key do
    to_string System.get_env("NAPSTER_API_KEY")
  end

  def listGenres do
    url = @baseURL <> "genres"
    case HTTPoison.get url, headers: [apikey: key()] do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> IO.puts ("Success" <> body)
      {:ok, %HTTPoison.Response{status_code: 400, body: body}} -> IO.puts "Bad Request" <> body
      {:error, %HTTPoison.Error{reason: reason}} -> IO.inspect reason
    end
  end
end
