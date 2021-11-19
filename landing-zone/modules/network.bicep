param networkConfig object
param environment object

// generate nomenclature
module naming 'naming.bicep' = {
  name: 'naming'
  params: {
    namingComponents: environment.naming
  }
}

// deploy vnet
module vnet 'vnet.bicep' = {
  name: '${resourceGroup().name}-vnet'
  params: {
    vnetConfig: networkConfig
    vnetName: naming.outputs.vnet
  }
}

// deploy bastion if required
var deployBastion = contains(networkConfig, 'deployBastion') ? networkConfig.deployBastion : false

module bastion 'bastion.bicep' = if (deployBastion) {
  name: '${resourceGroup().name}-bastion'
  params: {
    name: naming.outputs.bastion
    bastionPipName: naming.outputs.bastionPip
    location: networkConfig.location
    vnetName: vnet.outputs.vnetName
  }
}
