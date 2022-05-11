/*

main.bicep

Author: Michael See
Date: 05/10/22

Description: Deploy a sandbox infrastructure in Azure. 

Usage (via Azure cli): 
az deployment sub create --template-file main.bicep --location eastus

*/

targetScope = 'subscription'

param namePrefix string = 'rg-sandbox-001'
param location string = 'eastus'

param vnetLocation string = 'eastus'
