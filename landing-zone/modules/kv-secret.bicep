param vaultName string
param secretName string

@secure()
param secretValue string

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName

  resource secret 'secrets' = {
    name: secretName
    properties: {
      value: secretValue
    }
  }
}
