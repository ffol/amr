targetScope = 'subscription'

@description('Name of the existing resource group where Azure Managed Redis and Private Endpoint are deployed.')
param resourceGroupName string

@description('Name of the Azure Managed Redis cluster.')
@minLength(1)
@maxLength(63)
param redisClusterName string

@description('Name of the Redis database. Keep default unless a different database name is required.')
param redisDatabaseName string = 'default'

@description('Subnet resource ID where the Private Endpoint NIC is created.')
param privateEndpointSubnetResourceId string

@description('Resource ID of the existing private DNS zone used for Azure Managed Redis private endpoint resolution (can be in a central hub subscription).')
param privateDnsZoneResourceId string

@description('Microsoft Entra object ID (GUID) of the user to assign as the default Redis data access administrator.')
param entraAdminObjectId string

@description('Versioned Key Vault key URI for CMK encryption (example: https://kv-name.vault.azure.net/keys/key-name/key-version).')
param cmkKeyEncryptionKeyUrl string

@description('Resource ID of an existing user-assigned managed identity that has access to the CMK in Key Vault.')
param cmkUserAssignedIdentityResourceId string

@description('Name of the private endpoint resource.')
param privateEndpointName string

@description('Name of the private DNS zone group attached to the private endpoint.')
param privateDnsZoneGroupName string = 'default'

@description('Private Link group ID for Azure Managed Redis.')
param privateLinkGroupId string = 'redisEnterprise'

resource targetRg 'Microsoft.Resources/resourceGroups@2024-11-01' existing = {
  name: resourceGroupName
}

module redisRgDeployment './redis.rg.bicep' = {
  scope: targetRg
  params: {
    redisClusterName: redisClusterName
    redisDatabaseName: redisDatabaseName
    privateEndpointSubnetResourceId: privateEndpointSubnetResourceId
    privateDnsZoneResourceId: privateDnsZoneResourceId
    entraAdminObjectId: entraAdminObjectId
    cmkKeyEncryptionKeyUrl: cmkKeyEncryptionKeyUrl
    cmkUserAssignedIdentityResourceId: cmkUserAssignedIdentityResourceId
    privateEndpointName: privateEndpointName
    privateDnsZoneGroupName: privateDnsZoneGroupName
    privateLinkGroupId: privateLinkGroupId
  }
}

output redisClusterResourceId string = redisRgDeployment.outputs.redisClusterResourceId
output redisDatabaseResourceId string = redisRgDeployment.outputs.redisDatabaseResourceId
output privateEndpointResourceId string = redisRgDeployment.outputs.privateEndpointResourceId
