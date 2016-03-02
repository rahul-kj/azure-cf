#!/bin/bash
. common.sh

### Perform cleanup first
azure ad sp show --search "$CPI_NAME" > output.txt
OBJECT_ID=`cat output.txt | grep "Object Id" | cut -d ":" -f3 | tr -s " " | cut -d " " -f2`
azure ad sp delete --objectId "$OBJECT_ID"

azure ad app show --identifierUri "$CPI_URL" > output.txt
OBJECT_ID=`cat output.txt | grep "ObjectId" | cut -d ":" -f3 | tr -s " " | cut -d " " -f2`
azure ad app delete --objectId "$OBJECT_ID"
azure group delete "$RES_GRP_NAME"
