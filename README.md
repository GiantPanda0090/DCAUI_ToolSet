# DCAUI_ToolSet

Practice toolset for Cisco Automating Cisco Data Center Solutions. Inspired by Cisco DCAUTI Training  

Testbed for Elixir Data Center Network Automation  
Suggest to test the library with Cisco Devnet Sandbox:  
ACI:  
https://developer.cisco.com/docs/aci/#!sandbox/aci-sandboxes  
NXOS:  


UCS:  



## Module list
aci - ACI Automation  
nxos -  NXOS Automation  
ucs - UCS Automation  

Parameter for Login:  
param - Parameter for all module  

## Status
ACI Module In Progress....  

## Examples
$ iex -S mix  
iex(65)> import ACI  
iex(66)> start  
=====================Log==========================  
[OK] Post Request successful!  
[OK] Authentication successful!  
[OK] Get Request successful!  
[OK] Tenant List Retrive successful!  
[OK] Post Request successful!  
[OK] Security Domain-Manage Object update successful!  
=====================Result==========================  
[Result] Total retrive Tenant: 2  
[Result] Tenant List  
          * TEST1  
          * TEST2  
=======================End==============================  
:ok  

## Installation (Not available yet)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `aci` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aci, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/aci](https://hexdocs.pm/aci).
