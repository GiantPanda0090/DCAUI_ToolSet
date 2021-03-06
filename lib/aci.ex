defmodule ACI do
  @moduledoc """
  Documentation for `ACI`.
  """

  @doc """
  ACI Automation

  ## Examples


  """
  alias Poison
  alias HTTPoison
  import Param


  def start() do
    auth(apic_ip, username,password)
  end



  def auth(apic_ip, username,password) do
    uri = "/api/aaaLogin.json"
    url = "https://" <> apic_ip <> uri
    #headers =  hackney: [:insecure]
    body = Poison.encode!(%{
          "aaaUser"=> %{
            "attributes"=> %{
              "name"=> username,
              "pwd"=> password
              }
            }
      })
      %HTTPoison.Response{
  body: body,
  headers: headers,
  request: request,
  request_url: url,
  status_code: status_code
}= HTTPoison.post!(url, body)
    if status_code < 200 or status_code >= 300 do
         IO.puts("\n[ERROR] Authentication failed! APIC responded with:")
         [head|_]=str_to_map(body)["imdata"]
         IO.inspect(head["error"]["attributes"])
    else
      IO.puts("\n[OK] Authentication succeissful!")
    end
    status_code
  end

##https://stackoverflow.com/questions/37676789/convert-string-to-map
  def str_to_map(s) do
      b = Regex.replace(~r/([a-z0-9]+):/, s, "\"\\1\":")
      b |> String.replace("'", "\"") |> Poison.decode!
  end


end
