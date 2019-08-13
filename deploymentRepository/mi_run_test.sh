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
ls

echo "Build Image ~~~~~~~~~"
cd $dir/$filPath
exec 3<> Dockerfile

echo "ls carbonapps path=====> "
ls $dir/$filPath

#echo "RUN sudo docker login -u ballerinascenarios -p balscenXhgd308152" >&3
#echo "RUN sudo docker login -u="ballerinascenarios" -p="balscenXhgd308152"" >&3
echo "FROM wso2/micro-integrator:1.1.0-SNAPSHOT" >&3
echo "COPY hello-worldCompositeApplication_1.0.0.car /home/wso2carbon/wso2mi/repository/deployment/server/carbonapps" >&3

echo "Build Docker Image ~~~~~~~~~"
pwd
ls

#docker build -t "mi_docker:latest" .
docker build -t mi_docker:latest -f Dockerfile .

docker container ls -a
#docker container rm wso2-mi-container
echo "Run Image ~~~~~~~~~"
docker run -d -p 8290:8290 -p 8253:8253 --name=wso2-mi-container mi_docker:latest

echo "Docker PS ~~~~~~~~~"
docker ps

curl -v GET "http://0.0.0.0:8290/hello-world"
curl -v GET "http://0.0.0.0:8253/hello-world"

echo "Stop container ~~~~~~~~~"
docker container stop wso2-mi-container
docker container rm wso2-mi-container

