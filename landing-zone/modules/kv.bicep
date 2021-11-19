param name string
param location string
param enabledForDeployment bool = true
param enabledForTemplateDeployment bool = true
param enabledForDiskEncryption bool = true
param enableRbacAuthorization bool = true
param appendUniqueString bool = true

@allowed([
  'premium'
  'standard'
])
param sku string = 'standard'

var suffix = take(uniqueString(resourceGroup().id, name), 5)
var vaultName = appendUniqueString ? '${name}-${suffix}' : name

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableRbacAuthorization: enableRbacAuthorization
    enablePurgeProtection: true
    softDeleteRetentionInDays: 90
    enableSoftDelete: true
    tenantId: tenant().tenantId
  }
}
