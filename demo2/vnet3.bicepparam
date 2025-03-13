using '../packages/virtual-networks/main.bicep'

param enableTelemetry = false
param addressPrefixes = [
  '10.3.0.0/23'
]
param name = ''
param dnsServers = [
  '10.2.0.132'
]
param subnets = [
  {
    name: 'mySubnet'
    addressPrefix: '10.3.1.0/26'
    routeTableResourceId: readEnvironmentVariable('RouteTable')
  }
  {
    name: 'AzureBastionSubnet'
    addressPrefix: '10.3.1.64/26'
  } 
]
