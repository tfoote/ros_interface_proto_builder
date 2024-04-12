#!/bin/bash

# Run this in rocker --home --user

set -e

export DISTRO=iron

mkdir -p results

protos=$(find iron/install/*/include -name '*.proto')

for proto in $protos; do

    echo "Proto is at"
    echo $proto
    package=$(echo $proto | cut -d/ -f 3)
    echo $package
    result_dir=results/${DISTRO}/${package}/
    mkdir -p $result_dir
    cp $proto $result_dir

done

git checkout generated_protos

# Set git config if unset
git config user.name || git config user.name "Automatic Update"
git config user.email || git config user.email "tullyfoote@intrinsic.ai"

git add results
git commit -m"Updating protos for distro ${DISTRO}"
git push
