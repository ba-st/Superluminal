# Installation

## Provided groups

- `Core` will load the packages providing HTTPRequest building blocks to be used
  in a deployed application
- `API Client` will load the packages providing API client building blocks to be
  used in a deployed application
- `Service Discovery` will load the packages providing service discovery
  strategies to be used in a deployed application
- `Deployment` will load all the packages needed in a deployed application
  (Basically Core + API Client + Service Discovery)
- `Tests` will load the test cases
- `Dependent-SUnit-Extensions` will load the extensions to the SUnit framework
- `Tools` will load the extensions to the SUnit framework and development tools
  (inspector and spotter extensions)
- `CI` is the group loaded in the continuous integration setup
- `Development` will load all the needed packages to develop and contribute to
  the project

## Basic Installation

You can load **Superluminal** evaluating:

```smalltalk
Metacello new
  baseline: 'Superluminal';
  repository: 'github://ba-st/Superluminal:release-candidate';
  load.
```

> Change `release-candidate` to some released version if you want a pinned version

## Using as dependency

In order to include **Superluminal** as part of your project, you should
reference the package in your product baseline:

```smalltalk
setUpDependencies: spec

  spec
    baseline: 'Superluminal' 
      with: [ spec repository: 'github://ba-st/Superluminal:v{XX}' ];
    project: 'Superluminal-Deployment' copyFrom: 'Superluminal'
      with: [ spec loads: 'Deployment' ];  
```

> Replace `{XX}` with the version you want to depend on

```smalltalk
baseline: spec

  <baseline>
  spec
    for: #common
    do: [ self setUpDependencies: spec.
      spec package: 'My-Package' 
        with: [ spec requires: #('Superluminal-Deployment') ] ]
```
