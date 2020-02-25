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

- `containerIdentifier` - depending on the configuration `containerIdentifier` can be identifier of individual container or identifier of a logical container group.

- `experimentMethods` - experiment method name

- `specificContainerTargets` - defines concrete targets of experiments


### Create own experiment suite
In previous labs we deployed Kubernetes cluster together with dummy test applications. 

#### One target
Let's define new experiment suite and target `nginx` deployment. 
Following exmaple 
```json
{
   "platformType":"KubernetesPlatform",
   "experimentCriteria":[
      {
         "containerIdentifier":"nginx",
         "experimentMethods":[
            "deletePod"
         ],
         "specificContainerTargets":[

         ]
      }
   ]
}
```

#### Multiple targets

```json
{
   "platformType":"KubernetesPlatform",
   "experimentCriteria":[
      {
         "containerIdentifier":"nginx",
         "experimentMethods":[
            "deletePod"
         ],
         "specificContainerTargets":[

         ]
      },
      {
         "containerIdentifier":"nginx",
         "experimentMethods":[
            "cpuBurn.sh","memoryConsumer.sh"
         ],
         "specificContainerTargets":[

         ]
      }
   ]
}
```


## Random experiments 

 