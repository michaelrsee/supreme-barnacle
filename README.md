# supreme-barnacle
Azure Sandbox Infrastructure deployed using Azure Bicep

**This is a work in progress and not complete. 

Constructions Steps:
1. Configure Hub-Spoke network configuration
   - Hub vnet will contain Azure Firewall Subnet and Azure Bastion Subnet. - Done
   - A Network Security Group will deployed on the Azure Bastion subnet, with Bastion specific NSG configuration. - Done
   - Deploy Azure Firewall in the AzureFirewallSubnet - Done. Turned off for Bastion validation testing.
   - Bastion NSG has to be deployed before Bastion - Done. Completed in build 0.0.6.
   - Firewall configuration complete.
   - Build 0.0.7 (May 15, 2022): 
     - Bastion deployment disabled. 
     - Firewall deployment enabled and was deployed successfully.
   - Build 0.0.8 (May 19,2022)
    - Add User Defined Route for Dev subnets to route all internet traffic to the firewall 
   - Build 0.0.9 (May 27, 2022)
     - module-spoke-prod.bicep deployment successful
   - Build 0.0.10 
     - To include VM and AKS cluster to the dev web subnet and PaaS Sql to the dev SQL subnet. 
     - Adding a conditional to not deploy the dev subnet for testing purposes. This will be reverted in another update. 

Network Layout 
![Network Diagram](/images/2022-05-27_21-05-33.png)
