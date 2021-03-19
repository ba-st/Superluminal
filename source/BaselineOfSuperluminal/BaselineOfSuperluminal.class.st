Class {
	#name : #BaselineOfSuperluminal,
	#superclass : #BaselineOf,
	#category : #BaselineOfSuperluminal
}

{ #category : #baselines }
BaselineOfSuperluminal >> baseline: spec [

	<baseline>
	spec
		for: #pharo
		do: [ 
			self
				setUpDependencies: spec;
				setUpPackages: spec.
			spec
				group: 'CI' with: 'Tests';
				group: 'Development' with: 'Tests'
			]
]

{ #category : #accessing }
BaselineOfSuperluminal >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpDependencies: spec [

	spec
		baseline: 'Hyperspace' with: [ spec repository: 'github://ba-st/Hyperspace:v2' ];
		project: 'Hyperspace-Deployment' copyFrom: 'Hyperspace' with: [ spec loads: 'Deployment' ];
		project: 'Hyperspace-SUnit'
			copyFrom: 'Hyperspace'
			with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v3' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ];
		project: 'NeoJSON-Core' copyFrom: 'NeoJSON' with: [ spec loads: 'core' ].

	spec
		baseline: 'ObjectPool' with: [ spec repository: 'github://pharo-ide/ObjectPool:v1.0.1' ];
		project: 'ObjectPool-Core' copyFrom: 'ObjectPool' with: [ spec loads: 'Core' ].

	spec
		baseline: 'Teapot' with: [ spec repository: 'github://zeroflag/Teapot:v2.6.0/source' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'Teachable' with: [ spec repository: 'github://astares/Pharo-Teachable:master/src' ];
		project: 'Teachable-Core' copyFrom: 'Teachable' with: [ spec loads: 'Core' ].
		
	spec 
		baseline: 'Memcached' with: [ spec repository: 'github://svenvc/memcached:v1.0.0' ];
		project: 'Memcached-Core' copyFrom: 'Memcached' with: [ spec loads: 'Memcached' ]
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpDeploymentPackages: spec [

	spec
		package: 'Superluminal-Model' with: [ spec requires: #('Hyperspace-Deployment' 'NeoJSON-Core') ];
		group: 'Core' with: 'Superluminal-Model';
		group: 'Deployment' with: 'Superluminal-Model'.
	spec
		package: 'Superluminal-RESTfulAPI'
			with: [ spec requires: #('Superluminal-Model' 'ObjectPool-Core' 'Memcached-Core') ];
		group: 'API Client' with: 'Superluminal-RESTfulAPI';
		group: 'Deployment' with: 'Superluminal-RESTfulAPI'.
	spec
		package: 'Superluminal-Service-Discovery' with: [ spec requires: 'Superluminal-Model' ];
		group: 'Service Discovery' with: 'Superluminal-Service-Discovery';
		group: 'Deployment' with: 'Superluminal-Service-Discovery'
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpPackages: spec [

	self setUpDeploymentPackages: spec.
	spec
		package: 'Superluminal-Service-Discovery-Examples'
			with: [ spec requires: #('Deployment' 'Launchpad-Deployment') ];
		group: 'Examples' with: 'Superluminal-Service-Discovery-Examples'.
	spec
		package: 'Superluminal-SUnit-Model'
			with: [ spec requires: #('Hyperspace-SUnit' 'Teachable-Core') ];
		group: 'Dependent-SUnit-Extensions' with: 'Superluminal-SUnit-Model'.
	self setUpTestPackages: spec
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpTestPackages: spec [

	spec
		package: 'Superluminal-Model-Tests'
			with: [ spec requires: #('Superluminal-Model' 'Hyperspace-SUnit') ];
		group: 'Tests' with: 'Superluminal-Model-Tests'.
	spec
		package: 'Superluminal-RESTfulAPI-Tests'
			with: [ spec requires: #('Superluminal-RESTfulAPI' 'Hyperspace-SUnit' 'Superluminal-SUnit-Model') ];
		group: 'Tests' with: 'Superluminal-RESTfulAPI-Tests'.
	spec
		package: 'Superluminal-Service-Discovery-Tests'
			with: [ spec requires: #('Superluminal-Service-Discovery' 'Hyperspace-SUnit' 'Teapot-Deployment') ];
		group: 'Tests' with: 'Superluminal-Service-Discovery-Tests'.
	spec
		package: 'Superluminal-Service-Discovery-Examples-Tests'
			with: [ spec requires: 'Superluminal-Service-Discovery-Examples' ];
		group: 'Tests' with: 'Superluminal-Service-Discovery-Examples-Tests'
]
