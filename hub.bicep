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


output coreVnet1Subnet3Prefix string = vnet1Config.subnet3Prefix

