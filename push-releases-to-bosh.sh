#!/bin/sh

for f in releases/*.tgz; do bosh upload release $f --skip-if-exists; done
