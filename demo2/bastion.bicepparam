using '../packages/bastion-hosts/main.bicep'

param name = 'bastion'
param virtualNetworkResourceId = ''
param bastionSubnetPublicIpResourceId = ''
param skuName = 'Basic'
