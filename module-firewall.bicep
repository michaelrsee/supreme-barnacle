param Location string
param hub string


resource vnet1 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name:hub
  
  resource azureFirewallSubnet 'subnets' existing = {
    name: 'AzureFirewallSubnet'
  }
}


// Allocate one IP addresses to the firewall
resource pipsAzureFirewall 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-fw-${Location}'
  location: Location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    publicIPAddressVersion: 'IPv4'
  }
}


// Azure Firewall starter policy
resource fwPolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: 'fw-policies-${Location}'
  location: Location
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Deny'
    threatIntelWhitelist: {
      fqdns: []
      ipAddresses: []
    }
    intrusionDetection: {
      mode: 'Deny'
      configuration: {
        bypassTrafficSettings: []
        signatureOverrides: []
      }
    }
    dnsSettings: {
      servers: []
      enableProxy: true
    }
  }

  // Network hub starts out with only supporting DNS. This is only being done for
  // simplicity in this deployment and is not guidance, please ensure all firewall
  // rules are aligned with your security standards.
  resource defaultNetworkRuleCollectionGroup 'ruleCollectionGroups@2021-05-01' = {
    name: 'DefaultNetworkRuleCollectionGroup'
    properties: {
      priority: 200
      ruleCollections: [
        {
          ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
          name: 'org-wide-allowed'
          priority: 100
          action: {
            type: 'Allow'
          }
          rules: [
            {
              ruleType: 'NetworkRule'
              name: 'DNS'
              description: 'Allow DNS outbound (for simplicity, adjust as needed)'
              ipProtocols: [
                'UDP'
              ]
              sourceAddresses: [
                '*'
              ]
              sourceIpGroups: []
              destinationAddresses: [
                '209.244.0.3,209.244.0.4'
              ]
              destinationIpGroups: []
              destinationFqdns: []
              destinationPorts: [
                '53'
              ]
            }
          ]
        }
      ]
    }
  }


// Network hub starts out with no allowances for appliction rules
resource defaultApplicationRuleCollectionGroup 'ruleCollectionGroups@2021-05-01' = {
  name: 'DefaultApplicationRuleCollectionGroup'
  dependsOn: [
    defaultNetworkRuleCollectionGroup
  ]
  properties: {
    priority: 300
    ruleCollections: [
      {
        name: 'App-Coll01'
        priority: 100
        ruleCollectionType:'FirewallPolicyFilterRuleCollection'
        action:{
          type:'Allow'
        }
        rules: [
          {
            ruleType:'ApplicationRule'
            name:'Google'
            description:'Allow google.com'
            destinationAddresses:[
              'www.google.com'
            ]
            protocols:[
              {
                protocolType:'Https'
                port:8080
              }
            ]
            sourceAddresses:[
              '*'
            ]
            //targetFqdns:[
              //'www.google.com'
            //]
            targetUrls:[
              'www.google.com'
            ]
            terminateTLS:true
          }
        ]
      }
    ]
  }
}
}

 // This is the regional Azure Firewall that all regional spoke networks can egress through.
resource hubFirewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'fw-${Location}'
  location: Location
  dependsOn: [
    // This helps prevent multiple PUT updates happening to the firewall causing a CONFLICT race condition
    // Ref: https://docs.microsoft.com/azure/firewall-manager/quick-firewall-policy
    fwPolicy::defaultApplicationRuleCollectionGroup
    fwPolicy::defaultNetworkRuleCollectionGroup
  ]
  properties: {
    sku: {
      tier: 'Premium'
      name: 'AZFW_VNet'
    }
    firewallPolicy: {
      id: fwPolicy.id
    }
    ipConfigurations: [
      {
      name: pipsAzureFirewall.name
      properties: {
        subnet: {
          id: vnet1::azureFirewallSubnet.id 
        } 
        publicIPAddress: {
          id: pipsAzureFirewall.id
        }
      }
    }
   ]
  }
}

output hubFireWalllName string = hubFirewall.name
