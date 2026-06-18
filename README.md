Pre-requisites:

Dns zone to be available on connectivity sub: **privatelink.redis.azure.net**
Resource providers to be registered at subcription level

```powershell
az provider register --namespace "Microsoft.cache"
```

make sure the resource provider is registered
```powershell
az provider show -n Microsoft.Cache --query "registrationState"
```

Deployment:

```powershell
$name = "amr-" + (Get-Date -Format "yyyyMMddHHmmss")
$location = "uaenorth"
az deployment sub create --name $name --location $location --template-file ./main.bicep --parameters ./main.bicepparam
```
