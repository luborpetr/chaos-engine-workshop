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
OPENED_PORTS="tcp:8080,tcp:8200,tcp:9000,tcp:5222,tcp:5280,tcp:5269,tcp:8089,tcp:8085"


SCRIPT_LOCATION=$(readlink -f $(dirname $0))

function wait_for_machine() {
  MAX_RETRIES=10
  RETRY_NO=0
  STATUS_CODE=255
     while [ $STATUS_CODE -ne 0 ]; do
      RETRY_NO=$((RETRY_NO+1))
      echo $(date) "Machine is not yet ready";
      gcloud compute ssh --zone $1 $2 --command "echo Machine is ready"
      STATUS_CODE=$?
      if [ $RETRY_NO -gt $MAX_RETRIES ]; then
        break;
      fi
      sleep 10
    done
}

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
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=$CHAOS_ENGINE_INSTANCE_NANE

    wait_for_machine $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE

    gcloud compute ssh --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE --command "
      cd
      rm -rf chaos-engine-workshop
      git clone https://github.com/luborpetr/chaos-engine-workshop.git
      sudo chaos-engine-workshop/scripts/provision-vm.sh
      chaos-engine-workshop/scripts/configuration/configure-vnc.sh
      chaos-engine-workshop/scripts/configuration/configure-jabber.sh
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
    wait_for_machine $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE

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

    kubectl describe secret chaos-engine

    kubectl apply -f $SCRIPT_LOCATION/../kubernetes/hipster_shop.yml

}

function full_install() {
    provision_chaos_machine
    deploy_chaos_engine
    setup_firewall
    deploy_k8s_cluster
    deploy_workload

}

function delete_chaos_machine() {
    gcloud compute instances delete --quiet --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_INSTANCE_NANE
}

function delete_firewall() {
  gcloud compute firewall-rules delete  --quiet chaos-engine-inbound
}

function delete_cluster() {
  gcloud container clusters delete --quiet --zone $CHAOS_ENGINE_ZONE $CHAOS_ENGINE_VICTIM_NAME
}

function purge_all() {
  delete_chaos_machine
  delete_firewall
  delete_cluster
}

$1

