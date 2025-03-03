param location string
param privateEndpointName string
param privateDnsZoneId string
param privateLinkServiceId string // accounts_aoai_6vthaa_name_resource.id
param subNetId string // virtualNetworks_vn_6vthaa_name_subnet_pe.id

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        // id: '${privateEndpoint.id}/privateLinkServiceConnections/${privateEndpointName}'
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            'account'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${privateEndpointName}-nic'
    subnet: {
      id: subNetId
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource privateEndpointName_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-03-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-openai-azure-com'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
