# Lab 5: Run Experiments

In this lab we will learn how to construct and run experiments. 

In general there are two types of experiments: 

- User defined experiments - user can define list of targets as well as experiment methods

- Random experiments - the Engine randomly selects a target and experiment method

## User defined experiments

Let's start with user defined experiments. Go to `http://${CHAOS_ENGINE_IP}:8080/swagger-ui.html` and find `/experiment/build/` API endpoint.
The Chaos Engine accepts experiment definition in JSON format. The JSON object is called `experiment suite`.

The experiment suite definition has following format:

- `platformType` - defines on which level we are going to run our experiments. Only one `platformType` can be specified in the suite

- `experimentCriteria` - defines target selection criteria

- `containerIdentifier` - depending on the configuration `containerIdentifier` can be identifier of individual container or identifier of a logical container group. In our case it's a ReplicaSet name.

- `experimentMethods` - experiment method name

- `specificContainerTargets` - defines concrete targets of experiments


### Create own experiment suite
In previous labs we deployed Kubernetes cluster together with dummy test applications. 

Now we need to gather ReplicaSet name. From the `Cloud Shell` run:

```bash tab="shell command"
kubectl describe pod nginx | grep ReplicaSet | head -n 1 | cut -d / -f 2
```

!!! note
    The Chaos Engine automated mode is disabled. The Engine will perform experiments on user requests only.
    You need to change the scheduler mode to `automated` in order to let the Engine decide when and how the experiments will be executed.

#### One target
Let's define new experiment suite and target `nginx` deployment. 
With following configuration the Chaos Engine randomly selects containers 
from defined ReplicaSet and runs `deletePod` experiment. 

```json tab="request"
{
   "platformType":"KubernetesPlatform",
   "experimentCriteria":[
      {
         "containerIdentifier":"${REPLICASET_NAME}",
         "experimentMethods":[
            "deletePod"
         ],
         "specificContainerTargets":[

         ]
      }
   ]
}
```

```json tab="response"
[
  {
    "id": "9d8ceadd-c041-4b03-8387-672c99d84279",
    "experimentState": "CREATED",
    "container": {
      "shellCapabilities": {},
      "uuid": "ea25ec0a-5873-11ea-8e60-42010a840252",
      "podName": "nginx-8779fd9dc-r4s8g",
      "namespace": "default",
      "ownerKind": "REPLICA_SET",
      "ownerName": "nginx-8779fd9dc",
      "targetedSubcontainer": "nginx",
      "simpleName": "nginx-8779fd9dc-r4s8g (default)",
      "aggregationIdentifier": "nginx-8779fd9dc",
      "cattle": true,
      "containerType": "KubernetesPodContainer",
      "identity": 460354102,
      "experimentStartTime": "2020-02-26T08:49:08.337167Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-26T08:49:08.337167Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "deletePod",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  }
]
```
#### Multiple targets
There might be cases where you need to target multiple ReplicaSets. 
With following suite the Chaos Engine will perform `deletePod` experiment one the first and `cpuBurn.sh` and `memoryConsumer.sh` on the second.

```json tab="request"
{
   "platformType":"KubernetesPlatform",
   "experimentCriteria":[
      {
         "containerIdentifier":"${REPLICASET_NAME}",
         "experimentMethods":[
            "deletePod"
         ],
         "specificContainerTargets":[

         ]
      },
      {
         "containerIdentifier":"${REPLICASET_NAME}",
         "experimentMethods":[
            "cpuBurn.sh","memoryConsumer.sh"
         ],
         "specificContainerTargets":[

         ]
      }
   ]
}
```

```json tab="response"
[
  {
    "id": "6c862bea-31b7-410e-8c89-66f058dbb9d5",
    "experimentState": "CREATED",
    "container": {
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
      "experimentStartTime": "2020-02-25T17:31:46.880036Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-25T17:31:46.880036Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "cpuBurn.sh",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  },
  {
    "id": "2d8f0780-a792-4740-b08b-b5bd9c68082e",
    "experimentState": "CREATED",
    "container": {
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
      "experimentStartTime": "2020-02-25T17:31:46.879668Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-25T17:31:46.879668Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "deletePod",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  },
  {
    "id": "e11781f3-2a13-44aa-80b1-6d6edb3bce85",
    "experimentState": "CREATED",
    "container": {
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
      "experimentStartTime": "2020-02-25T17:31:46.881773Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-25T17:31:46.881773Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "memoryConsumer.sh",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  }
]
```

