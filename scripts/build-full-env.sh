#!/bin/bash


COMPUTE_INSTANCE_SMALL=n1-standard-1
COMPUTE_INSTANCE_MEDIUM=n1-standard-2
COMPUTE_INSTANCE_LARGE=n1-standard-4

CHAOS_ENGINE_INSTANCE_NANE="chaos-engine"
CHAOS_ENGINE_INSTANCE_TYPE=$COMPUTE_INSTANCE_LARGE
CHAOS_ENGINE_VICTIM_NAME="$CHAOS_ENGINE_INSTANCE_NANE-victim"
CHAOS_ENGINE_NETWORK_TAGS=$CHAOS_ENGINE_INSTANCE_NANE
CHAOS_ENGINE_FW_NAME="$CHAOS_ENGINE_INSTANCE_NANE-inbound"
CHAOS_ENGINE_ZONE="europe-west2-c"
OPENED_PORTS="tcp:8080,tcp:8200,tcp:9000,tcp:5222,tcp:5280,tcp:5269,tcp:8089"


SCRIPT_LOCATION=$(readlink -f $(dirname $0))

function provision_chaos_machine() {
  gcloud compute \
    instances create $CHAOS_ENGINE_INSTANCE_NANE \
    --zone=$CHAOS_ENGINE_ZONE \
    --machine-type=$CHAOS_ENGINE_INSTANCE_TYPE \
    --no-service-account \
    --no-scopes \
    --tags=$CHAOS_ENGINE_NETWORK_TAGS \
    --image=ubuntu-1604-xenial-v20200129 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=$CHAOS_ENGINE_INSTANCE_NANE \
    --metadata-from-file startup-script=$SCRIPT_LOCATION/provision-vm.sh

    sleep 60

    gcloud compute ssh --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE --command "
      sudo usermod -a -G docker $USER
      cd
      git clone https://github.com/luborpetr/chaos-engine-workshop.git
      "
}

function setup_firewall() {
  gcloud compute firewall-rules create $CHAOS_ENGINE_FW_NAME \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=$OPENED_PORTS \
    --source-ranges=0.0.0.0/0 \
    --target-tags=$CHAOS_ENGINE_NETWORK_TAGS

}

function deploy_chaos_engine() {
    gcloud compute ssh --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE --command "
      cd
      git clone https://github.com/ThalesGroup/chaos-engine.git
      cd chaos-engine
      wget -O docker-compose.yml https://raw.githubusercontent.com/luborpetr/chaos-engine-workshop/master/docker/docker-compose.yml
      docker-compose pull
    "
}

function deploy_k8s_cluster() {
    gcloud container clusters create $CHAOS_ENGINE_VICTIM_NAME \
    --zone $CHAOS_ENGINE_ZONE \
    --no-enable-basic-auth \
    --cluster-version "1.14.10-gke.17" \
    --machine-type "$COMPUTE_INSTANCE_SMALL" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "20" \
    --num-nodes "3" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --enable-autoupgrade \
    --enable-autorepair

    kubectl apply -f $SCRIPT_LOCATION/../kubernetes/rbac.yml

}

function deploy_workload() {
    gcloud container clusters get-credentials $CHAOS_ENGINE_VICTIM_NAME --zone $CHAOS_ENGINE_ZONE

    kubectl apply -f $SCRIPT_LOCATION/../kubernetes/applications.yml

}

function full_install() {
    provision_chaos_machine
    deploy_chaos_engine
    setup_firewall
    deploy_k8s_cluster
    deploy_workload

}

function purge_all() {
    gcloud compute instances delete --quiet --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE
    gcloud compute firewall-rules delete  --quiet chaos-engine-inbound
    gcloud container clusters delete --quiet --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_VICTIM_NAME
}

$1

