using '../packages/virtual-networks/main.bicep'

param enableTelemetry = false
param addressPrefixes = [
  '10.2.0.0/23'
]
param name = ''
param dnsServers = [
  '10.2.0.132'
]
param subnets = [
  {
    name: 'AzureFirewallSubnet'
    addressPrefix: '10.2.0.128/26'
  }
  {
    name: 'GatewaySubnet'
    addressPrefix: '10.2.0.192/26'
    routeTableResourceId: readEnvironmentVariable('RouteTableGW')
  } 
]
