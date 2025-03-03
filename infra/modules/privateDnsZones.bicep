param privateDNSZoneName string
param vNetId string

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: privateDNSZoneName
  location: 'global'
  properties: {}
}

resource privateDNSZoneARecord 'Microsoft.Network/privateDnsZones/A@2024-06-01' = {
  parent: privateDNSZone
  name: '${privateDNSZoneName}_A_Record'
  properties: {
    metadata: {
      creator: 'created by private endpoint pe-nesic-6vthaa with resource guid 0592c891-3a39-472b-ae58-52adc3010c77'
    }
    ttl: 10
    aRecords: [
      {
        ipv4Address: '172.16.0.36'
      }
    ]
  }
}

resource privateDNSZoneSOARecord 'Microsoft.Network/privateDnsZones/SOA@2024-06-01' = {
  parent: privateDNSZone
  name: '@'
  properties: {
    ttl: 3600
    soaRecord: {
      email: 'azureprivatedns-host.microsoft.com'
      expireTime: 2419200
      host: 'azureprivatedns.net'
      minimumTtl: 10
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
  }
}

resource privateDNSZoneVNetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: privateDNSZone
  name: '${privateDNSZoneName}_VNetLink'
  location: 'global'
  properties: {
    registrationEnabled: false
    resolutionPolicy: 'Default'
    virtualNetwork: {
      id: vNetId
    }
  }
}

output privateDnsZoneId string = privateDNSZone.id
