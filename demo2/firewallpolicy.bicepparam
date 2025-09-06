using '../packages/firewall-policies/main.bicep'

param name = 'myFirewallPolicy'
param enableProxy = true
param servers = [
  '168.63.129.16'
]
param ruleCollectionGroups = [
  {
    name: 'rule-001'
    priority: 100
    ruleCollections: [
      {
        action: {
          type: 'Allow'
        }
        name: 'applicationRuleCollection001'
        priority: 300
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'donotuseinprodapp'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: [
              '*'
            ]
            targetUrls: []
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
        ]
      }
      {
        action: {
          type: 'Allow'
        }
        name: 'networkRuleCollection001'
        priority: 200
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'donotuseinprodnw'
            destinationAddresses: [
              '*'
            ]
            destinationFqdns: []
            destinationIpGroups: []
            destinationPorts: [
              '*'
            ]
            ipProtocols: [
              'Any'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
          }
        ]
      }      
    ]
  }
]
