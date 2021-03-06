#!/bin/bash -x

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

[[ -z $1 ]] && { echo "Error: s3://<Source> is required"; exit 1; }
[[ -z $2 ]] && { echo "Error: s3://<Destination> is required"; exit 1; }
[[ -z "$3" ]] && { echo "Error: KMS Key Arn is required"; exit 1; }
[[ -z "$4" ]] && { echo "Error: S3 Cannoical Id is required"; exit 1; }


aws s3 cp "$1" - | tee >(md5sum | cut -d ' ' -f1 > /tmp/MD5.result) >(sha1sum | cut -d ' ' -f1 > /tmp/SHA1.result) >(sha256sum | cut -d ' ' -f1 > /tmp/SHA256.result) >(sha512sum | cut -d ' ' -f1 > /tmp/SHA512.result) > /dev/null

aws s3 cp "$1" "$2" --copy-props metadata-directive --metadata-directive REPLACE --sse aws:kms --sse-kms-key-id $3 --grants read=id=$4 --metadata Content-MD5=$(cat /tmp/MD5.result),Content-SHA1=$(cat /tmp/SHA1.result),Content-SHA256=$(cat /tmp/SHA256.result),Content-SHA512=$(cat /tmp/SHA512.result)
