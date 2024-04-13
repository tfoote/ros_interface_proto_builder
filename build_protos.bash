#!/bin/bash

# Run this in rocker --home --user

set -e

export DISTRO=iron
TARGET_PACKAGES="sensor_msgs geometry_msgs"

sudo apt-get update && sudo apt-get install -qy python3-rosinstall-generator python3-vcstool

mkdir -p ${DISTRO}/src

# get all of rosdistro and msg packages
rosinstall_generator --rosdistro ${DISTRO} --upstream-devel --format repos ${TARGET_PACKAGES} --deps > ${DISTRO}_upstream.repos
vcs import --input ${DISTRO}_upstream.repos ${DISTRO}/src --skip-existing


#proto specific content
vcs import --input ${DISTRO}_proto.repos ${DISTRO}/src --force

sudo rosdep init || true
rosdep update


cd ${DISTRO}
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

colcon build --event-handlers=console_direct+ --cmake-args='-DBUILD_TESTING=OFF'


