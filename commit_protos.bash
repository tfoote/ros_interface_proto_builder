#!/bin/bash

# Run this in rocker --home --user

set -e
set -x

mkdir -p ${ROS_DISTRO}

protos=$(find ${ROS_DISTRO}_ws/install/*/include/* -name '*.proto')

current_branch=$(git branch --show-current)
target_branch=${ROS_DISTRO}_generated

git branch -D ${target_branch} || true
git checkout --orphan ${target_branch}

# Set git config if unset
git config user.name || git config user.name "Automatic Update"
git config user.email || git config user.email "morganquigley@intrinsic.ai"

for proto in $protos; do

    echo "Proto is at"
    echo $proto
    package=$(echo $proto | cut -d/ -f 3)
    proto_type=$(echo $proto | cut -d/ -f 7)
    echo $package
    result_dir=${ROS_DISTRO}/${package}/${proto_type}
    mkdir -p $result_dir
    cp $proto $result_dir

done

package_dirs=$(colcon list -p)

for pd in $package_dirs; do
    license_file=$pd/LICENSE
    echo Trying License file: $license_file
    if ! [ -f $license_file ] ; then
        license_file=$(dirname $pd)/LICENSE
    fi
    if ! [ -f $license_file ] ; then
        echo NO license file at $license_file either, continuing
        continue
    fi
    package=$(basename $pd)
    result_dir=${ROS_DISTRO}/${package}/
    if [ -d $result_dir ] ; then
        cp $license_file $result_dir
    fi
done

echo "Git adding results directory: ${ROS_DISTRO}"
git add ${ROS_DISTRO} -f
if ! git diff --cached --exit-code
then
    git commit -m"Updating protos for distro ${ROS_DISTRO} in branch ${target_branch}"
else
    echo "Nothing to commit, skipping commit and push"
fi

git checkout ${current_branch}
