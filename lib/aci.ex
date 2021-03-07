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
    cookies = auth(apic_ip, username,password)
    list_tenants(apic_ip,cookies)
    #{:ok}
  end

  def list_tenants(apic_ip,cookies) do
    uri = "/api/class/fvTenant.json"
    {response,status_code}=get_request(apic_ip,uri,[],hackney: [cookie: cookies])
    if status_code < 200 or status_code >= 300 do
         IO.puts("\n[ERROR] Tenant List Retrive failed!")
    else
         IO.puts("\n[OK] Tenant List Retrive successful!")
    end
    str_to_map(response.body)
  end
  # def main():
  #     cookies = get_cookies(APIC_HOST)
  #
  #     rsp = get_request(APIC_HOST, cookies, "/api/class/fvTenant.json")
  #     rsp_dict = json.loads(rsp.text)
  #     tenants = rsp_dict["imdata"]
  #
  #     print("\nNumber of tenants: {}".format(rsp_dict["totalCount"]))
  #
  #     for tenant in tenants:
  #         print(tenant["fvTenant"]["attributes"]["name"])



  def auth(apic_ip, username,password) do
    uri = "/api/aaaLogin.json"
    body = Poison.encode!(%{
          "aaaUser"=> %{
            "attributes"=> %{
              "name"=> username,
              "pwd"=> password
              }
            }
      })
    {response,status_code} = post_request(apic_ip,body,uri,[],[])
    {"Set-Cookie", cookies}=Enum.at(response.headers, 5)
    if status_code < 200 or status_code >= 300 do
         IO.puts("\n[ERROR] Authentication failed!")
    else
         IO.puts("\n[OK] Authentication successful!")
    end
    cookies
  end
    #headers =  hackney: [:insecure]


    def get_request(apic_ip,uri,headers,options) do
      url = "https://" <> apic_ip <> uri
      response = %HTTPoison.Response{
          body: body,
          headers: headers,
          request: request,
          request_url: url,
          status_code: status_code
      }= HTTPoison.get!(url, headers,options)
      if status_code < 200 or status_code >= 300 do
           IO.puts("\n[ERROR] Get Request failed! APIC responded with:")
           [head|_]=str_to_map(body)["imdata"]
           IO.inspect(head["error"]["attributes"]["code"])
           IO.inspect(head["error"]["attributes"]["text"])
      else
           IO.puts("\n[OK] Get Request successful!")
      end
          {response,status_code}
      end


  def post_request(apic_ip,body,uri,headers,options) do
    url = "https://" <> apic_ip <> uri
    response = %HTTPoison.Response{
        body: body,
        headers: headers,
        request: request,
        request_url: url,
        status_code: status_code
    }= HTTPoison.post!(url, body,headers,options)
    if status_code < 200 or status_code >= 300 do
         IO.puts("\n[ERROR] Post Request failed! APIC responded with:")
         [head|_]=str_to_map(body)["imdata"]
         IO.inspect(head["error"]["attributes"]["code"])
         IO.inspect(head["error"]["attributes"]["text"])
    else
         IO.puts("\n[OK] Post Request successful!")
    end
      {response,status_code}
    end

##https://stackoverflow.com/questions/37676789/convert-string-to-map
  def str_to_map(s) do
      s
      |> String.replace("'", "\"")
      |> Poison.decode!
  end


end
