using '../packages/virtual-network-gateways/main.bicep'

param name = 'myVNG'
param existingFirstPipResourceId = ''
param gatewayType = 'Vpn'
param vpnGatewayGeneration = 'Generation1'
param skuName = 'VpnGw1AZ'
param vNetResourceId = ''
param clusterSettings = {
  clusterMode: 'activePassiveNoBgp'
}
param vpnClientAddressPoolPrefix = '192.168.14.0/24'
param vpnClientAadConfiguration = {
  aadTenant: concat('https://login.microsoftonline.com/', readEnvironmentVariable('TenantId'))
  aadAudience: '41b23e61-6c1e-4545-b367-cd054e0ed4b4'
  aadIssuer: concat('https://sts.windows.net/', readEnvironmentVariable('TenantId'),'/')
  vpnAuthenticationTypes: [
    'Aad'
  ]
  vpnClientProtocols: [
    'OpenVPN'    
  ]
}
param customRoutes = {
  addressPrefixes: [
    '10.1.0.0/23'
    '10.3.0.0/23'
  ]
}
