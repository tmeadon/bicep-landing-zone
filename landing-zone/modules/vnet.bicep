param vnetName string
param vnetConfig object

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: vnetConfig.location
  properties: {
    addressSpace: {
      addressPrefixes: vnetConfig.addressPrefixes
    }
    subnets: [for subnet in vnetConfig.subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
      }
    }]
  }
}

output vnetName string = vnet.name
