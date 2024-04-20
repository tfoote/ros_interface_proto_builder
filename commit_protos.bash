#!/bin/bash

# Run this in rocker --home --user

set -e
set -x

mkdir -p results

msg_protos=$(find ${ROS_DISTRO}/install/*/include/*/msg/* -name '*.proto')

git fetch origin
git checkout -b auto_update origin/generated_protos

# Set git config if unset
git config user.name || git config user.name "Automatic Update"
git config user.email || git config user.email "tullyfoote@intrinsic.ai"

for proto in $msg_protos; do

    echo "Proto is at"
    echo $proto
    package=$(echo $proto | cut -d/ -f 3)
    echo $package
    result_dir=results/${ROS_DISTRO}/${package}/
    mkdir -p $result_dir
    cp $proto $result_dir

done

echo "Git adding results directory"
git add results
if ! git diff --cached --exit-code
then
    git commit -m"Updating protos for distro ${ROS_DISTRO}"
else
    echo "Nothing to commit, skipping commit and push"
fi
