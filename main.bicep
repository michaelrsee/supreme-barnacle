/*

main.bicep

Author: Michael See
Initial Commit Date: 05/10/22

Description: Deploy a sandbox infrastructure in Azure. 

Usage (via Azure cli): 
az deployment sub create --template-file main.bicep --location eastus

*/


targetScope = 'subscription'


/*** Params ***/
param namePrefix string = 'rg-sandbox-001'
param location string = 'eastus'
param InstanceNumber string = '001'

param vnetLocation string = 'eastus'
param vnet1Name string = 'vnet-hub-${vnetLocation}'
param vnet2Name string = 'vnet-prod-${vnetLocation}'
param vnet3Name string = 'vnet-dev-${vnetLocation}'

param nsg1Name string = 'nsg-hub-${vnetLocation}-${InstanceNumber}'
param nsg1Location string = 'eastus'
param nsg2Name string = 'nsg-prod-${vnetLocation}-${InstanceNumber}'
param nsg2Location string = 'eastus'
param nsg3Name string = 'nsg-dev-${vnetLocation}-${InstanceNumber}'
param nsg3Location string = 'eastus'
param nsgBastionName string = 'nsg-bastion-hub-${vnetLocation}-${InstanceNumber}'
param nsgBastionLocation string = 'eastus'


@description('Conditional to deploy Bastion')
param deployBastion bool = false

@description('Conditional to deploy firewall')
param deployFirewall bool = true

@description('Conditional to deploy the dev subnet')
param deployDevSubnet bool = false


/*** Resources ***/
resource rsgTest 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: namePrefix
  location: location
}

module nsg 'module-nsg.bicep' = {
  name:'nsg-module'
  scope:resourceGroup(rsgTest.name)
  params:{
    nsgName:nsg1Name
    nsgLocation:nsg1Location
  }
}

module nsgBastion 'module-nsg-bastion.bicep' = {
  name: 'nsg-bastion'
  scope:resourceGroup(rsgTest.name)
  params: {
    nsgName:nsgBastionName
    nsgLocation:nsgBastionLocation
  }
}

module hub 'hub.bicep' = {
  name:'hub'
  scope:resourceGroup(rsgTest.name)
  params:{
    vnetLocation:vnetLocation
    vnet1Name:vnet1Name
    vnetInstanceNumber:InstanceNumber
    nsgID: nsg.outputs.nsgID
    nsgBastionID:nsgBastion.outputs.bastionNsgID 
  }
}

module bastion 'module-bastion.bicep' = if (deployBastion) {
  name:'bastion'
  scope:resourceGroup(rsgTest.name)
  params:{
    vnetName:vnet1Name
    location:rsgTest.location
    resourceGroup:rsgTest
    bastionSubnetIpPrefix:hub.outputs.coreVnet1Subnet3Prefix
    nsgBastionID:nsgBastion.outputs.bastionNsgID
  }
}

module firewall 'module-firewall.bicep' = if (deployFirewall) {
  name:'firewall'
  scope:resourceGroup(rsgTest.name)
  params:{
    Location:rsgTest.location
    hub: vnet1Name
  }
}

// nsg for dev subnets 
module nsg2 'module-nsg.bicep' = {
  name:'nsg2-module'
  scope:resourceGroup(rsgTest.name)
  params:{
    nsgName:nsg3Name
    nsgLocation:nsg3Location
  }
}

module spokeDev 'module-spoke-dev.bicep' = if (deployDevSubnet) {
  name:'spokeDev'
  scope:resourceGroup(rsgTest.name)
  params:{
    vnetLocation:vnetLocation
    vnet3Name:vnet3Name
    vnetInstanceNumber:InstanceNumber
    nsgID:nsg2.outputs.nsgID
    vnet1Name:vnet1Name
    resourceGroup:rsgTest.name
    firewall:firewall.outputs.hubFireWalllName
  }
}

//nsg for prod subnets
module nsg3 'module-nsg.bicep' = {
  name:'nsg3-module'
  scope:resourceGroup(rsgTest.name)
  params:{
    nsgName:nsg2Name
    nsgLocation:nsg2Location
  }
}

module spokeProd 'module-spoke-prod.bicep' = {
  name:'spokeProd'
  scope:resourceGroup(rsgTest.name)
  params:{
    vnetLocation:vnetLocation
    vnet2Name:vnet2Name
    vnetInstanceNumber:InstanceNumber
    nsgID:nsg3.outputs.nsgID
    vnet1Name:vnet1Name
    resourceGroup:rsgTest.name
    firewall:firewall.outputs.hubFireWalllName
  }
}
