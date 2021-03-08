defmodule ACI do
  @moduledoc """
  Documentation for `ACI`.
  """

  @doc """
  ACI Automation

  ## Examples
    iex(66)> ACI.start
    =====================Log==========================
    [OK] Post Request successful!
    [OK] Authentication successful!
    [OK] Get Request successful!
    [OK] Tenant List Retrive successful!
    [OK] Post Request successful!
    [OK] Security Domain-Manage Object update successful!
    =====================Result==========================
    [Result] Total retrive Tenant: 51
    [Result] Tenant List
              * TEST1
              * TEST2
    =======================End==============================
  """
  alias Poison
  alias JSON
  alias HTTPoison
  import Param

## Main
  def start() do
    final_status = 0
    IO.puts("=====================Log==========================")
    {status,cookies} = auth(apic_ip, username,password)
    final_status = final_status + status
    if final_status == 0 do
      {status,tenants_list}=list_tenants(apic_ip,cookies)
      final_status = final_status + status
      {status,output}=create_sec_domain(apic_ip,cookies,"SECDOM-PYTHON","Python Managed Tenants")
      final_status = final_status + status
      {status,output} = add_user_tosec(apic_ip,cookies,"python","cisco123","all","read-all", "readPriv","SECDOM-PYTHON","tenant-ext-admin","writePriv")
      final_status = final_status + status
      IO.puts("=====================Result==========================")
      ## Result
      imdata = tenants_list["imdata"]
      total_tenants = tenants_list["totalCount"]
      IO.puts("[Result] Total retrive Tenant: " <> total_tenants)
      IO.puts("[Result] Tenant List")
      for tenant <- imdata do
        IO.puts("          * " <> tenant["fvTenant"][ "attributes"]["name"])
      end
      IO.puts("=======================End==============================\n")
      if final_status == 0 do
        :ok
      else
        :err
      end
    else
      :err
    end
  end

## add user to security domain
def add_user_tosec(apic_ip,cookies,username,password,range,user_role, privacy_type,security_domain,sec_user_role,sec_priv) do
  uri = "/api/mo/uni/userext/user-python.json"
  user = %{
    "aaaUser" => %{
      "attributes" => %{
        "name" => username,
        "pwd" => password
        },
        "children" => [
            %{
                "aaaUserDomain"=> %{
                    "attributes"=> %{
                      "name"=> range
                      },
                    "children"=> [
                        %{
                            "aaaUserRole"=> %{
                                "attributes"=> %{
                                    "name"=> user_role,
                                    "privType"=> privacy_type
                                }
                            }
                        }
                    ]
                }
            },
            %{
                "aaaUserDomain"=> %{
                    "attributes"=> %{
                      "name"=> "common"
                      },
                    "children"=> [
                        %{
                            "aaaUserRole"=> %{
                                "attributes"=> %{
                                    "name"=> user_role,
                                    "privType"=>  privacy_type
                                }
                            }
                        }
                    ]
                }
            },
            %{
                "aaaUserDomain"=> %{
                    "attributes"=> %{
                      "name"=> security_domain
                      },
                    "children"=> [
                        %{
                            "aaaUserRole"=> %{
                                "attributes"=> %{
                                    "name"=> sec_user_role,
                                    "privType"=> sec_priv
                                      }
                                  }
                              }
                          ]
                      }
                  },
              ]
          }
      }
      payload = JSON.encode!(user)
      {response,status_code} = post_request(apic_ip,payload,uri,[],hackney: [cookie: cookies])
      if status_code < 200 or status_code >= 300 do
           IO.puts("[ERROR] New user creation and privileges assign to the Security Domain Process failed!")
           {1,str_to_map(response.body)}
      else
           IO.puts("[OK] New user creation and privileges assign to the Security Domain Process successful!")
           {0,str_to_map(response.body)}
      end

end

## create a new security domain-managed object
  def create_sec_domain(apic_ip,cookies,name,descr) do
    uri = "/api/mo/uni/userext/domain-SECDOM-PYTHON.json"
    secdom = Poison.encode!(%{
           "aaaDomain"=> %{
            "attributes"=> %{
              "name" => name ,
              "descr" => descr
              }
            }
      })

      {response,status_code} = post_request(apic_ip,secdom,uri,[],hackney: [cookie: cookies])
      if status_code < 200 or status_code >= 300 do
           IO.puts("[ERROR] Security Domain-Manage Object update failed!")
           {1,str_to_map(response.body)}
      else
           IO.puts("[OK] Security Domain-Manage Object update successful!")
           {0,str_to_map(response.body)}
      end
  end

## Retrive Tenants List
  def list_tenants(apic_ip,cookies) do
    uri = "/api/class/fvTenant.json"
    {response,status_code}=get_request(apic_ip,uri,[],hackney: [cookie: cookies])
    if status_code < 200 or status_code >= 300 do
         IO.puts("[ERROR] Tenant List Retrive failed!")
         {1,str_to_map(response.body)}
    else
         IO.puts("[OK] Tenant List Retrive successful!")
         {0,str_to_map(response.body)}
    end
  end

##Log in
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

    if status_code < 200 or status_code >= 300 do
         IO.puts("[ERROR] Authentication failed!")
         {1,str_to_map(response.body)}
    else
         IO.puts("[OK] Authentication successful!")
         {"Set-Cookie", cookies}=Enum.at(response.headers, 5)
         {0,cookies}
    end
  end

## GET Request
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

## POST Request
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
      |> Poison.decode!
  end


end
