using '../packages/cdn-profiles/main.bicep'

param name = 'fdtest'
param sku = 'Premium_AzureFrontDoor'
param location = 'global'

param afdEndpoints = [
  {
    name: 'test-endpoint'
    routes: [
      {
        name: 'test-route'
        originGroupName: 'test-origin-group'
      }
    ]
  }
]

param originGroups = [
  {
    loadBalancingSettings: {
      additionalLatencyInMilliseconds: 50
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    name: 'test-origin-group'
    origins: [
      {
        hostName: readEnvironmentVariable('FDHostname')
        name: 'test-origin'
        sharedPrivateLinkResource: {
          groupId: 'sites'
          privateLink: {
            id: readEnvironmentVariable('WebAppId')
          }
          privateLinkLocation: 'westeurope'
          requestMessage: 'message'
          status: 'Approved'
        }

      }
    ]
  }
]
param originResponseTimeoutSeconds = 60

