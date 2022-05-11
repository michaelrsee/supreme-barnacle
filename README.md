# supreme-barnacle
Azure Sandbox Infrastructure deployed using Azure Bicep

Constructions Steps:
1. Configure Hub-Spoke network configuration
   - Hub vnet will contain Azure Firewall Subnet, Gateway Subnet, and Azure Bastion Subnet.
   - A Network Security Group will deployed on the Azure Bastion subnet, with Bastion specific NSG configuration
   - Azure Firewall deployed in Azure Firewall Subnet, with basic application rule configured. 
   - 