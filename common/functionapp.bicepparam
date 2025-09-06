using '../packages/web-function-apps/main.bicep'
// Required parameters
param kind                                    = 'functionapp'
param name                                    = 'test'
param location                                = 'westeurope'
param serverFarmResourceId                    = ''
param storageAccountResourceId                = ''
param virtualNetworkSubnetId                  = ''
param storageAccountUseIdentityAuthentication = true
param appSettingsKeyValuePairs                = null
param vnetRouteAllEnabled                     = true
param storageAccountRequired                  = true

param siteConfig = {
  alwaysOn: true
  minTlsVersion: '1.2'
  ftpsState: 'FtpsOnly'
  linuxFxVersion: 'PowerShell|7.4'
  vnetRouteAllEnabled: true
  cors: {
    allowedOrigins: [
        'https://portal.azure.com'
    ]
    supportCredentials: false
  }
  ipSecurityRestrictions: [
    {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
    }
  ]
  scmIpSecurityRestrictions: [
    {
      ipAddress: 'Any'
      action: 'Allow'
      priority: 2147483647
      name: 'Allow all'
      description: 'Allow all access'
    }
  ]
}
// param managedIdentities = {
//   systemAssigned: false
//   userAssignedResourceIds: [
//     readEnvironmentVariable('ManagedIdentity')
//   ]
// }

param managedIdentities = {
  systemAssigned: true
}
