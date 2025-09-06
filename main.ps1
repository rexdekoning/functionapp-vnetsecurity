#region general
$subscriptionID = "[subscriptionid]"
$tenantId       = "[tenantid]"
$location       = "westeurope"

az login --tenant $tenantId --use-device-code
az account set --subscription $subscriptionID



#endregion

#region demo0

$resourceGroupName  = "demo0"
$storageAccountName = "functionappstoragerdk0"
$appServicePlanName = "myAppServicePlan0"
$appServicePlanSku  = "B1"
$functionAppName    = "apptestrdk0"
$triggerName        = "trigger1"

az deployment sub create    --parameters ./common/resourcegroup.bicepparam --location $location `
                            --parameters name=$resourceGroupName `
                            --parameters location=$location

$storage        = az deployment group create --name storageaccount0  --parameters ./common/storage.bicepparam --resource-group $resourceGroupName --parameters name=$storageAccountName
$storageId      = $storage | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1
$storageAccount = az storage account show-connection-string -g $resourceGroupName -n $storageAccountName | convertfrom-json

$appServicePlan = az deployment group create    --name appserviceplan0 --parameters ./common/serviceplan.bicepparam --resource-group $resourceGroupName `
                                                --parameters name=$appServicePlanName `
                                                --parameters skuName=$appServicePlanSku `
                                                --parameters location=$location
$webFarmId      = $appServicePlan | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1

$webAppConfig = @{
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME" = "powershell"
    "AzureWebJobsStorage" = "$($storageAccount.connectionString)"
} | ConvertTo-Json

az deployment group create  --name functionapp0 --parameters ./common/functionappnovnet.bicepparam --resource-group $resourceGroupName `
                            --parameters name=$functionAppName `
                            --parameters serverFarmResourceId=$webFarmId `
                            --parameters location=$location `
                            --parameters storageAccountResourceId=$storageId `
                            --parameters appSettingsKeyValuePairs=$webAppConfig

az deployment group create  --name functionappcode0 --parameters ./common/trigger.bicepparam --resource-group $resourceGroupName `
                            --parameters functionappname=$functionAppName `
                            --parameters functionname=$triggerName

(Invoke-WebRequest -uri "https://$functionAppName.azurewebsites.net/api/$($triggerName)?").Content

#endregion

#region demo1

$resourceGroupName  = "demo1"
$virtualNetworkName = "vnetDemo1"
$storageAccountName = "functionappstoragerdk1"
$appServicePlanName = "myAppServicePlan1"
$appServicePlanSku  = "B1"
$functionAppName    = "apptestrdk1"
$triggerName        = "trigger1"
$NatGWName          = "myNatGateway1"
$NatGWIPName        = ("pip-$NatGWName").ToLower()
$subnetName         = "snFunctionOut"

az deployment sub create    --parameters ./common/resourcegroup.bicepparam --location $location `
                            --parameters name=$resourceGroupName `
                            --parameters location=$location

$vnet     = az deployment group create --parameters ./$resourceGroupName/vnet.bicepparam --resource-group $resourceGroupName --parameters name=$virtualNetworkName
$subnetId = $vnet | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputs | Select-Object -ExpandProperty subnetResourceIds | Select-Object -ExpandProperty value | Where-Object {$_ -like "*out"}

$natgwpip   = ,@(az deployment group create --name natgwpip1 --parameters ./common/publicip.bicepparam --resource-group $resourceGroupName  --parameters name=$NatGWIPName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id) | ConvertTo-Json
$natgateway = az deployment group create    --name natgw1 --parameters ./common/natgateway.bicepparam --resource-group $resourceGroupName `
                                            --parameters name=$NatGWName `
                                            --parameters publicIpResourceIds=$natgwpip | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1

$storage        = az deployment group create --name storageaccount1  --parameters ./common/storage.bicepparam --resource-group $resourceGroupName --parameters name=$storageAccountName
$storageId      = $storage | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1
$storageAccount = az storage account show-connection-string -g $resourceGroupName -n $storageAccountName | convertfrom-json

