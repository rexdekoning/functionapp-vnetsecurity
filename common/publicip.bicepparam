using '../packages/public-ip-addresses/main.bicep'

param name = ''
param dnsSettings = {
  domainNameLabel: name
  domainNameLabelScope: 'NoReuse'
}
