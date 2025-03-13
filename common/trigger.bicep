param functionappname string
param functionname string

resource functionapp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: functionappname
}

resource function 'Microsoft.Web/sites/functions@2020-12-01' = {
  parent: functionapp
  name: functionname
  properties: {
    config: {
      disabled: false
      bindings: [
        {
          name: 'req'
          type: 'httpTrigger'
          direction: 'in'
          authLevel: 'function'
          methods: [
            'get'
          ]
        }
        {
          name: '$return'
          type: 'http'
          direction: 'out'
        }
      ]
    }
    files: {
      'run.ps1': loadTextContent('source/run.ps1')
      'function.json': loadTextContent('source/function.json')
    }
  }
}
