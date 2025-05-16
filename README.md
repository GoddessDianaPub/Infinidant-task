# Infinidat-task

This repo contains files and commands to use in order to complete Infini-Quest task.

There are 3 folders for each part of the task.
It has been created on windows 11 operating system.

During the task i have used these resources: github, fedoraproject.org, google, chatgpt.

My challenges were to create a VM with a static IP, and the networking part.

I started with WSL which had some limitations and than i moved to windows.

I have created a butane file which more readable for human, and than converted it to ignition file 

in order to create a VM with all the configurations.

I would improve the code by not to save the public key within the config file, i would pass the key in a safer way.

Please clone the repo and follow the instructions bellow:

# Part 1:
## Generate ssh key
ssh-keygen -t rsa -b 4096 -f "your\path\.ssh\id_rsa"

## Prepare a butane file with all the requirements to create a VM

## Download and exctract this file: fedora-coreos-41.20250315.3.0-qemu.x86_64.qcow2.xz
https://builds.coreos.fedoraproject.org/browser?stream=stable&arch=aarch64

## Generate config.ign file based on the butane file with powershell
cd "your\path\Infinidat-task\Part 1"
butane.exe config.bu -o config.ign

## Run this file to create a VM
run-vm.bat

## Use this command to connect to the VM
ssh -i "your\path\.ssh\id_rsa" -p 2222 infini-ops@127.0.0.1


# Part 2:
## Create these files: Dockerfile, requirements.txt, prometheus.yml, docker-compose.yml based on the app.py file provided.
cd "your\path\Infinidat-task\Part 2 + 3\"

## Build the containers:
docker-compose up --build

## Check that it works
http://localhost:9090/
http://localhost:9090/targets

http://localhost:5000/health
http://localhost:5000/metrics


# Part 3:
## Prepaer a powershell file with all the instructions and run it
cd "your\path\Infinidat-task\Part 2 + 3\"
Part_3_deploy.ps1
