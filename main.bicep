/*

main.bicep

Author: Michael See
Initial Commit Date: 05/10/22

Description: Deploy a sandbox infrastructure in Azure. 

Usage (via Azure cli): 
az deployment sub create --template-file main.bicep --location eastus

*/


targetScope = 'subscription'

param namePrefix string = 'rg-sandbox-001'
param location string = 'eastus'
param InstanceNumber string = '001'

param vnetLocation string = 'eastus'
param vnet1Name string = 'vnet-hub-${vnetLocation}'
//param vnet2Name string = 'vnet-prod-${vnetLocation}'
//param vnet3Name string = 'vnet-dev-${vnetLocation}'

param nsg1Name string = 'nsg-hub-${vnetLocation}-${InstanceNumber}'
param nsg1Location string = 'eastus'
//param nsg2Name string = 'nsg-prod-${vnetLocation}-${InstanceNumber}'
//param nsg2Location string = 'eastus'
//param nsg3Name string = 'nsg-dev-${vnetLocation}-${InstanceNumber}'
//param nsg3Location string = 'eastus'
param nsgBastionName string = 'nsg-bastion-corehub-${vnetLocation}-${InstanceNumber}'
param nsgBastionLocation string = 'eastus'


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

module bastion 'module-bastion.bicep' = {
  name:'bastion'
  scope:resourceGroup(rsgTest.name)
  params:{
    vnetName:vnet1Name
    location:rsgTest.location
    resourceGroup:rsgTest
    bastionSubnetIpPrefix:hub.outputs.coreVnet1Subnet3Prefix
  }
}
