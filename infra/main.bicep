param virtualNetworkName string
param applicationInsightsName string
param cognitiveServicesName string
param apiManagementName string
param privateEndpointName string
param networkSecurityGroupName string
param privateDnsZoneName string
param subnetNetworkSecurityGroupName string
param operationalInsightsWorkspaceName string
param smartDetectorAlertRuleName string
param actionGroupExternalId string

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string
var location = resourceGroup().location
var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

module networkSecurityGroups 'modules/networkSecurityGroups.bicep' = {
  name: 'networkSecurityGroupsModule'
  params: {
    location: location
    networkSecurityGroupsName: '${abbrs.networkNetworkSecurityGroups}main-${resourceToken}'
    networkSecurityGroupsSbntPeName: '${abbrs.networkNetworkSecurityGroups}pe-${resourceToken}'
  }
}

module privateDnsZones 'modules/privateDnsZones.bicep' = {
  name: 'privateDnsZoneModule'
  params: {
    privateDNSZoneName: '${abbrs.networkPrivateDnsZones}${resourceToken}'
    vNetId: virtualNetworkName
  }
}

module apiManagement 'modules/apiManagement.bicep' = {
  name: 'apiManagementModule'
  params: {
    location: location
    apiManagementName: '${abbrs.apiManagementService}${resourceToken}'
    subnetMainId: virtualNetworks.outputs.subNetMainId
  }
}

module cognitiveServices 'modules/cognitiveServices.bicep' = {
  name: 'cognitiveServicesModule'
  params: {
    location: location
    aoaiName: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    subnetMainId: virtualNetworks.outputs.subNetMainId
  }
}

module applicationInsights 'modules/insightsComponents.bicep' = {
  name: 'insightsComponentsModule'
  params: {
    location: location
    operationalInsightsWorkspaceName: operationalInsightsWorkspaceName
    applicationInsightsName: '${abbrs.insightsComponents}${resourceToken}'
  }
  dependsOn: [
    apiManagement
    cognitiveServices
  ]
}

module privateEndpoints 'modules/privateEndpoints.bicep' = {
  name: 'privateEndpointsModule'
  params: {
    location: location
    privateEndpointName: '${abbrs.networkPrivateEndpoints}${resourceToken}'
    privateDnsZoneId: privateDnsZones.outputs.privateDnsZoneId
    privateLinkServiceId: cognitiveServices.outputs.aoaiPrivateEndpointConnectionId
    subNetId: virtualNetworks.outputs.subNetPeId
  }
}

module virtualNetworks 'modules/virtualNetworks.bicep' = {
  name: 'virtualNetworksModule'
  params: {
    location: location
    virtualNetworkName: '${abbrs.networkVirtualNetworks}${resourceToken}'
    subnetMainName: 'main'
    subnetPeName: 'pe'
    nsgMainId: networkSecurityGroups.outputs.nsgMainId
    nsgPeId: networkSecurityGroups.outputs.nsgSbntPeId
  }
}
