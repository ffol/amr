using './main.bicep'

var workloadSubscriptionId = '00000000-0000-0000-0000-000000000000'
var hubSubscriptionId = '00000000-0000-0000-0000-000000000000'

var workloadResourceGroupName = 'rg-workload-example'
var hubResourceGroupName = 'rg-hub-example'

var vnetName = 'vnet-example'
var subnetName = 'snet-private-endpoints'

var redisName = 'amr-dev-001'

var privateEndpointPrefix = 'pep'

var keyVaultName = 'kv-example'
var cmkKeyName = 'key-redis-example'
var cmkKeyVersion = '00000000000000000000000000000000'
var cmkUMI = 'uai-redis-cmk-example'

param entraAdminObjectId = '11111111-1111-1111-1111-111111111111'

param resourceGroupName = workloadResourceGroupName
param redisClusterName = redisName
param privateEndpointName = '${privateEndpointPrefix}-${redisClusterName}'

// Replace with a valid subnet resource ID for private endpoint placement.
param privateEndpointSubnetResourceId = '/subscriptions/${workloadSubscriptionId}/resourceGroups/${workloadResourceGroupName}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${subnetName}'

// Existing centralized private DNS zone resource ID (hub subscription supported).
param privateDnsZoneResourceId = '/subscriptions/${hubSubscriptionId}/resourceGroups/${hubResourceGroupName}/providers/Microsoft.Network/privateDnsZones/privatelink.redis.azure.net'


// Existing Key Vault key URI (versioned URI is required for CMK).
param cmkKeyEncryptionKeyUrl = 'https://${keyVaultName}.vault.azure.net/keys/${cmkKeyName}/${cmkKeyVersion}'

// Existing user-assigned managed identity with key permissions.
param cmkUserAssignedIdentityResourceId = '/subscriptions/${workloadSubscriptionId}/resourceGroups/${workloadResourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${cmkUMI}'
