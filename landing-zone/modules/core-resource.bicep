param resourceRef string
param resources object
param environments object
param networks object

@secure()
param vmAdminPassword string

// get the config for the specific resource we are deploying using the resourceRef parameter
var resourceConfig = resources[resourceRef]

// if the resource references a network then find that network in the list
var network = contains(resourceConfig.properties, 'vnetRef') ? networks[resourceConfig.properties.vnetRef] : null

// if the resource refernces a key vault then find that key vault resource config
var keyVault = contains(resourceConfig.properties, 'keyVaultRef') ? resources[resourceConfig.properties.keyVaultRef] : null

// generate naming
module naming 'naming.bicep' = {
  name: '${deployment().name}-resourceNaming'
  params: {
    namingComponents: environments[resourceConfig.environment].naming
  }
}

// if the network variable does not equal null then we need to generate naming for that network
module vnetNaming 'naming.bicep' = if (network != null) {
  name: '${deployment().name}-vnetNaming'
  params: {
    namingComponents: environments[network.environment].naming
  }
}

// if the key vault variable does not equal null then we need to generate naming for that key vault
module keyVaultNaming 'naming.bicep' = if (keyVault != null) {
  name: '${deployment().name}-vaultNaming'
  params: {
    namingComponents: environments[keyVault.environment].naming
  }
}

// deploy a log analytics workspace if required
module logWorkspace 'log-analytics.bicep' = if (resourceConfig.type == 'logAnalyticsWorkspace') {
  name: '${deployment().name}-log-analytics'
  params: {
    name: naming.outputs.logAnalyticsWorkspace
    location: resourceConfig.location
    sku: resourceConfig.properties.sku
    retentionInDays: resourceConfig.properties.retentionDays
  }
}

// deploy a key vault if required
module vault 'kv.bicep' = if (resourceConfig.type == 'keyVault') {
  name: '${deployment().name}-keyVault'
  params: {
    name: naming.outputs.keyVault
    location: resourceConfig.location
    enabledForDeployment: resourceConfig.properties.enabledForDeployment
    enabledForDiskEncryption: resourceConfig.properties.enabledForDiskEncryption
    enabledForTemplateDeployment: resourceConfig.properties.enabledForTemplateDeployment
    enableRbacAuthorization: resourceConfig.properties.enableRbacAuthorization
    sku: resourceConfig.properties.sku
    appendUniqueString: resourceConfig.properties.appendUniqueString
  }
}

// deploy a virtual machine if required
module vm 'vm.bicep' = if (resourceConfig.type == 'vm') {
  name: '${deployment().name}-vm'
  params: {
    name: '${naming.outputs.vm}${resourceConfig.nameSuffix}'
    location: resourceConfig.location
    vnetName: network != null ? vnetNaming.outputs.vnet : ''
    vnetResourceGroup: network.resourceGroup
    subnetName: resourceConfig.properties.subnetName
    size: resourceConfig.properties.size
    imageReference: resourceConfig.properties.imageReference
    osDiskSizeGb: resourceConfig.properties.osDiskSizeGb
    dataDisks: resourceConfig.properties.dataDisks
    adminUsername: resourceConfig.properties.adminUsername
    adminPassword: vmAdminPassword
    keyVaultName: keyVault != null ? keyVaultNaming.outputs.keyVault : ''
  }
}

