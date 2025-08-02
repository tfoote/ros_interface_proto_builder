#!/bin/bash

# Run this in rocker --home --user

set -e
set -x

TARGET_PACKAGES="common_interfaces control_msgs pcl_msgs tf2_msgs"


echo ROS_DISTRO: ${ROS_DISTRO:?is_unset}

mkdir -p ${ROS_DISTRO}_ws/src

# get all of rosdistro and msg packages
rosinstall_generator --rosdistro ${ROS_DISTRO} --upstream-devel --format repos ${TARGET_PACKAGES} --deps > ${ROS_DISTRO}_ws/upstream.repos
vcs import --input ${ROS_DISTRO}_ws/upstream.repos ${ROS_DISTRO}_ws/src --skip-existing


#proto specific content
vcs import --input ${ROS_DISTRO}_proto.repos ${ROS_DISTRO}_ws/src --force

sudo rosdep init || true
rosdep update


cd ${ROS_DISTRO}_ws
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

colcon build --event-handlers=console_direct+ --cmake-args='-DBUILD_TESTING=OFF' --packages-up-to $TARGET_PACKAGES


