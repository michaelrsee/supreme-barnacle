param nsgName string
param nsgLocation string


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: nsgLocation
  properties: {}   
}

output nsgID string = nsg.id
