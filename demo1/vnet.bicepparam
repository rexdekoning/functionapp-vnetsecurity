using '../packages/virtual-networks/main.bicep'

param enableTelemetry = false
param addressPrefixes = [
  '10.0.0.0/23'
]
param name = ''
param subnets = [
  {
    name: 'mySubnet'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'snFunctionIn'
    addressPrefix: '10.0.0.0/26'
    delegation: 'Microsoft.Web/serverFarms'
  }
  {
    name: 'snFunctionOut'
    addressPrefix: '10.0.0.64/26'
    delegation: 'Microsoft.Web/serverFarms'
  }
]
