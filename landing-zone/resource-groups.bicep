targetScope = 'subscription'

// read in the resource group config file
var groups = json(loadTextContent('./config/resource-groups.json')).resourceGroups

// create the resource groups
module rgs 'modules/resource-group.bicep' = [for item in groups: {
  scope: subscription(contains(item, 'subscriptionId') ? item.subscriptionId : subscription().subscriptionId)
  name: item.name
  params: {
    name: item.name
    location: item.location
    tags: contains(item, 'tags') ? item.tags : {}
  }
}]
