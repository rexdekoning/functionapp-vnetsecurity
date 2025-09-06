using '../packages/app-service-plan/main.bicep'

// Required parameters
param name     = 'comesasparameter'
param kind     = 'FunctionApp'
param reserved = true
param location = ''
param skuName  = ''
param skuCapacity = 1
