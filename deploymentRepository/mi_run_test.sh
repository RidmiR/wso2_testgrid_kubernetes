#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------------

echo "~~~~~~~~~~~~~ Starting mi_run_test.sh ~~~~~~~~~~~~~~~~~~~"

input_dir=$2
output_dir=$4

echo "My INPUTS_DIR is $input_dir"

dir=$(pwd)
echo "HOME ====>   $dir"

echo "Setup GIT ~~~~~~~~~"

setup_git(){
# Add github key to known host
ssh-keyscan -H "github.com" >> ~/.ssh/known_hosts
# Start the ssh-agent
eval "$(ssh-agent -s)"
# Write ssh key to id-rsa file and set the permission
echo "$1" > ~/.ssh/id_rsa
username=$(id -un)

if [ "$username" == "centos" ]; then
    chmod 600 /home/centos/.ssh/id_rsa
else
    chmod 600 /home/ubuntu/.ssh/id_rsa
fi

# Add ssh key to the agent
ssh-add ~/.ssh/id_rsa

}

setup_git

echo "Repo Clone ~~~~~~~~~"
cd $dir
git clone https://github.com/RidmiR/micro-integrator.git
filPath="micro-integrator/distribution/src/resources/dockerfiles/files/carbonapps"
echo "filepath --->>>   $filPath"

echo "$dir LS---->"
ls

echo "Build Image ~~~~~~~~~"
pwd
cd $dir/$filPath
exec 3<> DockerFile

cp DockerFile $dir/$filPath
echo "LS $dir/$filPath==== "
ls $dir/$filPath

echo "RUN sudo docker login -u ridmir -p 1qaz2wsx@E" >&3
echo "FROM wso2/micro-integrato:1.1.0-SNAPSHOT" >&3
echo "RUN mkdir -p $dir/server/carbonapps" >&3
echo "ADD $dir/server/carbonapps" >&3
echo "COPY carbonapps $dir/server/carbonapps" >&3

echo "Build Docker Image ~~~~~~~~~"
cd $dir/$filPath && docker build -t mi_docker:latest .

#echo "Run Image ~~~~~~~~~"
#docker run -d -p 8290:8290 mi_docker:latest

