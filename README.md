# supreme-barnacle
Azure Sandbox Infrastructure deployed using Azure Bicep

Constructions Steps:
1. Configure Hub-Spoke network configuration
   - Hub vnet will contain Azure Firewall Subnet and Azure Bastion Subnet. - Done
   - A Network Security Group will deployed on the Azure Bastion subnet, with Bastion specific NSG configuration. - Done
   - Deploy Azure Firewall in the AzureFirewallSubnet - Done