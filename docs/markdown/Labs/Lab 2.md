# Lab 2: Install Chaos Engine 

In this lab we will setup our demo environment and we will learn how to deploy and run Chaos Engine tool.

## Clone workshop GitHub repo
In `Cloud Shell` clone the workshop repo. We are going to use scripts located in `scripts` directory.

```bash tab="shell command"
git clone https://github.com/luborpetr/chaos-engine-workshop.git
```

```tab="expected output"
Cloning into 'chaos-engine-workshop'...
remote: Enumerating objects: 4, done.
remote: Counting objects: 100% (4/4), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 4 (delta 0), reused 0 (delta 0), pack-reused 0
Unpacking objects: 100% (4/4), done.

```

## Create new compute instance

We start with creation of a compute node that will be hosting our Chaos Engine instance.

Run following `gcloud` command in your `Cloud Shell`. The script will provision new compute instance with `docker` and `docker-compose` installed.

!!! note
    The script referenced by `startup-script=scripts/provision-vm.sh` option is located in the repo we've downloaded in previous step. Make sure you are in the repo root directory before you run the `gcloud` command.


```bash tab="gcloud command"
gcloud compute \
instances create chaos-engine \
    --zone=europe-west2-c \
    --machine-type=n1-standard-1 \
    --no-service-account \
    --no-scopes \
    --tags=chaos-engine \
    --image=ubuntu-1604-xenial-v20200129 \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=chaos-engine \
    --metadata-from-file startup-script=scripts/provision-vm.sh
```

```tab="expected output"
WARNING: You have selected a disk size of under [200GB]. This may result in poor I/O performance. For more information, see: https://developers.google.com/compute/docs/disks#performance.
Created [https://www.googleapis.com/compute/v1/projects/gemalto-cspeng/zones/europe-west2-c/instances/chaos-engine].
WARNING: Some requests generated warnings:
 - Disk size: '20 GB' is larger than image size: '10 GB'. You might need to resize the root repartition manually if the operating system does not support automatic resizing. See https://cloud.google.com/compute/docs/disks/add-persistent-disk#resize_pd for details.

NAME          ZONE            MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
chaos-engine  europe-west2-c  n1-standard-1               10.xxx.xxx.xxx  xxx.xxx.xxx.xxx  RUNNING

```

### Configure firewall

By default all ingress traffic is dropped by the firewall. We need couple of ports opened to the internet.
That could be done by following command:

```bash tab="gcloud command"
gcloud compute firewall-rules create chaos-engine-inbound \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:8080,tcp:8200,tcp:9000 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=chaos-engine
```

```tab="expected command"
Creating firewall...⠧Created [https://www.googleapis.com/compute/v1/projects/gemalto-cspeng/global/firewalls/chaos-engine-inbound].
Creating firewall...done.                                                                                            
NAME                  NETWORK  DIRECTION  PRIORITY  ALLOW                       DENY  DISABLED
chaos-engine-inbound  default  INGRESS    1000      tcp:8080,tcp:8200,tcp:9000        False

```

### Connect to the Chaos Engine instance

In order to SSH to the machine run following command

```bash tab="gcloud command"
gcloud compute ssh --zone "europe-west2-c" "chaos-engine"
```

```tab="expected output"
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-1052-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage


25 packages can be updated.
15 updates are security updates.

New release '18.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Fri Feb 21 14:21:29 2020 from xxx.xxx.xxx.xx
user@chaos-engine:~$ 

```

### Verify all prerequisites are installed properly

On the `chaos-engine` machine run following list of post install checks

#### Check docker

Check you have `docker` configured properly.

```bash tab="shell command"
docker ps
```

```tab="expected output"
user@chaos-engine:~$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

If the output looks like below, your user is not in `docker` group.
```
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/containers/json: dial unix /var/run/docker.sock: connect: permission denied
```

Adjust your groups and relogin

```bash
sudo usermod -a -G docker $USER
```



#### Check docker-compose

Verify `docker-compose` in your path.

```bash tab="shell command"
docker-compose
```

```tab="expected output"
user@chaos-engine:~$ docker-compose -v
docker-compose version 1.25.4, build 8d51620a
```


## Deploy Chaos Engine

Chaos Engine deployment is very easy, we just need to do few configuration steps.

### Clone Chaos Engine GitHub repo

Clone official Chaos Engine GitHub repo in order to get latest version of the configuration scripts.
From your Chaos Engine VM run:

```bash tab="shell command"
git clone https://github.com/gemalto/chaos-engine.git
```

```tab="expected output"
user@chaos-engine:~$ git clone https://github.com/gemalto/chaos-engine.git
Cloning into 'chaos-engine'...
remote: Enumerating objects: 691, done.
remote: Counting objects: 100% (691/691), done.
remote: Compressing objects: 100% (315/315), done.
remote: Total 26251 (delta 275), reused 609 (delta 228), pack-reused 25560
Receiving objects: 100% (26251/26251), 3.53 MiB | 3.98 MiB/s, done.
Resolving deltas: 100% (10854/10854), done.
Checking connectivity... done.
```

### Adjust configuration
On the Chaos Engine machine go to `chaos-engine` directory and replace `docker-compose.yml` with a file from the workshop repo:
```bash
 wget -O docker-compose.yml https://raw.githubusercontent.com/luborpetr/chaos-engine-workshop/master/docker/docker-compose.yml
```


### Pull Docker Images

Pull Chaos Engine image from DockerHub.

```bash tab="shell command"
docker-compose pull
```

```bash tab="expected output"
Pulling vault        ... done
Pulling vault-loader ... done
Pulling chaosengine  ... done
```

Verify you pulled image tagged `stable`.

```bash tab="shell command"
docker images
```

```bash tab="expected output"
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
thalesgroup/chaos-engine   stable              46c560a17d9a        2 days ago          304MB
vault                      latest              0542f65ae3d0        4 weeks ago         140MB
```

`