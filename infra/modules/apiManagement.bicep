param location string
param apiManagementName string
param subnetMainId string

resource apiManagement 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apiManagementName
  location: location
  sku: {
    name: 'StandardV2'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: 'masayasonobe@microsoft.com'
    publisherName: 'nesic-demo'
    notificationSenderEmail: 'apimgmt-noreply@mail.windowsazure.com'
    hostnameConfigurations: [
      {
        type: 'Proxy'
        hostName: '${apiManagementName}.azure-api.net'
        negotiateClientCertificate: false
        defaultSslBinding: true
        certificateSource: 'BuiltIn'
      }
    ]
    virtualNetworkConfiguration: {
      subnetResourceId: subnetMainId
    }
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
    }
    virtualNetworkType: 'External'
    natGatewayState: 'Enabled'
    apiVersionConstraint: {}
    publicNetworkAccess: 'Enabled'
    legacyPortalStatus: 'Disabled'
    developerPortalStatus: 'Disabled'
  }
}
