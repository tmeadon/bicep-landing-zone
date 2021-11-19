param sourceVnetName string
param sourceVnetConfig object
param targetVnetName string
param targetVnetConfig object

// get references to the vnets
resource sourceVnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: sourceVnetName
  scope: resourceGroup(sourceVnetConfig.resourceGroup)
}

resource targetVnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: targetVnetName
  scope: resourceGroup(targetVnetConfig.resourceGroup)
}

// determine if the source or destination have gateways deployed
var sourceHasGateways = contains(sourceVnetConfig, 'gateways') && (length(sourceVnetConfig.gateways) > 0)
var targetHasGateways = contains(targetVnetConfig, 'gateways') && (length(targetVnetConfig.gateways) > 0)

// connect the source to the target
module sourceToTarget 'individual_peering.bicep' = {
  name: '${sourceVnetName}-to-${targetVnetName}'
  scope: resourceGroup(sourceVnetConfig.resourceGroup)
  params: {
    sourceVnetName: sourceVnet.name
    sourceIsHub: sourceVnetConfig.isHub
    remoteVnetId: targetVnet.id
    remoteIsHub: targetVnetConfig.isHub
    remoteHasGateway: targetHasGateways
  }
}

// connect the target back to the source
module targetToSource 'individual_peering.bicep' = {
  name: '${targetVnetName}-to-${sourceVnetName}'
  scope: resourceGroup(targetVnetConfig.resourceGroup)
  params: {
    sourceVnetName: targetVnet.name
    sourceIsHub: targetVnetConfig.isHub
    remoteVnetId: sourceVnet.id
    remoteIsHub: sourceVnetConfig.isHub
    remoteHasGateway: sourceHasGateways
  }
}
