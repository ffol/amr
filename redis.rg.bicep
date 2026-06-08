targetScope = 'resourceGroup'

@description('Name of the Azure Managed Redis cluster.')
@minLength(1)
@maxLength(63)
param redisClusterName string

@description('Name of the Redis database.')
param redisDatabaseName string

@description('Subnet resource ID where the Private Endpoint NIC is created.')
param privateEndpointSubnetResourceId string

@description('Resource ID of the existing private DNS zone used for Azure Managed Redis private endpoint resolution (can be in a central hub subscription).')
param privateDnsZoneResourceId string

@description('Microsoft Entra object ID (GUID) of the user to assign as default Redis data access administrator.')
param entraAdminObjectId string

@description('Versioned Key Vault key URI for CMK encryption (example: https://kv-name.vault.azure.net/keys/key-name/key-version).')
param cmkKeyEncryptionKeyUrl string

@description('Resource ID of an existing user-assigned managed identity that has access to the CMK in Key Vault.')
param cmkUserAssignedIdentityResourceId string

@description('Name of the private endpoint resource.')
param privateEndpointName string

@description('Name of the private DNS zone group attached to the private endpoint.')
param privateDnsZoneGroupName string

@description('Private Link group ID for Azure Managed Redis.')
param privateLinkGroupId string

resource managedRedis 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  name: redisClusterName
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${cmkUserAssignedIdentityResourceId}': {}
    }
  }
  sku: {
    name: 'Balanced_B0'
  }
  properties: {
    highAvailability: 'Enabled'
    publicNetworkAccess: 'Disabled'
    minimumTlsVersion: '1.2'
    encryption: {
      customerManagedKeyEncryption: {
        keyEncryptionKeyUrl: cmkKeyEncryptionKeyUrl
        keyEncryptionKeyIdentity: {
          identityType: 'userAssignedIdentity'
          userAssignedIdentityResourceId: cmkUserAssignedIdentityResourceId
        }
      }
    }
  }
}

resource redisDatabase 'Microsoft.Cache/redisEnterprise/databases@2025-07-01' = {
  name: redisDatabaseName
  parent: managedRedis
  properties: {
    accessKeysAuthentication: 'Disabled'
    clientProtocol: 'Encrypted'
    clusteringPolicy: 'OSSCluster'
    modules: []
  }
}

resource redisDefaultEntraAdmin 'Microsoft.Cache/redisEnterprise/databases/accessPolicyAssignments@2025-07-01' = {
  name: 'defaultadmin'
  parent: redisDatabase
  properties: {
    accessPolicyName: 'default'
    user: {
      objectId: entraAdminObjectId
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-10-01' = {
  name: privateEndpointName
  location: resourceGroup().location
  properties: {
    subnet: {
      id: privateEndpointSubnetResourceId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-pls'
        properties: {
          privateLinkServiceId: managedRedis.id
          groupIds: [
            privateLinkGroupId
          ]
        }
      }
    ]
  }
}

resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-10-01' = {
  name: privateDnsZoneGroupName
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'redis-dns'
        properties: {
          privateDnsZoneId: privateDnsZoneResourceId
        }
      }
    ]
  }
}

output redisClusterResourceId string = managedRedis.id
output redisDatabaseResourceId string = redisDatabase.id
output privateEndpointResourceId string = privateEndpoint.id
