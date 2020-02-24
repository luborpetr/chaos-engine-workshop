# Lab 3: Deploy Chaos Engine Victim

In this lab we are going to deploy test Kubernetes cluster in GCP with 3 worker nodes and 2 dummy applications.
The cluster will be a target for our experiments we will run in the next lab.

## Create new Kubernetes cluster
Let's provision tiny cluster with 3 nodes. Each node will have 1 CPU and 1.5 GB memory.
From Cloud Shell run:

```bash tab="gcloud command"
gcloud container clusters create "chaos-engine-victim" \
    --zone "europe-west1-b" \
    --no-enable-basic-auth \
    --cluster-version "1.14.10-gke.17" \
    --machine-type "g1-small" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "20" \
    --num-nodes "3" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --enable-autoupgrade \
    --enable-autorepair 
```

```tab="expected output"
WARNING: Starting in 1.12, default node pools in new clusters will have their legacy Compute Engine instance metadata endpoints disabled by default. To create a cluster with legacy instance metadata endpoints disabled in the default node pool, run `clusters create` with the flag `--metadata disable-legacy-endpoints=true`.
WARNING: The Pod address range limits the maximum size of the cluster. Please refer to https://cloud.google.com/kubernetes-engine/docs/how-to/flexible-pod-cidr to learn how to optimize IP address allocation.
This will enable the autorepair feature for nodes. Please see https://cloud.google.com/kubernetes-engine/docs/node-auto-repair for more information on node autorepairs.
Creating cluster chaos-engine-victim in europe-west1-b... Cluster is being health-checked (master is healthy)...done.
Created [https://container.googleapis.com/v1/projects/xxxx/zones/europe-west1-b/clusters/chaos-engine-victim].
To inspect the contents of your cluster, go to: https://console.cloud.google.com/kubernetes/workload_/gcloud/europe-west1-b/chaos-engine-victim?project=xxxx
kubeconfig entry generated for chaos-engine-victim.
NAME                 LOCATION        MASTER_VERSION  MASTER_IP      MACHINE_TYPE  NODE_VERSION    NUM_NODES  STATUS
chaos-engine-victim  europe-west1-b  1.14.10-gke.17  xxx.xxx.xxx.xxx  g1-small      1.14.10-gke.17  3          RUNNING
```

### Authenticate

In order to run `kubectl` commands we need to add new context into your `.kube` config. It could be done by following `gcloud` command.

```bash tab="gcloud command"
gcloud container clusters get-credentials chaos-engine-victim --zone europe-west1-b 
```

```tab="expected output"
Fetching cluster endpoint and auth data.
kubeconfig entry generated for chaos-engine-victim.
```

Check that the `kubectl` context has been switched.

```bash tab="shell command"
kubectl config current-context
```

```tab="expected output"
xxxxxxxxx-west1-b_chaos-engine-victim
```

### Deploy dummy applications

In order to demonstrate Chaos Engine features we need to deploy couple of applications. We will use 2 deployments, one nginx and second apache.
Please go to the workshop repo you cloned to your `Cloud Shell` instance and perform following command.

```bash tab="shell command"
kubectl apply -f kubernetes/applications.yml
```

```tab="expected output"
deployment.apps/nginx configured
deployment.apps/apache created
```

Verify test application were started.

```bash tab="shell command"
kubectl get pods
```

```tab="expected output"
NAME                      READY   STATUS    RESTARTS   AGE
apache-7c99b8d54f-bkk2w   1/1     Running   0          77m
apache-7c99b8d54f-g8k6g   1/1     Running   0          77m
apache-7c99b8d54f-ncwcn   1/1     Running   0          77m
nginx-8779fd9dc-22hqf     1/1     Running   0          76m
nginx-8779fd9dc-pt66s     1/1     Running   0          77m
nginx-8779fd9dc-zn94b     1/1     Running   0          76m
```
