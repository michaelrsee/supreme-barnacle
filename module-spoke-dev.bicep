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
param resourceGroup string
param firewall string


var vnet3Config = {
  addressSpacePrefix: '10.20.0.0/16'
  subnet1Name: 'snet-web-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet1Prefix: '10.20.10.0/24'
  subnet2Name: 'snet-database-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet2Prefix: '10.20.20.0/24'
}

/*-- Existing Resources --*/
resource existingResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  scope:subscription()
  name:resourceGroup
}

 resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: vnet1Name
}

resource existingFirewall 'Microsoft.Network/azureFirewalls@2021-08-01' existing = {
  scope:existingResourceGroup
  name:firewall
}


/*--  Resources  --*/
// Next hop to the regional hub's Azure Firewall
resource routeNextHopToFirewall 'Microsoft.Network/routeTables@2021-05-01' = {
  name: 'route-to-${vnetLocation}-hub-fw'
  location: vnetLocation
  properties: {
    routes: [
      {
        name: 'r-nexthop-to-fw'
        properties: {
          nextHopType: 'VirtualAppliance'
          addressPrefix: '0.0.0.0/0'
          nextHopIpAddress: existingFirewall.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}


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
          routeTable:{
            id:routeNextHopToFirewall.id
          }
          networkSecurityGroup: nsgID == '' ? null : {
            id:nsgID
          }
        }
      }
      {
        name: vnet3Config.subnet2Name
        properties: {
          addressPrefix: vnet3Config.subnet2Prefix
          routeTable:{
            id:routeNextHopToFirewall.id
          }
          networkSecurityGroup: nsgID == '' ? null : {
            id:nsgID
          }
        }
      }
    ]
  }
}


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
