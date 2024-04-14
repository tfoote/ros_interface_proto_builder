#!/bin/bash

# Run this in rocker --home --user

set -e
set -x

TARGET_PACKAGES="common_interfaces can_msgs aruco_msgs control_msgs pcl_msgs"

sudo apt-get update && sudo apt-get install -qy python3-rosinstall-generator python3-vcstool

mkdir -p ${ROS_DISTRO}/src

# get all of rosdistro and msg packages
rosinstall_generator --rosdistro ${ROS_DISTRO} --upstream-devel --format repos ${TARGET_PACKAGES} --deps > ${ROS_DISTRO}_upstream.repos
vcs import --input ${ROS_DISTRO}_upstream.repos ${ROS_DISTRO}/src --skip-existing


#proto specific content
vcs import --input ${ROS_DISTRO}_proto.repos ${ROS_DISTRO}/src --force

sudo rosdep init || true
rosdep update


cd ${ROS_DISTRO}

# These packages are missing type_description_interfaces service_msgs on Humble no need to build the tests for this
touch src/rosidl/typesupport_integration_tests/COLCON_IGNORE
touch src/rosidl/typesupport_tests/COLCON_IGNORE
touch src/rosidl/rosidl_generator_tests/COLCON_IGNORE
# testing if they are needed to be protected by rosdep too
# rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers type_description_interfaces service_msgs"

rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

colcon build --event-handlers=console_direct+ --cmake-args='-DBUILD_TESTING=OFF'


