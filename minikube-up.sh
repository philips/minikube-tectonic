#!/bin/bash
set -e

### Setup the default variables if not defined
if [ -z $TECTONIC_CONSOLE_VERSION ]; then TECTONIC_CONSOLE_VERSION=v0.1.9; fi
if [ -z $TECTONIC_DEX_VERSION ]; then TECTONIC_DEX_VERSION=v0.5.1; fi

function Check_Prerequisites {
	echo `date` - Starting to check Tectonic on MiniKube requirements ...
	if [[ $(minikube) ]]; then
		echo `date` - 	'	Found MiniKube'
	else 
		echo `date` - ERROR: Could Not Found MiniKube
		exit ;
	fi
	
	if [[ $(kubectl) ]]; then
		echo `date` - '	Found kubectl'
	else 
		echo `date` - ERROR: Could Not Found kubectl
		exit ;
	fi
		
	if [[ $(which wget) || $(which curl) ]]; then
		echo `date` - '	Found wget/curl'
	else 
		echo `date` - ERROR: Could Not Found cURL or wget utilities
		exit ;
	fi

	if [[ $TECTONIC_PULL_SECRET && -e $TECTONIC_PULL_SECRET ]]; then
		echo `date` - '	Found Tectonic Pull Secret'
	elif [ -a $HOME/.dockercfg ]; then
		echo `date` - WARNING: \$TECTONIC_PULL_SECRET not defined or does not exist. Using \$HOME/.dockercfg as pull secret. This may fail if your dockercfg file does not have pull access to Tectonic assets
		export TECTONIC_PULL_SECRET=$HOME/.dockercfg
	else 
		echo `date` - ERROR: Could not find pull secret $TECTONIC_PULL_SECRET
		exit;
	fi
}

function Start_MiniKube {
	echo `date` - Starting MiniKube ...
	minikube start --memory 4096 2> /dev/stdout 1> /dev/null

	echo `date` - Verifying MiniKube Status ...  
		if [ $(minikube status) == "Running" ]; then
			echo `date` - '	MiniKube cluster running'
		else 
			echo `date` - ERROR: Not a valid response from \"minikube status\" 
			exit ;
		fi

	echo `date` - Testing MiniKube Connectivity ...
		echo `date` - Waiting for Kubernetes to initialize ...
		sleep 10  
		if [[ $(kubectl get cs | grep ok) ]]; then
			echo `date` - '	MiniKube cluster seem to be health'
		else 
			echo `date` - ERROR: Not a valid response from \"kubectl get cluster-health\" 
			exit ;
		fi
}

function Install_Tectonic_Basic {
	echo `date` - Installing Tectonic Console ...
	if [[ $(kubectl get namespace | grep tectonic-system) ]] ; then
		echo `date` - '	Found tectonic-system'
	else
		echo `date` - Couldn\'t find namespace, creating it now   
		kubectl create namespace tectonic-system 2> /dev/stdout 1> /dev/null
	fi

	echo `date` - Downloading Manifests ...
	if [[ $(which wget ) ]]; then
		wget -q https://tectonic.com/enterprise/docs/1.2.0/deployer/files/tectonic-console.yaml -O /tmp/tectonic-console.yaml
	elif [[ $(which curl) ]]; then
		curl -s https://tectonic.com/enterprise/docs/1.2.0/deployer/files/tectonic-console.yaml > /tmp/tectonic-console.yaml
	fi
	
	if [ -a /tmp/tectonic-console.yaml ]; then
		sed -i 's@v0.1.6@'$TECTONIC_CONSOLE_VERSION'@g' /tmp/tectonic-console.yaml
	else
		echo `date` - ERROR: Could not download manifest into /tmp
	fi

	echo `date` - Creating tectonic-console objects on kubernetes

	if [ "$TECTONIC_PULL_SECRET" == "$HOME/.dockercfg" ]; then		
		kubectl --namespace=tectonic-system create secret generic coreos-pull-secret --from-file=$TECTONIC_PULL_SECRET 2> /dev/stdout 1> /dev/null
	else
		kubectl --namespace=tectonic-system create -f "$TECTONIC_PULL_SECRET" 2> /dev/stdout 1> /dev/null
	fi

	kubectl --namespace=tectonic-system create -f /tmp/tectonic-console.yaml 2> /dev/stdout 1> /dev/null
	kubectl --namespace=tectonic-system expose rc tectonic-console-$TECTONIC_CONSOLE_VERSION --port=9000 --target-port=9000 --name=tectonic-console --type=NodePort 2> /dev/stdout 1> /dev/null

	minikube service tectonic-console -n=tectonic-system 
}

Check_Prerequisites
Start_MiniKube
#### Install Stuff on Minikube
Install_Tectonic_Basic