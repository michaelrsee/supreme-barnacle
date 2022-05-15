/*

nsg (one nsg associated to both subnets)
vnet
snet
peerings (1 to 3 and 3 to 1) test up to peerings first. Success.
udr applied to web snet - develop and test 


*/

param vnetLocation string
param vnet3Name string 
param vnetInstanceNumber string
param nsgID string
param vnet1Name string


var vnet3Config = {
  addressSpacePrefix: '10.20.0.0/16'
  subnet1Name: 'snet-web-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet1Prefix: '10.20.10.0/24'
  subnet2Name: 'snet-database-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet2Prefix: '10.20.20.0/24'
}

 // existing vnet1
 resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: vnet1Name
}


/*--  Resources  --*/
resource vnet3 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet3Name
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet3Config.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: vnet3Config.subnet1Name
        properties: {
          addressPrefix: vnet3Config.subnet1Prefix
          networkSecurityGroup: nsgID == '' ? null : {
            id:nsgID
          }
        }
      }
      {
        name: vnet3Config.subnet2Name
        properties: {
          addressPrefix: vnet3Config.subnet2Prefix
          networkSecurityGroup: nsgID == '' ? null : {
            id:nsgID
          }
        }
      }
    ]
  }
}

// could do an existing for vnet1 here
resource vnetPeering3 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: existingVirtualNetwork
  name: '${vnet1Name}-TO-${vnet3Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet3.id
    }
  }
}

resource vnetPeering4 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet3
  name: '${vnet3Name}-TO-${vnet1Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: existingVirtualNetwork.id
    }
  }
}
