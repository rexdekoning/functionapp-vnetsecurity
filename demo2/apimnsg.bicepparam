using '../packages/network-security-groups/main.bicep'

param name = 'apim-nsg'
param securityRules = [
  {
    name: 'InternetInbound'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 100
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'Internet'
      destinationAddressPrefix: 'VirtualNetwork'
      description: 'Client communication to API Management'
    }
  }
  {
    name: 'ApiManagementInbound'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 110
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      description: 'Management endpoint for Azure portal and PowerShell'
    }
  }
  {
    name: 'AzureLoadBalancerInbound'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 120
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6390'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: 'VirtualNetwork'
      description: 'Azure Infrastructure Load Balancer'
    }
  }
    {
    name: 'AzureTrafficManagerInbound'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 130
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'AzureTrafficManager'
      destinationAddressPrefix: 'VirtualNetwork'
      description: 'Azure Traffic Manager routing for multi-region deployment'
    }
  }
  {
    name: 'StorageOutBound'
    properties: {
      access: 'Allow'
      direction: 'Outbound'
      priority: 140
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      description: 'Dependency on Azure Storage for core service functionality'
    }
  }
  {
    name: 'SQLOutBound'
    properties: {
      access: 'Allow'
      direction: 'Outbound'
      priority: 150
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '1433'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'SQL'
      description: 'Access to Azure SQL endpoints for core service functionality'
    }
  }
  {
    name: 'AzureKeyvaultOutBound'
    properties: {
      access: 'Allow'
      direction: 'Outbound'
      priority: 160
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureKeyvault'
      description: 'Access to Azure Key Vault for core service functionality'
    }
  }
  {
    name: 'AzureMonitorOutBound'
    properties: {
      access: 'Allow'
      direction: 'Outbound'
      priority: 170
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRanges: [
        '443'
        '1886'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      description: 'Publish Diagnostics Logs and Metrics, Resource Health, and Application Insights'
    }
  }
]
