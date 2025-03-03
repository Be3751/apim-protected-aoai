param location string
param networkSecurityGroupsName string
param networkSecurityGroupsSbntPeName string

resource networkSecurityGroupsSubnetMain 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: networkSecurityGroupsName
  location: location
  properties: {
    securityRules: []
  }
}

resource networkSecurityGroupsSubnetPe 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: networkSecurityGroupsSbntPeName
  location: location
  properties: {
    securityRules: []
  }
}

output nsgMainId string = networkSecurityGroupsSubnetMain.id
output nsgSbntPeId string = networkSecurityGroupsSubnetPe.id
