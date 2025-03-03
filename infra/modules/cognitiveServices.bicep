param location string
param aoaiName string
param subnetMainId string

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: aoaiName
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    apiProperties: {}
    customSubDomainName: aoaiName
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      virtualNetworkRules: [
        {
          id: subnetMainId
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
      ipRules: []
    }
    publicNetworkAccess: 'Disabled'
  }
}

resource aoaiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: cognitiveService
  name: 'gpt-4o-mini'
  sku: {
    name: 'GlobalStandard'
    capacity: 250
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-10-01-preview'
    }
    versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    currentCapacity: 250
  }
}

resource aoaiPrivateEndpointConnection 'Microsoft.CognitiveServices/accounts/privateEndpointConnections@2024-10-01' = {
  parent: cognitiveService
  name: '${cognitiveService.name}PrivateEndpointConnection'
  location: location
  properties: {
    privateEndpoint: {}
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

output aoaiPrivateEndpointConnectionId string = aoaiPrivateEndpointConnection.id
