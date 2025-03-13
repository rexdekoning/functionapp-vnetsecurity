using '../packages/virtual-machines/main.bicep'

param name = 'testvm'
param vmSize = 'Standard_B1s'
param encryptionAtHost = false
param imageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}
param osDisk = {
  name: 'osdisk'
  diskSizeGB: 30
  managedDisk: {
    storageAccountType: 'Standard_LRS'
  }
}
param adminUsername = 'rex'
param adminPassword = 'NietVertellenim@1'
param zone = 1
param nicConfigurations = [
  {
    ipConfigurations: [
      {
        name: 'ipconfig01'
        subnetResourceId: readEnvironmentVariable('mySubnetId')
      }
    ]
    nicSuffix: '-nic-01'
    enableAcceleratedNetworking: false
  }
]

param osType = 'Linux'
