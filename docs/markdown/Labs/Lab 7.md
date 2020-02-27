# Lab 7: Clean up
Make sure you freed all the resources you have created during this workshop.

## Delete Chaos Engine machine

```bash
gcloud compute instances delete --zone "europe-west2-c" "chaos-engine"
```

## Purge firewall rules

```bash
gcloud compute firewall-rules delete  chaos-engine-inbound
```

## Delete Kubernetes cluster

```bash
gcloud container clusters delete --zone "europe-west1-b" "chaos-engine-victim"
```