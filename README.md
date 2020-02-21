# Chaos Engine Workshop
In this workshop you will learn how to deploy Chaos Engine framework and how to execute experiments targeting Kubernetes PODs.
The Chaos Engine and our test targets will be provisioned in Google Cloud Platform.

## Workshop Prerequisites
- Sign up for [free GCP subscription](https://cloud.google.com/free)
- Make sure you have [Chrome web browser](https://www.google.com/chrome/) installed

# Exercise 1: Activate your GCP console
1. Open `Chrome` web browser and go to [GCP console](https://console.cloud.google.com/)
2. `Activate Cloud Shell` by clinking on the shell icon in the upper right corner of the Console
3. I will take a while until your `Cloud Shell` instance gets provisioned
 

# Exercise 2: Install Chaos Engine 

### Create new compute instance

```bash
gcloud compute \
instances create chaos-engine \
    --zone=europe-west2-c \
    --machine-type=n1-standard-1 \
    --no-service-account \
    --no-scopes \
    --tags=http-server,https-server \
    --image=ubuntu-1604-xenial-v20200129 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=chaos-engine \
    --metadata-from-file startup-script=scripts/provision-vm.sh
```

Connect
```bash
gcloud compute ssh --zone "europe-west2-c" "chaos-engine"

usermod -a -G docker lubor

```
## Free all created resources