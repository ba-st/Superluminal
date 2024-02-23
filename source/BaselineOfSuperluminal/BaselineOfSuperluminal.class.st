Class {
	#name : 'BaselineOfSuperluminal',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfSuperluminal',
	#package : 'BaselineOfSuperluminal'
}

{ #category : 'baselines' }
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
				group: 'Tools' with: 'Hyperspace-Tools';
				group: 'Development' with: #('Tests' 'Tools')
			]
]

{ #category : 'accessing' }
BaselineOfSuperluminal >> projectClass [

	^ MetacelloCypressBaselineProject
]

{ #category : 'baselines' }
BaselineOfSuperluminal >> setUpDependencies: spec [

	spec
		baseline: 'Hyperspace' with: [ spec repository: 'github://ba-st/Hyperspace:v5' ];
		project: 'Hyperspace-Deployment' copyFrom: 'Hyperspace' with: [ spec loads: 'Deployment' ];
		project: 'Hyperspace-SUnit'
			copyFrom: 'Hyperspace'
			with: [ spec loads: 'Dependent-SUnit-Extensions' ];
		project: 'Hyperspace-Tools'
			copyFrom: 'Hyperspace'
			with: [ spec loads: 'Tools' ].

	spec
		baseline: 'Launchpad' with: [ spec repository: 'github://ba-st/Launchpad:v5' ];
		project: 'Launchpad-Deployment' copyFrom: 'Launchpad' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON:master' ];
		project: 'NeoJSON-Core' copyFrom: 'NeoJSON' with: [ spec loads: 'core' ].

	spec
		baseline: 'ObjectPool' with: [ spec repository: 'github://ba-st-dependencies/ObjectPool:v2' ];
		project: 'ObjectPool-Core' copyFrom: 'ObjectPool' with: [ spec loads: 'Core' ].

	spec
		baseline: 'Teapot' with: [ spec repository: 'github://ba-st-dependencies/Teapot:v2' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'Teachable' with: [ spec repository: 'github://ba-st-dependencies/Teachable:v3' ];
		project: 'Teachable-Core' copyFrom: 'Teachable' with: [ spec loads: 'Core' ].
		
	spec 
		baseline: 'Memcached' with: [ spec repository: 'github://ba-st-dependencies/Memcached:v2' ];
		project: 'Memcached-Core' copyFrom: 'Memcached' with: [ spec loads: 'Deployment' ]
]

{ #category : 'baselines' }
BaselineOfSuperluminal >> setUpDeploymentPackages: spec [

	spec
		package: 'Superluminal-Model' with: [ spec requires: #('Hyperspace-Deployment' 'NeoJSON-Core') ];
		group: 'Core' with: 'Superluminal-Model';
		group: 'Deployment' with: 'Superluminal-Model'.
	spec
		package: 'Superluminal-Model-Extensions' with: [ spec requires: 'Superluminal-Model' ];
		group: 'Core' with: 'Superluminal-Model-Extensions';
		group: 'Deployment' with: 'Superluminal-Model-Extensions'.
	spec
		package: 'Superluminal-RESTfulAPI'
			with: [ spec requires: #('Superluminal-Model-Extensions' 'ObjectPool-Core' 'Memcached-Core') ];
		group: 'API Client' with: 'Superluminal-RESTfulAPI';
		group: 'Deployment' with: 'Superluminal-RESTfulAPI'.
	spec
		package: 'Superluminal-RESTfulAPI-Extensions'
			with: [ spec requires: 'Superluminal-RESTfulAPI'];
		group: 'API Client' with: 'Superluminal-RESTfulAPI-Extensions';
		group: 'Deployment' with: 'Superluminal-RESTfulAPI-Extensions'.
	spec
		package: 'Superluminal-Service-Discovery' with: [ spec requires: 'Superluminal-RESTfulAPI-Extensions' ];
		group: 'Service Discovery' with: 'Superluminal-Service-Discovery';
		group: 'Deployment' with: 'Superluminal-Service-Discovery'
]

{ #category : 'baselines' }
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

{ #category : 'baselines' }
BaselineOfSuperluminal >> setUpTestPackages: spec [

	spec
		package: 'Superluminal-Model-Tests-Extensions';
		group: 'Tests' with: 'Superluminal-Model-Tests-Extensions'.
	spec
		package: 'Superluminal-Model-Tests'
			with: [ spec requires: #('Superluminal-Model-Extensions' 'Hyperspace-SUnit') ];
		group: 'Tests' with: 'Superluminal-Model-Tests'.
	spec
		package: 'Superluminal-RESTfulAPI-Tests'
			with: [ spec requires: #('Superluminal-RESTfulAPI-Extensions' 'Hyperspace-SUnit' 'Superluminal-SUnit-Model') ];
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
