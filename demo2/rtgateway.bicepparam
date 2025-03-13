using '../packages/route-tables/main.bicep'

param name = 'myRouteTableGW'
param routes = [
  {
    name: 'route1'
    properties: {
      addressPrefix: '10.1.0.0/23'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.2.0.132'
    }
  }
  {
    name: 'route2'
    properties: {
      addressPrefix: '10.2.0.0/23'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.2.0.132'
    }
  }
  {
    name: 'route3'
    properties: {
      addressPrefix: '10.3.0.0/23'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.2.0.132'
    }
  }
]
