#!/bin/bash
PREFIX="rj"
CPI_NAME="$PREFIX Bosh CPI"
CPI_URL="http://$PREFIX-BoshAzureCPI"
CLIENT_SECERT="changeme"
RES_GRP_NAME="$PREFIX-bosh-res-group"
LOCATION="Central US"
VNET_NAME="$PREFIX-boshnet"
VNET_PREFIX="10.0.0.0/8"
SUBNET_NAME="$PREFIX-bosh"
SUBNET_PREFIX="10.0.0.0/24"
CF_SUBNET_NAME="$PREFIX-cf"
CF_SUBNET_PREFIX="10.0.16.0/22"
DEFAULT_STORAGE_NAME=$PREFIX"boshstore"
STORAGE_TYPE="GRS"
BOSH_PUBLIC_IP_NAME="$PREFIX-public-ip"
CF_PUBLIC_IP_NAME="$PREFIX-cf-public-ip"
DOMAIN="rj-test.io"

### LOGIN
azure config mode arm
azure login
