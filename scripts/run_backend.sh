#!/usr/bin/env bash
cd $(cd -P -- "$(dirname -- "$0")" && pwd -P)

# Identify device
if [ $(uname -m) == "aarch64" ]; then
    export DEVICE=jetson
else
    export DEVICE=gpu
fi;

SERVICE_NAME=$1

ROS_URI="${ROS_MASTER_URI:-"http://localhost:11311/"}"
ROS_LOCAL_IP="${ROS_IP:-"127.0.0.1"}"

# Run backend
docker-compose -f ../docker/docker-compose.yml run $SERVICE_NAME


# image_name="saga/rasberry_perception:$1"
# password=$2

# # We use 'docker save rasberry_perception:backend_name | gzip > rasberry_perception_backend_name.tar.gz' to host our
# #   docker containers on nextcloud and then download and 'docker load < rasberry_perception_backend_name.tar.gz' to simulate
# #   pulling a container from docker hub. You can also build the dockers locally (see docker/backend_name/dockerfile for details)

# # To add a docker container to the hub add it to the array below
# # Pass password to the protected locations to allow the user access
# #   format: docker_hub["rasberry_perception:backend_name"]="$SHARE_TOKEN:$SHARE_PASSWORD"
# declare -A docker_hub
# docker_hub["rasberry_perception:detectron2"]="n6rXP3oQpbjX9di:${password}"
# docker_hub["rasberry_perception:fruit_reid"]="DqS38eHzLGbHpqR:${password}"
# docker_hub["rasberry_perception:fruitcast"]="irB4bE5AnEGWGZY:${password}"

# echo "Looking for docker image '${image_name}' locally"

# # # Attempt to import docker image from a simulated hub hosted on nextcloud
# # if ! docker image inspect "$image_name" >/dev/null 2>&1 ; then
# #     echo "Docker image '${image_name}' does not exist locally"
# #     echo "Downloading Docker image not implemented yet!" # TODO: Replace lincoln with saga's servers
# #     exit 1

# #     # Check if in the dict array above
# #     share_key=""; share_name=""
# #     for key in "${!docker_hub[@]}"; do
# #         if [ $key == $image_name ]; then
# #             share_key=${docker_hub[$key]}
# #             share_name="$(echo "${key}" | tr : _).tar.gz"
# #         fi
# #     done

# #     # If not in the dict array then return
# #     if [ -z "${share_key}" ]; then
# #         echo "Docker image '${image_name}' also does not exist in the docker hub! Exiting"
# #         exit 1
# #     fi

# #     # Ensure share_key is in the format "token:password"
# #     original_IFS="$IFS"; IFS=":"; declare -a fields=($share_key); IFS="$original_IFS"; unset original_IFS;

# #     # Exit if share key is malformed (not two strings)
# #     if [ ${#fields[@]} -ne "2" ]; then
# #         function join_by { local IFS="$1"; shift; echo "$*"; }
# #         echo "Share string ($(join_by ":" "${fields[*]}")) malformed please contact Saga Robotics for access."
# #         exit 1
# #     fi

# #     mkdir "/tmp/rasberry_perception/docker/" -p
# #     cd /tmp/rasberry_perception/docker/ || exit 1

# #     # Attempt to download the share if it doesn't exist
# #     if [ ! -f "${share_name}" ]; then
# #         echo "Downloading ${share_name}"
# #         curl  -k -u "$share_key" https://lcas.lincoln.ac.uk/nextcloud/public.php/webdav/ -o "${share_name}"
# #     else
# #         echo -e "File  already exists. Delete to re-download:\nrm /tmp/rasberry_perception/docker/${share_name}"
# #     fi

# #     echo "Loading container /tmp/rasberry_perception/docker/${share_name} into docker"
# #     docker load < "${share_name}"

# #     # If docker fails to load the container then delete because the share was invalid
# #     if ! docker image inspect "$image_name" >/dev/null 2>&1 ; then
# #         echo "Docker load command has failed"
# #         rm "/tmp/rasberry_perception/docker/${share_name}"
# #         exit 1
# #     fi
# # fi

# # If container exists then launch, else exit
# if docker image inspect "$image_name" >/dev/null 2>&1 ; then
#     echo "Image '${image_name}' exists locally"
#     echo "Starting $image_name"
#     ROS_URI="${ROS_MASTER_URI:-"http://localhost:11311/"}"
#     ROS_LOCAL_IP="${ROS_IP:-"127.0.0.1"}"
#     docker-compose -f ../docker/docker-compose.yml run gripper-perception
# else
#     echo "No valid container for backend ${image_name} can be started"
#     exit 1
# fi
