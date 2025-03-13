using '../packages/route-tables/main.bicep'

param name = 'myRouteTable'
param routes = [
  {
    name: 'route1'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.2.0.132'
    }
  }
]
