#!/bin/bash
. common.sh

### START THE PROCESS NOW ###
azure account list --json | tee -a azure.txt > output.txt
SUBSCRIPTION_ID=`cat output.txt | grep "id" | head -1 | cut -d ":" -f2 | cut -d "," -f1 | cut -d " " -f2 | cut -d '"' -f2`
TENANT_ID=`cat output.txt | grep "tenantId" | head -1 | cut -d ":" -f2 | cut -d "," -f1 | cut -d " " -f2 | cut -d '"' -f2`

azure account set "$SUBSCRIPTION_ID" | tee -a azure.txt

azure ad app create --name "$CPI_NAME" --password "$CLIENT_SECERT" --identifier-uris "$CPI_URL" --home-page "$CPI_URL" | tee -a azure.txt > output.txt
APP_ID=`cat output.txt | grep AppId | cut -d ":" -f3 | tr -s " " | cut -d " " -f2`

azure ad sp create "$APP_ID" | tee -a azure.txt

## FIX THIS.. there is tenant id showing up here.... not sure what's wrong here
azure role assignment create --roleName "Contributor" --spn "$CPI_URL" --subscription "$SUBSCRIPTION_ID" | tee -a azure.txt

azure group create --name "$RES_GRP_NAME" --location "$LOCATION" | tee -a azure.txt
azure group show --name "$RES_GRP_NAME" | tee -a azure.txt
azure network vnet create --name "$VNET_NAME" --address-prefixes "$VNET_PREFIX" --resource-group "$RES_GRP_NAME" --location "$LOCATION" | tee -a azure.txt
azure network vnet subnet create --name "$SUBNET_NAME" --address-prefix "$SUBNET_PREFIX" --vnet-name "$VNET_NAME" --resource-group "$RES_GRP_NAME" | tee -a azure.txt
azure storage account create "$DEFAULT_STORAGE_NAME" --resource-group "$RES_GRP_NAME" --type "$STORAGE_TYPE" --location "$LOCATION" | tee -a azure.txt
azure storage account show "$DEFAULT_STORAGE_NAME" --resource-group "$RES_GRP_NAME" | tee -a azure.txt
azure storage account keys list "$DEFAULT_STORAGE_NAME" --resource-group "$RES_GRP_NAME" | tee -a azure.txt > output.txt

ACCOUNT_KEY=`cat output.txt | grep Primary | cut -d ":" -f3 | tr -s " " | cut -d " " -f2`

azure storage container create --container bosh  --account-name "$DEFAULT_STORAGE_NAME" --account-key "$ACCOUNT_KEY" | tee -a azure.txt
azure storage container create --container stemcell --account-name "$DEFAULT_STORAGE_NAME" --account-key "$ACCOUNT_KEY" --permission Blob | tee -a azure.txt
azure storage container list --account-name "$DEFAULT_STORAGE_NAME" --account-key "$ACCOUNT_KEY" | tee -a azure.txt
azure storage table create --table stemcells --account-name "$DEFAULT_STORAGE_NAME" --account-key "$ACCOUNT_KEY" | tee -a azure.txt
azure storage table list --account-name "$DEFAULT_STORAGE_NAME" --account-key "$ACCOUNT_KEY" | tee -a azure.txt
azure network public-ip create --name "$BOSH_PUBLIC_IP_NAME" --allocation-method Static --resource-group "$RES_GRP_NAME" --location "$LOCATION" | tee -a azure.txt > output.txt
BOSH_PUBLIC_IP=`cat output.txt | grep "IP Address" | cut -d ":" -f3 | cut -d " " -f2`

### Prepare for CF deployment
azure network public-ip create --name $CF_PUBLIC_IP_NAME --allocation-method Static --resource-group "$RES_GRP_NAME" --location "$LOCATION" | tee -a azure.txt > output.txt
CF_PUBLIC_IP=`cat output.txt | grep "IP Address" | cut -d ":" -f3 | cut -d " " -f2`

azure network dns zone create --resource-group "$RES_GRP_NAME" --name sys.$DOMAIN | tee -a azure.txt
azure network dns zone create --resource-group "$RES_GRP_NAME" --name cfapps.$DOMAIN | tee -a azure.txt
azure network dns record-set create --resource-group "$RES_GRP_NAME" --dns-zone-name sys.$DOMAIN --name "*" --type A --ttl 3600 | tee -a azure.txt
azure network dns record-set create --resource-group "$RES_GRP_NAME" --dns-zone-name cfapps.$DOMAIN --name "*" --type A --ttl 3600 | tee -a azure.txt
azure network dns record-set add-record --resource-group "$RES_GRP_NAME" --dns-zone-name sys.$DOMAIN --record-set-name "*" --type A --ipv4-address "$CF_PUBLIC_IP" | tee -a azure.txt
azure network dns record-set add-record --resource-group "$RES_GRP_NAME" --dns-zone-name cfapps.$DOMAIN --record-set-name "*" --type A --ipv4-address "$CF_PUBLIC_IP" | tee -a azure.txt
azure network dns record-set show --resource-group "$RES_GRP_NAME" --dns-zone-name sys.$DOMAIN --name "@" --type NS | tee -a azure.txt
azure network dns record-set show --resource-group "$RES_GRP_NAME" --dns-zone-name cfapps.$DOMAIN --name "@" --type NS | tee -a azure.txt
azure network vnet subnet create --name "$CF_SUBNET_NAME" --address-prefix "$CF_SUBNET_PREFIX" --vnet-name "$VNET_NAME" --resource-group "$RES_GRP_NAME" | tee -a azure.txt

echo "virtual_network_name - $VNET_NAME"
echo "subnet_name - $SUBNET_NAME"
echo "subscription_id - $SUBSCRIPTION_ID"
echo "tenant_id - $TENANT_ID"
echo "client_id - $APP_ID"
echo "client_secret - $CLIENT_SECERT"
echo "resource_group_name - $RES_GRP_NAME"
echo "storage_account_name - $DEFAULT_STORAGE_NAME"
echo "storage_access_key - $ACCOUNT_KEY"
echo "bosh public ip - $BOSH_PUBLIC_IP"
echo "cf public ip - $CF_PUBLIC_IP"
