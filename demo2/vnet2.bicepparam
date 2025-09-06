using '../packages/virtual-networks/main.bicep'

param enableTelemetry = false
param addressPrefixes = [
  '10.1.0.0/23'
]
param name = ''
param dnsServers = [
  '10.2.0.132'
]
param subnets = [
  {
    name: 'snFunctionIn'
    addressPrefix: '10.1.0.0/26'
    delegation: 'Microsoft.Web/serverFarms'
    routeTableResourceId: readEnvironmentVariable('RouteTable')
  }
  {
    name: 'snFunctionOut'
    addressPrefix: '10.1.0.64/26'
    delegation: 'Microsoft.Web/serverFarms'
    routeTableResourceId: readEnvironmentVariable('RouteTable')
  }
  {
    name: 'PrivateEndpoint'
    addressPrefix: '10.1.1.128/26'
    routeTableResourceId: readEnvironmentVariable('RouteTable')
  }
  {
    name: 'Apim'
    addressPrefix: '10.1.1.192/26'
    //routeTableResourceId: readEnvironmentVariable('RouteTable')
    networkSecurityGroupResourceId: readEnvironmentVariable('ApimNsgId')
  }
]