$appServicePlan = az deployment group create    --name appserviceplan1 --parameters ./common/serviceplan.bicepparam --resource-group $resourceGroupName `
                                                --parameters name=$appServicePlanName `
                                                --parameters skuName=$appServicePlanSku `
                                                --parameters location=$location
$webFarmId      = $appServicePlan | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1

$webAppConfig = @{
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME" = "powershell"
    "AzureWebJobsStorage" = "$($storageAccount.connectionString)"
} | ConvertTo-Json

az deployment group create  --name functionapp1 --parameters ./common/functionapp.bicepparam --resource-group $resourceGroupName `
                            --parameters name=$functionAppName `
                            --parameters serverFarmResourceId=$webFarmId `
                            --parameters location=$location `
                            --parameters storageAccountResourceId=$storageId `
                            --parameters virtualNetworkSubnetId=$subnetId `
                            --parameters appSettingsKeyValuePairs=$webAppConfig

az deployment group create  --name functionappcode1 --parameters ./common/trigger.bicepparam --resource-group $resourceGroupName `
                            --parameters functionappname=$functionAppName `
                            --parameters functionname=$triggerName

#az network vnet subnet update --name $subnetName --resource-group $resourceGroupName --vnet-name $virtualNetworkName --nat-gateway $natgateway

(Invoke-WebRequest -uri "https://$functionAppName.azurewebsites.net/api/$($triggerName)?").Content

#endregion

#region demo2

$resourceGroupName   = "demo2"
$virtualNetworkName1 = "vnetDemo2-1"
$virtualNetworkName2 = "vnetDemo2-2"
$virtualNetworkName3 = "vnetDemo2-3"
$storageAccountName  = "functionappstoragerdk2"
$appServicePlanName  = "myAppServicePlan2"
$appServicePlanSku   = "B1"
$functionAppName     = "apptestrdk2"
$triggerName         = "trigger1"
$subnetName          = "snFunctionOut"
$FWPIPName           = "pip-firewall"
$VNGPIPName          = "pip-vng"
$BastionPIPName      = "pip-bastion"
$APIMPIPName         = "pip-apim"
$APIMName            = "apimrex$(Get-Date -Format "yyyyMMdd")"
$PublisherEmail      = "rexdekoning@outlook.com"
$PublisherName       = "Rex de Koning"
$FrontDoorName      = "fdtest"

az deployment sub create    --parameters ./common/resourcegroup.bicepparam --location $location `
                            --parameters name=$resourceGroupName `
                            --parameters location=$location

$rt   = az deployment group create  --name routetable --parameters ./$resourceGroupName/routetable.bicepparam `
                                    --resource-group $resourceGroupName | ConvertFrom-Json | `
                                    Select-Object -ExpandProperty properties | `
                                    Select-Object -ExpandProperty outputResources | `
                                    Select-Object -ExpandProperty id
$rtgw = az deployment group create  --name routetablegw --parameters ./$resourceGroupName/rtgateway.bicepparam `
                                    --resource-group $resourceGroupName| ConvertFrom-Json | `
                                    Select-Object -ExpandProperty properties | `
                                    Select-Object -ExpandProperty outputResources | `
                                    Select-Object -ExpandProperty id

$apimNsgId = az deployment group create  --name apimnsg --parameters ./$resourceGroupName/apimnsg.bicepparam `
                                    --resource-group $resourceGroupName | ConvertFrom-Json | `
                                    Select-Object -ExpandProperty properties | `
                                    Select-Object -ExpandProperty outputResources | `
                                    Select-Object -ExpandProperty id

New-Item -Path Env:\RouteTable   -Value $rt -Force
New-Item -Path Env:\RouteTableGW -Value $rtgw -Force
New-Item -Path Env:\ApimNsgId -Value $apimNsgId -Force

$vnet1 = az deployment group create     --name vnet1 --parameters ./$resourceGroupName/vnet1.bicepparam `
                                        --resource-group $resourceGroupName --parameters name=$virtualNetworkName1 `
                                        | ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                        Select-Object -ExpandProperty outputResources | `
                                        Select-Object -ExpandProperty id
$vnet2 = az deployment group create     --name vnet2 --parameters ./$resourceGroupName/vnet2.bicepparam `
                                        --resource-group $resourceGroupName --parameters name=$virtualNetworkName2 `
                                        | ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                        Select-Object -ExpandProperty outputResources | `
                                        Select-Object -ExpandProperty id  
$vnet3 = az deployment group create     --name vnet3 --parameters ./$resourceGroupName/vnet3.bicepparam `
                                        --resource-group $resourceGroupName --parameters name=$virtualNetworkName3 `
                                        | ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                        Select-Object -ExpandProperty outputResources | `
                                        Select-Object -ExpandProperty id                                                                              

