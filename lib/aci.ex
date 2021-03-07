defmodule ACI do
  @moduledoc """
  Documentation for `ACI`.
  """

  @doc """
  ACI Automation

  ## Examples
    iex(66)> ACI.start
    [OK] Post Request successful!
    [OK] Authentication successful!
    [OK] Get Request successful!
    [OK] Tenant List Retrive successful!

    [Result] Total retrive Tenant: 19
    [Result] Tenant List
              * infra
              * mgmt
              * common
              * Heroes
              * SnV
              * VM-LAB
              * Prod
              * tenant_kit
              * test
              * DEMO-TN
              * DevNet
              * D
              * K
              * PH_TEST
              * Darknova-2
              * Darknova
              * testtest
              * INITIALS_Example_Tenant
              * CL-Test
  """
  alias Poison
  alias HTTPoison
  import Param


  def start() do
    cookies = auth(apic_ip, username,password)
    tenants_list=list_tenants(apic_ip,cookies)
    IO.puts("")

    imdata = tenants_list["imdata"]
    total_tenants = tenants_list["totalCount"]
    IO.puts("[Result] Total retrive Tenant: " <> total_tenants)
    IO.puts("[Result] Tenant List")
    for tenant <- imdata do
      IO.puts("          * " <> tenant["fvTenant"][ "attributes"]["name"])

    end
    IO.puts("")

    :ok
  end

  def list_tenants(apic_ip,cookies) do
    uri = "/api/class/fvTenant.json"
    {response,status_code}=get_request(apic_ip,uri,[],hackney: [cookie: cookies])
    if status_code < 200 or status_code >= 300 do
         IO.puts("[ERROR] Tenant List Retrive failed!")
    else
         IO.puts("[OK] Tenant List Retrive successful!")
    end
    str_to_map(response.body)
  end

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
         IO.puts("[ERROR] Authentication failed!")
    else
         IO.puts("[OK] Authentication successful!")
    end
    cookies
  end


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
           IO.puts("[ERROR] Get Request failed! APIC responded with:")
           [head|_]=str_to_map(body)["imdata"]
           IO.inspect(head["error"]["attributes"]["code"])
           IO.inspect(head["error"]["attributes"]["text"])
      else
           IO.puts("[OK] Get Request successful!")
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
         IO.puts("[ERROR] Post Request failed! APIC responded with:")
         [head|_]=str_to_map(body)["imdata"]
         IO.inspect(head["error"]["attributes"]["code"])
         IO.inspect(head["error"]["attributes"]["text"])
    else
         IO.puts("[OK] Post Request successful!")
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
