using '../packages/private-endpoints/main.bicep'

param name = 'pe-storage'
param subnetResourceId  = ''

param privateLinkServiceConnections = [
  {
    name: 'myPLSCStorage'
    properties: {
      privateLinkServiceId: readEnvironmentVariable('StorageId')
      groupIds: [
        'blob'
      ]
    }
  }
]

param privateDnsZoneGroup = {
  name: 'default'
  privateDnsZoneGroupConfigs: [
    {
      name: 'config'
      privateDnsZoneResourceId: readEnvironmentVariable('ZoneId')
    }
  ]
}