$vnet1Id      = $vnet1 | Select-Object -First 1
$vnet2Id      = $vnet2 | Select-Object -First 1
$vnet3Id      = $vnet3 | Select-Object -First 1
$subnetId     = $vnet2 | Where-Object {$_ -like "*out"}
$peSubnetId   = $vnet2 | Where-Object {$_ -like "*PrivateEndpoint"}
$apimSubnetId = $vnet2 | Where-Object {$_ -like "*Apim"}
$mySubnetId   = $vnet3 | Where-Object {$_ -like "*mySubnet"}

New-Item -Path Env:\VNet1Id -Value $vnet1Id -Force
New-Item -Path Env:\VNet2Id -Value $vnet2Id -Force
New-Item -Path Env:\VNet3Id -Value $vnet3Id -Force

az network vnet peering create -g $resourceGroupName -n MyVnet1ToMyVnet2 --vnet-name $virtualNetworkName1 --remote-vnet $vnet2Id --allow-vnet-access
az network vnet peering create -g $resourceGroupName -n MyVnet1ToMyVnet3 --vnet-name $virtualNetworkName1 --remote-vnet $vnet3Id --allow-vnet-access
az network vnet peering create -g $resourceGroupName -n MyVnet2ToMyVnet1 --vnet-name $virtualNetworkName2 --remote-vnet $vnet1Id --allow-vnet-access
az network vnet peering create -g $resourceGroupName -n MyVnet3ToMyVnet1 --vnet-name $virtualNetworkName3 --remote-vnet $vnet1Id --allow-vnet-access

New-Item -Path Env:\mySubnetId -Value $mySubnetId -Force
New-Item -Path Env:\ApimSubnetId -Value $apimSubnetId -Force
az deployment group create --name vm --parameters ./$resourceGroupName/vm.bicepparam --resource-group $resourceGroupName

$firewallpip = az deployment group create --name fwgwpip --parameters ./common/publicip.bicepparam --resource-group $resourceGroupName  --parameters name=$FWPIPName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id
$vngpip      = az deployment group create --name vngpip --parameters ./common/publicip.bicepparam --resource-group $resourceGroupName  --parameters name=$VNGPIPName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id
$bastionpip  = az deployment group create --name bastionip --parameters ./common/publicip.bicepparam --resource-group $resourceGroupName  --parameters name=$BastionPIPName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id
$apimpip     = az deployment group create --name bastionip --parameters ./common/publicip.bicepparam --resource-group $resourceGroupName  --parameters name=$APIMPIPName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id


az deployment group create  --name bastion --parameters ./$resourceGroupName/bastion.bicepparam --resource-group $resourceGroupName `
                            --parameters virtualNetworkResourceId=$vnet3Id `
                            --parameters bastionSubnetPublicIpResourceId=$bastionpip

$law      = az deployment group create --name law --parameters ./$resourceGroupName/law.bicepparam --resource-group $resourceGroupName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id
$fwpolicy = az deployment group create --name fwpolicy --parameters ./$resourceGroupName/firewallpolicy.bicepparam --resource-group $resourceGroupName | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1

New-Item -Path Env:\Law -Value $law -Force

az deployment group create --name firewall  --parameters ./$resourceGroupName/firewall.bicepparam --resource-group $resourceGroupName `
                                            --parameters virtualNetworkResourceId=$vnet1Id `
                                            --parameters publicIPResourceID=$firewallpip `
                                            --parameters firewallPolicyId=$fwpolicy

New-Item -Path Env:\TenantId -Value $tenantId -Force
az deployment group create  --name vng --parameters ./$resourceGroupName/p2s.bicepparam --resource-group $resourceGroupName `
                            --parameters existingFirstPipResourceId=$vngpip `
                            --parameters vNetResourceId=$vnet1id --no-wait


$storageId      = az deployment group create    --name storageaccount --parameters ./common/storage.bicepparam `
                                                --resource-group $resourceGroupName `
                                                --parameters name=$storageAccountName `
                                                --parameters publicNetworkAccess='Disabled' | `
                                                ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                                Select-Object -ExpandProperty outputResources | `
                                                Select-Object -ExpandProperty id -First 1
$storageAccount = az storage account show-connection-string -g $resourceGroupName -n $storageAccountName | convertfrom-json


