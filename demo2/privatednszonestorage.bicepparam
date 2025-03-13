using '../packages/private-dns-zones/main.bicep'

param name = 'privatelink.blob.core.windows.net'
param virtualNetworkLinks = [
  {
    name: 'myVNetLinkStorageVNet1'
    virtualNetworkResourceId: readEnvironmentVariable('VNet1Id')
    registrationEnabled: false
  }
  {
    name: 'myVNetLinkStorageVNet2'
    virtualNetworkResourceId: readEnvironmentVariable('VNet2Id')
    registrationEnabled: false
  }
  {
    name: 'myVNetLinkStorageVNet3'
    virtualNetworkResourceId: readEnvironmentVariable('VNet3Id')
    registrationEnabled: false
  } 
]
