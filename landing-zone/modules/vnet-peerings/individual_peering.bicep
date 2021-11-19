param sourceVnetName string
param remoteVnetId string
param sourceIsHub bool
param remoteIsHub bool
param remoteHasGateway bool

// get the target vnet's name
var remoteVnetName = last(split(remoteVnetId, '/'))

// use remote gateways if the source is not a hub and the remote is a hub and the remote has a gateway
var useRemoteGateways = !sourceIsHub && (remoteIsHub && remoteHasGateway) 

// allow gateway transit if the source is a hub and the target is not
var allowGatewayTransit = sourceIsHub && !remoteIsHub

// allow forwarded traffic if both the source and the remote are hubs
var allowForwardedTraffic = (sourceIsHub && remoteIsHub) || (!sourceIsHub && remoteIsHub)

// get a reference to the source vnet
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: sourceVnetName
}

// deploy the peering
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
  parent: vnet
  name: '${sourceVnetName}-to-${remoteVnetName}'
  properties: {
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    allowForwardedTraffic: allowForwardedTraffic
  }
}
