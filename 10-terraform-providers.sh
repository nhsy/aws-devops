#!/bin/bash
set -e

for version in 2.70.0 3.18.0 3.21.0
do
  echo "Downloading aws provider version: $version"
  wget -q https://releases.hashicorp.com/terraform-provider-aws/${version}/terraform-provider-aws_${version}_linux_amd64.zip
  unzip terraform-provider-aws_${version}_linux_amd64.zip -d ${TF_PLUGIN_CACHE_DIR}/linux_amd64
  rm terraform-provider-aws_${version}_linux_amd64.zip
done
