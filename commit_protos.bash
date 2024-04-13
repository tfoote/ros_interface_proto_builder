#!/bin/bash

# Run this in rocker --home --user

set -e

export DISTRO=iron

mkdir -p results

protos=$(find iron/install/*/include -name '*.proto')

git fetch origin
git checkout -b auto_update origin/generated_protos

# Set git config if unset
git config user.name || git config user.name "Automatic Update"
git config user.email || git config user.email "tullyfoote@intrinsic.ai"

for proto in $protos; do

    echo "Proto is at"
    echo $proto
    package=$(echo $proto | cut -d/ -f 3)
    echo $package
    result_dir=results/${DISTRO}/${package}/
    mkdir -p $result_dir
    cp $proto $result_dir

done


git add results
if git diff --cached --exit-code
then
    git commit -m"Updating protos for distro ${DISTRO}"
    git push origin auto_update:generated_protos
else
    echo "Nothing to commit, skipping commit and push"
fi
