### Getting Started with MiniKube

Minikube is a tool that makes it easy to run Kubernetes locally. Minikube runs a single-node Kubernetes cluster inside a VM on your laptop for users looking to try out Kubernetes or develop with it day-to-day.

Prerequisites 
- On Linux you will need VirtualBox or KVM installation.
- On OSX you can use the xhyve driver, VirtualBox or VMware Fusion

Follow the documentation in; https://github.com/kubernetes/minikube in order to set up minikube. Releases can be found in; https://github.com/kubernetes/minikube/releases 

### Getting Started

MiniKube + Tectonic requires about 4 GB Memory on the host machine.

Download the CoreOS Pull Secret from tectonic.com

Set the Variables such as

```
# Tectonic Console Version
export TECTONIC_CONSOLE_VERSION=v0.2.0
# Tectonic DEX Version (not yet implemented)
export TECTONIC_DEX_VERSION=v0.5.1
# Tectonic.com pull secret
export TECTONIC_PULL_SECRET=$HOME/Downloads/coreos-pull-secret.yaml
```

Run the minikube-up script

```
minikube-up.sh
```

### Cleanup

```
minikube delete
```
