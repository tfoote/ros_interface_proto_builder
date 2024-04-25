This repository is setup to automatically run the protobuf generator on ROS distros and generate the current reference protos in a place for easy usage outside the context of a standard build toolchain. 

The github actions will create a branch <ROS_DISTRO>_generated for each distro processed. 

There is a configuration setting which packages are to be built from the rosdistro.

And there are optional override files which enable the addition of the protobuf typesupport packages for the generation while it's still not in the default builds. 
