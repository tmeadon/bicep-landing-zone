targetScope = 'subscription'

// pass the admin password for any VMs in securely
@secure()
param vmAdminPassword string

// read in our core and environments config files
var resources = json(loadTextContent('config/core.json')).resources
var environments = json(loadTextContent('config/environments.json')).environments
var networks = json(loadTextContent('config/networking.json')).networks

// deploy resources with dependants first
module dependees 'modules/core-resource.bicep' = [for (item, index) in items(resources): if (item.value.type == 'keyVault') {
  scope: resourceGroup(item.value.resourceGroup)
  name: 'dependees-${index}-${item.key}'
  params: {
    resources: resources
    resourceRef: item.key
    environments: environments
    networks: networks
    vmAdminPassword: vmAdminPassword
  }
}]

// deploy the core resources which depend on those deployed above
module dependants 'modules/core-resource.bicep' = [for (item, index) in items(resources): if (item.value.type != 'keyVault') {
  scope: resourceGroup(item.value.resourceGroup)
  name: 'dependants-${index}-${item.key}'
  params: {
    resources: resources
    resourceRef: item.key
    environments: environments
    networks: networks
    vmAdminPassword: vmAdminPassword
  }
  dependsOn: [
    dependees
  ]
}]
