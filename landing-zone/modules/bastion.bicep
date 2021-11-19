param name string
param bastionPipName string
param location string
param vnetName string
param vnetResourceGroup string = resourceGroup().name

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)

  resource subnet 'subnets' existing = {
    name: 'AzureBastionSubnet'
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: bastionPipName
  location: location
  sku: {
    name: 'Standard'
  }  
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: vnet::subnet.id
          }
        }
      }
    ]
  }
}
