param networkInterfaceName string
param virtualMachineName string
param ipConfigurations array

@description('Optional. Location for all resources.')
param location string

@description('Optional. Tags of the resource.')
param tags object?

param enableIPForwarding bool = false
param enableAcceleratedNetworking bool = false
param dnsServers array = []

@description('Required. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableTelemetry bool

@description('Optional. The network security group (NSG) to attach to the network interface.')
param networkSecurityGroupResourceId string = ''

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. The diagnostic settings of the Network Interface.')
param diagnosticSettings diagnosticSettingType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

module networkInterface_publicIPAddresses '../packages/public-ip-addresses/main.bicep' = [
  for (ipConfiguration, index) in ipConfigurations: if (contains(ipConfiguration, 'pipConfiguration') && !contains(
    ipConfiguration.pipConfiguration,
    'publicIPAddressResourceId'
  )) {
    name: '${deployment().name}-publicIP-${index}'
    params: {
      name: ipConfiguration.pipConfiguration.?name ?? '${virtualMachineName}${ipConfiguration.pipConfiguration.?publicIpNameSuffix}'
      diagnosticSettings: ipConfiguration.?diagnosticSettings
      location: location
      lock: lock
      idleTimeoutInMinutes: ipConfiguration.pipConfiguration.?idleTimeoutInMinutes
      ddosSettings: ipConfiguration.pipConfiguration.?ddosSettings
      dnsSettings: ipConfiguration.pipConfiguration.?dnsSettings
      publicIPAddressVersion: ipConfiguration.pipConfiguration.?publicIPAddressVersion ?? 'IPv4'
      publicIPAllocationMethod: ipConfiguration.pipConfiguration.?publicIPAllocationMethod ?? 'Static'
      publicIpPrefixResourceId: ipConfiguration.pipConfiguration.?publicIPPrefixResourceId ?? ''
      roleAssignments: ipConfiguration.pipConfiguration.?roleAssignments ?? []
      skuName: ipConfiguration.pipConfiguration.?skuName ?? 'Standard'
      skuTier: ipConfiguration.pipConfiguration.?skuTier ?? 'Regional'
      tags: ipConfiguration.?tags ?? tags
      zones: ipConfiguration.pipConfiguration.?zones ?? [
        1
        2
        3
      ]
      enableTelemetry: ipConfiguration.?enableTelemetry ?? enableTelemetry
    }
  }
]

module networkInterface '../packages/network-interface/main.bicep' = {
  name: '${deployment().name}-NetworkInterface'
  params: {
    name: networkInterfaceName
    ipConfigurations: [
      for (ipConfiguration, index) in ipConfigurations: {
        name: !empty(ipConfiguration.name) ? ipConfiguration.name : null
        primary: index == 0
        privateIPAllocationMethod: contains(ipConfiguration, 'privateIPAllocationMethod')
          ? (!empty(ipConfiguration.privateIPAllocationMethod) ? ipConfiguration.privateIPAllocationMethod : null)
          : null
        privateIPAddress: contains(ipConfiguration, 'privateIPAddress')
          ? (!empty(ipConfiguration.privateIPAddress) ? ipConfiguration.privateIPAddress : null)
          : null
        publicIPAddressResourceId: contains(ipConfiguration, 'pipConfiguration')
          ? !contains(ipConfiguration.pipConfiguration, 'publicIPAddressResourceId')
              ? resourceId(
                  'Microsoft.Network/publicIPAddresses',
                  ipConfiguration.pipConfiguration.?name ?? '${virtualMachineName}${ipConfiguration.pipConfiguration.?publicIpNameSuffix}'
                )
              : ipConfiguration.pipConfiguration.publicIPAddressResourceId
          : null
        subnetResourceId: ipConfiguration.subnetResourceId
        loadBalancerBackendAddressPools: ipConfiguration.?loadBalancerBackendAddressPools ?? null
        applicationSecurityGroups: ipConfiguration.?applicationSecurityGroups ?? null
        applicationGatewayBackendAddressPools: ipConfiguration.?applicationGatewayBackendAddressPools ?? null
        gatewayLoadBalancer: ipConfiguration.?gatewayLoadBalancer ?? null
        loadBalancerInboundNatRules: ipConfiguration.?loadBalancerInboundNatRules ?? null
        privateIPAddressVersion: ipConfiguration.?privateIPAddressVersion ?? null
        virtualNetworkTaps: ipConfiguration.?virtualNetworkTaps ?? null
      }
    ]
    location: location
    tags: tags
    diagnosticSettings: diagnosticSettings
    dnsServers: !empty(dnsServers) ? dnsServers : []
    enableAcceleratedNetworking: enableAcceleratedNetworking
    enableTelemetry: enableTelemetry
    enableIPForwarding: enableIPForwarding
    lock: lock
    networkSecurityGroupResourceId: !empty(networkSecurityGroupResourceId) ? networkSecurityGroupResourceId : ''
    roleAssignments: !empty(roleAssignments) ? roleAssignments : []
  }
  dependsOn: [
    networkInterface_publicIPAddresses
  ]
}

// =============== //
//   Definitions   //
// =============== //

type lockType = {
  @description('Optional. Specify the name of lock.')
  name: string?

  @description('Optional. Specify the type of lock.')
  kind: ('CanNotDelete' | 'ReadOnly' | 'None')?
}?

type diagnosticSettingType = {
  @description('Optional. The name of diagnostic setting.')
  name: string?

  @description('Optional. The name of logs that will be streamed. "allLogs" includes all possible logs for the resource. Set to `[]` to disable log collection.')
  logCategoriesAndGroups: {
    @description('Optional. Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.')
    category: string?

    @description('Optional. Name of a Diagnostic Log category group for a resource type this setting is applied to. Set to `allLogs` to collect all logs.')
    categoryGroup: string?

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.')
  metricCategories: {
    @description('Required. Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.')
    category: string

    @description('Optional. Enable or disable the category explicitly. Default is `true`.')
    enabled: bool?
  }[]?

  @description('Optional. A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.')
  logAnalyticsDestinationType: ('Dedicated' | 'AzureDiagnostics')?

  @description('Optional. Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  workspaceResourceId: string?

  @description('Optional. Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
  eventHubAuthorizationRuleResourceId: string?

  @description('Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.')
  eventHubName: string?

  @description('Optional. The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.')
  marketplacePartnerResourceId: string?
}[]?

type roleAssignmentType = {
  @description('Required. The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
  roleDefinitionIdOrName: string

  @description('Required. The principal ID of the principal (user/group/identity) to assign the role to.')
  principalId: string

  @description('Optional. The principal type of the assigned principal ID.')
  principalType: ('ServicePrincipal' | 'Group' | 'User' | 'ForeignGroup' | 'Device')?

  @description('Optional. The description of the role assignment.')
  description: string?

  @description('Optional. The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".')
  condition: string?

  @description('Optional. Version of the condition.')
  conditionVersion: '2.0'?

  @description('Optional. The Resource Id of the delegated managed identity resource.')
  delegatedManagedIdentityResourceId: string?
}[]?

