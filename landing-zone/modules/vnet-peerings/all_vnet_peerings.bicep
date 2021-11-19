param networkConfigKey string
param allNetworkConfigs object
param environments object

// use the networkConfigKey variable to extract the relevant section of the network config file 
var sourceNetworkConfig = allNetworkConfigs[networkConfigKey]

// get a list of the target vnets or create an empty array if there is no list
var targetVnets = contains(sourceNetworkConfig, 'peerings') ? sourceNetworkConfig.peerings : []

// generate nomenclature for the source vnet
module sourceVnetNaming '../naming.bicep' = {
  name: 'sourceVnetNaming'
  params: {
    namingComponents: environments[sourceNetworkConfig.environment].naming
  }
}

// generate nomenclature for all of the target vnets
module targetVnetNaming '../naming.bicep' = [for targetVnet in targetVnets: {
  name: 'targetVnetNaming-${targetVnet}'
  params: {
    namingComponents: environments[allNetworkConfigs[targetVnet].environment].naming
  }
}]

// iterate through the target vnets and deploy peerings 
module vnetPeerings 'bidirectional_peerings.bicep' = [for (targetVnet, i) in targetVnets: {
  name: 'peerings-${targetVnet}'
  params: {
    targetVnetConfig: allNetworkConfigs[targetVnet]
    targetVnetName: targetVnetNaming[i].outputs.vnet
    sourceVnetName: sourceVnetNaming.outputs.vnet
    sourceVnetConfig: sourceNetworkConfig
  }
}]

