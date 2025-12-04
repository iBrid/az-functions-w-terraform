# az-functions-w-terraform
An azure function that requests a URL, generates the QRCode for the URL and stores the QRCode in Azure Storage.

## What this project includes
- Terraform to provision a resource group, storage account, blob container, an App Service plan and a Function App.
- A Python Azure Function (`function/GenerateQrFunction`) that accepts a `url` (query or JSON body), generates a PNG QR code, uploads it to the configured blob container, and returns the blob name and URL.

## Prerequisites
- Azure CLI logged in and subscription selected
- Terraform
- Python 3.8+ and `pip`
- Azure Functions Core Tools (for local testing or publishing)

## Deploy (high level)
1. Update `variables.tf` or set Terraform variables for names, location, and tags.
2. Run:

```powershell
terraform init
terraform apply -auto-approve
```

3. Build and publish the function code. Two common approaches:

- Using Azure Functions Core Tools (recommended for dev):

```powershell
cd function
pip install -r requirements.txt --target=".python_packages/lib/site-packages"
func azure functionapp publish <FUNCTION_APP_NAME>
```

- Or build a zip of the function app and deploy via your CI pipeline or `az` commands.

Note: Terraform added `AzureWebJobsStorage` and `AZURE_STORAGE_CONNECTION_STRING` app settings for the Function App using the storage account created by Terraform. The container name is set from variable `storage_container_name` and is available in app setting `QR_CONTAINER`.

## Invoke the function
Once the function is deployed, call the HTTP trigger (replace host and key accordingly):

```powershell
# GET with query param
curl "https://<FUNCTION_APP>.azurewebsites.net/api/GenerateQrFunction?url=https://example.com&code=<function_key>"

# POST with JSON body
curl -H "Content-Type: application/json" -d '{"url":"https://example.com"}' "https://<FUNCTION_APP>.azurewebsites.net/api/GenerateQrFunction?code=<function_key>"
```

The function returns JSON with `blob_name` and `blob_url`. The blob is uploaded to the storage account/container created by Terraform.

## Local testing
- Copy `function/local.settings.json.template` to `function/local.settings.json` and fill in `AzureWebJobsStorage` / `AZURE_STORAGE_CONNECTION_STRING` with your storage account connection string.
- From the `function` folder run `func start` to test locally.