### Specific targets
There is a way how you can select specific PODs to be experiment on. 
The suite below will run `deletePod` experiment on two selected PODs.

```json tab="request"
{
   "platformType":"KubernetesPlatform",
   "experimentCriteria":[
      {
         "containerIdentifier":"${REPLICASET_NAME}",
         "experimentMethods":[
            "deletePod","deletePod"
         ],
         "specificContainerTargets":[
            "${CONTAINER_UUID}","${CONTAINER_UUID}"
         ]
      }
   ]
}
```

```json tab="response"
[
  {
    "id": "2f04f8e0-2c70-418b-b207-fa75291899b3",
    "experimentState": "CREATED",
    "container": {
      "shellCapabilities": {},
      "uuid": "b5bfbca5-57f4-11ea-b766-42010a840276",
      "podName": "nginx-8779fd9dc-8j5nz",
      "namespace": "default",
      "ownerKind": "REPLICA_SET",
      "ownerName": "nginx-8779fd9dc",
      "targetedSubcontainer": "nginx",
      "simpleName": "nginx-8779fd9dc-8j5nz (default)",
      "aggregationIdentifier": "nginx-8779fd9dc",
      "cattle": true,
      "containerType": "KubernetesPodContainer",
      "identity": 2721520672,
      "experimentStartTime": "2020-02-26T08:42:19.574611Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-26T08:42:19.574611Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "deletePod",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  },
  {
    "id": "de65529a-15ca-4a75-9667-8ed28223f27d",
    "experimentState": "CREATED",
    "container": {
      "shellCapabilities": {},
      "uuid": "f3d66972-57e9-11ea-b766-42010a840276",
      "podName": "nginx-8779fd9dc-5pm2h",
      "namespace": "default",
      "ownerKind": "REPLICA_SET",
      "ownerName": "nginx-8779fd9dc",
      "targetedSubcontainer": "nginx",
      "simpleName": "nginx-8779fd9dc-5pm2h (default)",
      "aggregationIdentifier": "nginx-8779fd9dc",
      "cattle": true,
      "containerType": "KubernetesPodContainer",
      "identity": 1188653708,
      "experimentStartTime": "2020-02-26T08:42:19.571086Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-26T08:42:19.571086Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "deletePod",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  }
]
```

## Random experiments 

You can run experiments without composing a suite. 
The main difference is that the Engine will randomly selects targets and experiment methods.

```bash tab="request"
curl -X POST "http://35.234.145.174:8080/experiment/start"
```

```json tab="response"
[
  {
    "id": "e4599705-0001-4170-b3bd-fd34f475b080",
    "experimentState": "CREATED",
    "container": {
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
      "experimentStartTime": "2020-02-26T09:22:02.801564Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-26T09:22:02.801564Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "forkBomb.sh",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  },
  {
    "id": "01a8d3e2-f8e4-4b7a-aeb4-0b23651a487c",
    "experimentState": "CREATED",
    "container": {
      "shellCapabilities": {},
      "uuid": "721c1715-57f5-11ea-b766-42010a840276",
      "podName": "apache-7c99b8d54f-9txbf",
      "namespace": "default",
      "ownerKind": "REPLICA_SET",
      "ownerName": "apache-7c99b8d54f",
      "targetedSubcontainer": "apache",
      "simpleName": "apache-7c99b8d54f-9txbf (default)",
      "aggregationIdentifier": "apache-7c99b8d54f",
      "cattle": true,
      "containerType": "KubernetesPodContainer",
      "identity": 2597272431,
      "experimentStartTime": "2020-02-26T09:22:02.786886Z",
      "knownMissingCapabilities": []
    },
    "experimentType": "STATE",
    "selfHealingMethod": {},
    "startTime": "2020-02-26T09:22:02.786886Z",
    "lastSelfHealingTime": null,
    "selfHealingCounter": 0,
    "experimentMethodName": "starveRandomNumberGenerator.sh",
    "experimentLayerName": "KubernetesPodContainer",
    "wasSelfHealingRequired": null
  }
]
```

## Lab summary

At the end of this exercise you should know:

- How to construct and run experiment suite