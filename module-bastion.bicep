@description('Name of existing vnet to which Azure Bastion should be deployed')
param vnetName string 

@description('Specify whether to provision new vnet or deploy to existing vnet')
@allowed([
  'new'
  'existing'
])
param vnetNewOrExisting string = 'existing'

@description('Name of Azure Bastion resource')
param bastionHostName string = 'sandboxBastion'

@description('Target Azure Resource Group')
param resourceGroup object

@description('Azure region for Bastion and virtual network')
param location string = resourceGroup.location

@description('Existing Bastion Subnet to deploy to')
param bastionSubnetIpPrefix string

@description('Existing Bastion subnet NSG')
param nsgBastionID string


var publicIpAddressName = 'pip-${bastionHostName}'
var bastionSubnetName = 'AzureBastionSubnet'


resource publicIp 'Microsoft.Network/publicIpAddresses@2020-05-01' = {
  name: publicIpAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}


// if vnetNewOrExisting == 'existing', reference an existing vnet and create a new subnet under it
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = if (vnetNewOrExisting == 'existing') {
  name: vnetName
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-05-01' = if (vnetNewOrExisting == 'existing') {
  parent: existingVirtualNetwork
  name: bastionSubnetName
  properties: {
    addressPrefix: bastionSubnetIpPrefix
    networkSecurityGroup:nsgBastionID =='' ? null : {
      id:nsgBastionID
    }
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-05-01' = {
  name: bastionHostName
  location: location
  dependsOn: [
    //newVirtualNetwork
    existingVirtualNetwork
  ]
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}
