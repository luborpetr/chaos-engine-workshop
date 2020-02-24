# Lab 4: Finalise Framework Configuration

Very well, we have Chaos Engine and Kubernetes cluster deployed, last step before we can run experiments is provisioning of the Vault secure store.


## Retrieve a token
Retrieve the token linked to your `chaos-engine-serviceaccount `.

```bash tab="shell command"
kubectl describe secret chaos-engine
```

```tab="expected output"
Name:         chaos-engine-serviceaccount-token-9thjd
Namespace:    default
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: chaos-engine-serviceaccount
              kubernetes.io/service-account.uid: 87b58785-5719-11ea-90b5-42010a8400d8

Type:  kubernetes.io/service-account-token

Data
====
namespace:  7 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9......
ca.crt:     1115 bytes
```

## Prepare a config file

We are going to load configuration into the Vault. The Vault accepts input data in JSON format.

In order to activate necessary Chaos Engine modules we need to define following variables.

```json
{
  "holidays": "DUM",
  "automatedMode": "false",
  "chaos.security.enabled": "false",
  "kubernetes": "",
  "kubernetes.url": "https://xxx.xxx.xxx.xxx",
  "kubernetes.token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9....",
  "kubernetes.averageMillisPerExperiment": "30000"
}
```

SSH to your `chaos-engine` VM. Go to the `chaos-engine` repo and create new file `./developer-tools/vault-loader/vault-secrets.json`containing JSON object from previous paragraph.

## Provision Vault

```bash tab="shell command"
docker-compose build vault-loader
```

```tab="expected output"
Building vault-loader
Step 1/6 : FROM vault:latest
 ---> 0542f65ae3d0
Step 2/6 : WORKDIR /vault-loader/
 ---> Using cache
 ---> 7b7931c22a68
Step 3/6 : ADD ./vault-* ./
 ---> 1f9bb91ebaad
Step 4/6 : RUN touch ./vault-secrets.json
 ---> Running in d1ad93796cdf
Removing intermediate container d1ad93796cdf
 ---> e34311e2b4b5
Step 5/6 : ENTRYPOINT [ "/bin/sh", "-c" ]
 ---> Running in e0d04f6ea1ac
Removing intermediate container e0d04f6ea1ac
 ---> d15ecf9a3da9
Step 6/6 : CMD [ "./vault-init.sh" ]
 ---> Running in 94ed0a132f1b
Removing intermediate container 94ed0a132f1b
 ---> 97224d8661fa

Successfully built 97224d8661fa
Successfully tagged chaos-engine_vault-loader:latest
```

## Start the Chaos Engine

Start Chaos Engine framework using `docker-compose`.

```bash tab="shell command"
docker-compose up
```

```json tab="expected output"
{"@timestamp":"2020-02-24T21:17:05.723Z","@version":"1","message":"Kubernetes Platform created","logger_name":"com.thales.chaos.platform.impl.KubernetesPlatform","thread_name":"main","level":"INFO","level_value":20000,"env":"WORKSHOP","chaos-host":"b8dcfa2ac884@gcp:chaos-engine:projects/203123834228/zones/europe-west2-c"}
```


## Verify setup

Visit Chaos Engine API endpoint at `http://xxx.xxx.xxx.xxx:8080/swagger-ui.html` You should see an OpenAPI UI.
Go to the `Platform` section and invoke `Get Platforms`. If the output contains 6 targets your environment is ready for experiments.

```bash tab="shell command"
curl -X GET "http://xxx.xxx.xxx.xxx:8080/platform" 
```

```json tab="expected output"
[
  {
    "roster": [
      {
        "shellCapabilities": {},
        "uuid": "a41694a5-56f1-11ea-90b5-42010a8400d8",
        "podName": "nginx-8779fd9dc-zn94b",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "nginx-8779fd9dc",
        "targetedSubcontainer": "nginx",
        "simpleName": "nginx-8779fd9dc-zn94b (default)",
        "aggregationIdentifier": "nginx-8779fd9dc",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 2084787268,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      },
      {
        "shellCapabilities": {},
        "uuid": "9da33aca-56f1-11ea-90b5-42010a8400d8",
        "podName": "nginx-8779fd9dc-pt66s",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "nginx-8779fd9dc",
        "targetedSubcontainer": "nginx",
        "simpleName": "nginx-8779fd9dc-pt66s (default)",
        "aggregationIdentifier": "nginx-8779fd9dc",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 2538209780,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      },
      {
        "shellCapabilities": {},
        "uuid": "9dba6965-56f1-11ea-90b5-42010a8400d8",
        "podName": "apache-7c99b8d54f-ncwcn",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "apache-7c99b8d54f",
        "targetedSubcontainer": "apache",
        "simpleName": "apache-7c99b8d54f-ncwcn (default)",
        "aggregationIdentifier": "apache-7c99b8d54f",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 1977081181,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      },
      {
        "shellCapabilities": {},
        "uuid": "a5ba334a-56f1-11ea-90b5-42010a8400d8",
        "podName": "nginx-8779fd9dc-22hqf",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "nginx-8779fd9dc",
        "targetedSubcontainer": "nginx",
        "simpleName": "nginx-8779fd9dc-22hqf (default)",
        "aggregationIdentifier": "nginx-8779fd9dc",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 3217786026,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      },
      {
        "shellCapabilities": {},
        "uuid": "9dbbddd4-56f1-11ea-90b5-42010a8400d8",
        "podName": "apache-7c99b8d54f-bkk2w",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "apache-7c99b8d54f",
        "targetedSubcontainer": "apache",
        "simpleName": "apache-7c99b8d54f-bkk2w (default)",
        "aggregationIdentifier": "apache-7c99b8d54f",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 3099393506,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      },
      {
        "shellCapabilities": {},
        "uuid": "9db2b330-56f1-11ea-90b5-42010a8400d8",
        "podName": "apache-7c99b8d54f-g8k6g",
        "namespace": "default",
        "ownerKind": "REPLICA_SET",
        "ownerName": "apache-7c99b8d54f",
        "targetedSubcontainer": "apache",
        "simpleName": "apache-7c99b8d54f-g8k6g (default)",
        "aggregationIdentifier": "apache-7c99b8d54f",
        "cattle": true,
        "containerType": "KubernetesPodContainer",
        "identity": 650070269,
        "experimentStartTime": null,
        "knownMissingCapabilities": []
      }
    ],
    "experimentTimes": [],
    "namespace": "default",
    "platformLevel": "PAAS",
    "platformHealth": "OK",
    "apiStatus": "OK",
    "nextChaosTime": "2020-02-24T21:41:18.547Z",
    "platformType": "KubernetesPlatform",
    "destructionProbability": 0.2
  }
]
```

## Lab summary

At the end of this exercise you should have:

- Chaos Engine configured and ready for the first round of experiments.