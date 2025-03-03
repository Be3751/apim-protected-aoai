param location string
param virtualNetworkName string
param subnetMainName string
param subnetPeName string
param nsgMainId string
param nsgPeId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.16.0.0/26'
      ]
    }
    privateEndpointVNetPolicies: 'Disabled'
    dhcpOptions: {
      dnsServers: []
    }
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource subnetMain 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  parent: virtualNetwork
  name: subnetMainName
  properties: {
    addressPrefix: '172.16.0.0/27'
    networkSecurityGroup: {
      id: nsgMainId
    }
    serviceEndpoints: [
      {
        service: 'Microsoft.CognitiveServices'
        locations: [
          '*'
        ]
      }
    ]
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        // id: '${subnetMain.id}/delegations/Microsoft.Web.serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource subnetPrivateEndpoint 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  parent: virtualNetwork
  name: subnetPeName
  properties: {
    addressPrefix: '172.16.0.32/27'
    networkSecurityGroup: {
      id: nsgPeId
    }
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output subNetMainId string = subnetMain.id
output subNetPeId string = subnetPrivateEndpoint.id
