param vnetLocation string
param vnet1Name string 
param vnetInstanceNumber string
param nsgID string
param nsgBastionID string



var vnet1Config = {
  addressSpace1Prefix: '10.0.0.0/16'
  subnet1Name: 'snet-gateway-corehub-${vnetLocation}-${vnetInstanceNumber}'
  subnet1Prefix: '10.0.0.0/27'
  subnet2Name: 'AzureFirewallSubnet'
  subnet2Prefix: '10.0.10.0/26'
  subnet3Name: 'AzureBastionSubnet'
  subnet3Prefix: '10.0.20.0/26'
}

/*
var vnet2Config = {
  addressSpacePrefix: '10.40.0.0/16'
  subnet1Name: 'snet-web-prod-${vnetLocation}-${vnetInstanceNumber}'
  subnet1Prefix: '10.40.10.0/24'
  subnet2Name: 'snet-database-prod-${vnetLocation}-${vnetInstanceNumber}'
  subnet2Prefix: '10.40.20.0/24'
}

var vnet3Config = {
  addressSpacePrefix: '10.20.0.0/16'
  subnet1Name: 'snet-web-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet1Prefix: '10.20.10.0/24'
  subnet2Name: 'snet-database-dev-${vnetLocation}-${vnetInstanceNumber}'
  subnet2Prefix: '10.20.20.0/24'
}
*/

resource vnet1 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet1Name
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet1Config.addressSpace1Prefix
      ]
    }
    subnets: [
      {
        name: vnet1Config.subnet1Name
        properties: {
          addressPrefix: vnet1Config.subnet1Prefix
          networkSecurityGroup: nsgID == '' ? null : {
            id:nsgID
          }
        }
      }
      {
        name: vnet1Config.subnet2Name
        properties: {
          addressPrefix: vnet1Config.subnet2Prefix
          //networkSecurityGroup: nsgID == '' ? null : {
            //id:nsgID
          //}
        }
      }
      {
        name: vnet1Config.subnet3Name
        properties: {
          addressPrefix: vnet1Config.subnet3Prefix
          networkSecurityGroup: nsgBastionID == '' ? null : {
            id:nsgBastionID
          }
        }
      }
    ]
  }
  resource azureFirewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }
}

/*
resource VnetPeering1 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet1
  name: '${vnet1Name}-TO-${vnet2Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet2.id
    }
  }
}

resource vnet2 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnet2Name
  location: vnetLocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet2Config.addressSpacePrefix
      ]
    }
    subnets: [
      {
        name: vnet2Config.subnet1Name
        properties: {
          addressPrefix: vnet2Config.subnet1Prefix
          networkSecurityGroup: nsgID1 == '' ? null : {
            id:nsgID1
          }
        }
      }
      {
        name: vnet2Config.subnet2Name
        properties: {
          addressPrefix: vnet2Config.subnet2Prefix
          networkSecurityGroup: nsgID1 == '' ? null : {
            id:nsgID1
          }
        }
      }
    ]
  }
}

resource vnetPeering2 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet2
  name: '${vnet2Name}-TO-${vnet1Name}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: vnet1.id
    }
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
          networkSecurityGroup: nsgID2 == '' ? null : {
            id:nsgID2
          }
        }
      }
      {
        name: vnet3Config.subnet2Name
        properties: {
          addressPrefix: vnet3Config.subnet2Prefix
          networkSecurityGroup: nsgID2 == '' ? null : {
            id:nsgID2
          }
        }
      }
    ]
  }
}

resource vnetPeering3 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-05-01' = {
  parent: vnet1
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
      id: vnet1.id
    }
  }
}
*/

//output prodVnet1Subnet1 string = vnet2Config.subnet1Name
output coreVnet1Subnet3Prefix string = vnet1Config.subnet3Prefix

