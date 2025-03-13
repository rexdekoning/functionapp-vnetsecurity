using '../packages/firewalls/main.bicep'

param name = 'myFirewall'
param virtualNetworkResourceId = ''
param publicIPResourceID = ''


param diagnosticSettings = [
  {
    logCategoriesAndGroups: [
      {
        category: 'AZFWApplicationRule'
      }
      {
        category: 'AzureFirewallApplicationRule'
      }
    ]
    name: 'customSetting'
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceResourceId: readEnvironmentVariable('Law')
  }
]

param firewallPolicyId = ''

