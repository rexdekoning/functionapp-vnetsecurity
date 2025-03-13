using '../packages/storage-accounts/main.bicep'

param name    = ''
param skuName = 'Standard_LRS'

param networkAcls = {
  defaultAction: 'Allow'
  bypass: 'AzureServices'
}

param publicNetworkAccess = 'Enabled'
