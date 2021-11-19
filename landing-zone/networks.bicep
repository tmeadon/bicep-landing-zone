targetScope = 'subscription'

// read in our network and environments config files
var networkConfigs = json(loadTextContent('config/networking.json')).networks
var environments = json(loadTextContent('config/environments.json')).environments

// convert the network configs object to an array so we can iterate over them
// (see https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-array#items) 
var networkConfigsArray = items(networkConfigs)

// deploy networks
module networks 'modules/network.bicep' = [for networkConfig in networkConfigsArray: {
  name: 'networks-${networkConfig.key}'
  scope: resourceGroup(networkConfig.value.resourceGroup)
  params: {
    networkConfig: networkConfig.value
    environment: environments[networkConfig.value.environment]
  }
}]

// deploy peerings for each network
module peerings 'modules/vnet-peerings/all_vnet_peerings.bicep' = [for networkConfig in networkConfigsArray: {
  name: 'peerings-${networkConfig.key}'
  scope: resourceGroup(networkConfig.value.resourceGroup)
  params: {
    networkConfigKey: networkConfig.key
    allNetworkConfigs: networkConfigs
    environments: environments
  }
  dependsOn: [
    networks
  ]
}]
