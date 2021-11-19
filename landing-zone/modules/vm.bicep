param name string
param location string
param vnetName string
param subnetName string
param vnetResourceGroup string = resourceGroup().name
param size string
param imageReference object
param osDiskSizeGb int = 128
param dataDisks array = []
param adminUsername string
param keyVaultName string = ''
param keyVaultResourceGroup string = resourceGroup().name
param keyVaultSubscriptionId string = subscription().subscriptionId

@secure()
param adminPassword string

var nicName = '${name}-nic'
var osDiskName = '${name}-os'
var diagStorageName = uniqueString(name, resourceGroup().id)
var adminPasswordSecretName = '${name}-adminPassword'
var adminUsernameSecretName = '${name}-adminUsername'

// get a reference to the subnet to connect to
resource vnet 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: vnetName
  scope: resourceGroup(vnetResourceGroup)

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

// create a key vault secret for the local admin username if a key vault was specified
module localAdminUsernameSecret 'kv-secret.bicep' = if (keyVaultName != '')  {
  name: 'localAdminUsernameSecret'
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroup)
  params: {
    vaultName: keyVaultName
    secretValue: adminUsername
    secretName: adminUsernameSecretName
  }
}

// create a key vault secret for the local admin password if a key vault was specified
module localAdminPasswordSecret 'kv-secret.bicep' = if (keyVaultName != '')  {
  name: 'localAdminPasswordSecret'
  scope: resourceGroup(keyVaultSubscriptionId, keyVaultResourceGroup)
  params: {
    vaultName: keyVaultName
    secretValue: adminPassword
    secretName: adminPasswordSecretName
  }
}


// create a nic
resource nic 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet::subnet.id
          }
        }
      }
    ]
  }
}

// create data disks
resource disks 'Microsoft.Compute/disks@2021-04-01' = [for (item, index) in dataDisks: {
  name: '${name}-data${index}'
  location: location
  sku: {
    name: item.sku
  }
  properties: {
    creationData: {
      createOption: 'Empty'
    }
    diskSizeGB: item.sizeGb
  }
}]

// create a storage account for boot diagnostics
resource stor 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: diagStorageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// create the vm
resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: size
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        name: osDiskName
        diskSizeGB: osDiskSizeGb
      }
      dataDisks: [for (item, index) in dataDisks: {
        managedDisk: {
          id: disks[index].id
        }
        createOption: 'Attach'
        lun: index
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: stor.properties.primaryEndpoints.blob
      }
    }
  }
}
