Pre-requisites:

Dns zone to be available on connectivity sub: **privatelink.redis.azure.net**

Deployment:

```powershell
$name = "amr-" + (Get-Date -Format "yyyyMMddHHmmss")
$location = uaenorth
az deployment sub create --name $name --location $location --template-file ./main.bicep --parameters ./main.bicepparam
```