$appServicePlan = az deployment group create    --name appserviceplan --parameters ./common/serviceplan.bicepparam --resource-group $resourceGroupName `
                                                --parameters name=$appServicePlanName `
                                                --parameters skuName=$appServicePlanSku `
                                                --parameters location=$location
$webFarmId      = $appServicePlan | ConvertFrom-Json | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty outputResources | Select-Object -ExpandProperty id -First 1

$webAppConfig = @{
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "FUNCTIONS_WORKER_RUNTIME" = "powershell"
    "AzureWebJobsStorage" = "$($storageAccount.connectionString)"
} | ConvertTo-Json

$WebAppID = az deployment group create  --name functionapp --parameters ./common/functionapp.bicepparam --resource-group $resourceGroupName `
                                        --parameters name=$functionAppName `
                                        --parameters serverFarmResourceId=$webFarmId `
                                        --parameters location=$location `
                                        --parameters storageAccountResourceId=$storageId `
                                        --parameters virtualNetworkSubnetId=$subnetId `
                                        --parameters appSettingsKeyValuePairs=$webAppConfig `
                                        --parameters publicNetworkAccess="Disabled" | `
                                        ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                        Select-Object -ExpandProperty outputResources | `
                                        Select-Object -ExpandProperty id -First 1

$storageZone = az deployment group create   --name privdnsstorage --parameters ./$resourceGroupName/privatednszonestorage.bicepparam `
                                            --resource-group $resourceGroupName | `
                                            ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                            Select-Object -ExpandProperty outputResources | `
                                            Select-Object -ExpandProperty id -First 1

New-Item -Path Env:\StorageId -Value $storageId -Force
New-Item -Path Env:\ZoneId -Value $storageZone -Force

$storagePE   = az deployment group create   --name pestorage --parameters ./$resourceGroupName/storageprivateendpoint.bicepparam `
                                            --resource-group $resourceGroupName `
                                            --parameters subnetResourceId=$peSubnetId


$webappZone = az deployment group create    --name privdnswebapp --parameters ./$resourceGroupName/privatednszone.bicepparam `
                                            --resource-group $resourceGroupName | `
                                            ConvertFrom-Json | Select-Object -ExpandProperty properties | `
                                            Select-Object -ExpandProperty outputResources | `
                                            Select-Object -ExpandProperty id -First 1

New-Item -Path Env:\WebAppId -Value $WebAppID -Force
New-Item -Path Env:\WebAppZoneId -Value $webappZone -Force

$webAppPE   = az deployment group create   --name webappstorage --parameters ./$resourceGroupName/webappprivateendpoint.bicepparam `
                                            --resource-group $resourceGroupName `
                                            --parameters subnetResourceId=$peSubnetId

az deployment group create  --name functionappcode --parameters ./common/trigger.bicepparam --resource-group $resourceGroupName `
                            --parameters functionappname=$functionAppName `
                            --parameters functionname=$triggerName

New-Item -Path Env:\ApimPipId -Value $apimpip -Force
New-Item -Path Env:\ApimServiceURL -Value "https://$functionAppName.azurewebsites.net/api/$($triggerName)?" -Force

$apim = az deployment group create --name apim --parameters ./$resourceGroupName/apim.bicepparam `
                                    --resource-group $resourceGroupName `
                                    --parameters subnetResourceId=$apimSubnetId `
                                    --parameters publicIpAddressResourceId=$apimpip `
                                    --parameters publisherEmail=$PublisherEmail `
                                    --parameters publisherName=$PublisherName `
                                    --parameters name=$APIMName `
                                    --no-wait 


New-Item -Path Env:\FDHostname -Value "$functionAppName.azurewebsites.net" -Force                                
$FrontDoor = az deployment group create --name frontdoor --parameters ./demo2/frontdoor.bicepparam `
                                        --parameters name=$FrontDoorName `
                                        --resource-group $resourceGroupName 

$EndPoint =  ($FrontDoor | ConvertFrom-Json).properties.outputs.frontDoorEndPointHostNames.Value        
$pe = az network private-endpoint-connection list -g $resourceGroupName  --id $WebAppID | ConvertFrom-Json

$pe | where-object { $_.properties.privateLinkServiceConnectionState.status -eq "Pending" } | `
    ForEach-Object { az network private-endpoint-connection approve --id $_.id --description "Approved by script" }

(Invoke-WebRequest -uri "https://$functionAppName.azurewebsites.net/api/$($triggerName)?").Content
(Invoke-WebRequest -uri "https://$EndPoint/api/trigger1?").Content
#endregion
