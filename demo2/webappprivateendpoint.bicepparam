using '../packages/private-endpoints/main.bicep'

param name = 'pe-webapp'
param subnetResourceId  = ''

param privateLinkServiceConnections = [
  {
    name: 'myPLSC'
    properties: {
      privateLinkServiceId: readEnvironmentVariable('WebAppId')
      groupIds: [
        'sites'
      ]
    }
  }
]

param     privateDnsZoneGroup = {
  name: 'default'
  privateDnsZoneGroupConfigs: [
    {
      name: 'config'
      privateDnsZoneResourceId: readEnvironmentVariable('WebAppZoneId')
    }
  ]
}
