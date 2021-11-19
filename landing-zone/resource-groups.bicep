targetScope = 'subscription'

// read in the resource group config file
var groups = json(loadTextContent('./config/resource-groups.json')).resourceGroups

// create the resource groups
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = [for item in groups: {
  name: item.name
  location: item.location
  tags: contains(item, 'tags') ? item.tags : {}
}]
