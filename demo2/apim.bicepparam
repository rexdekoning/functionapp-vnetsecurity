using '../packages/api-management-services/main.bicep'

param name = 'someapimname'
param publisherEmail = 'publisher@email.com'
param publisherName = 'PublisherName'
param sku = 'Developer'
param subnetResourceId = ''
param virtualNetworkType = 'External'
param publicIpAddressResourceId = ''
param apis = [
  {
    name: readEnvironmentVariable('ApimName')
    displayName: readEnvironmentVariable('ApimName')
    apiRevision: '1'
    serviceUrl: readEnvironmentVariable('ApimServiceURL')
    path: 'apimrex'
    protocols: [
      'https'
    ]
    isCurrent: true
    operations: [
      {
        name: 'getip'
        displayName: 'Get IP'
        method: 'GET'
        urlTemplate: '/'
      }
    ]
  }
]
