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
		project: 'Hyperspace-SUnit' copyFrom: 'Hyperspace' with: [ spec loads: 'Dependent-SUnit-Extensions' ].

	spec
		baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ];
		project: 'NeoJSON-Core' copyFrom: 'NeoJSON' with: [ spec loads: 'core' ].
		
	spec
		baseline: 'ObjectPool' with: [ spec repository: 'github://pharo-ide/ObjectPool:v1.0.1' ];
		project: 'ObjectPool-Core' copyFrom: 'ObjectPool' with: [ spec loads: 'Core' ].
	
	spec
		baseline: 'Teapot' with: [ spec repository: 'github://zeroflag/Teapot:v2.6.0/source' ];
		project: 'Teapot-Deployment' copyFrom: 'Teapot' with: [ spec loads: 'Deployment' ].
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpPackages: spec [

	spec
		package: 'Superluminal-Model'
		with: [ spec requires: #( 'Hyperspace-Deployment' 'NeoJSON-Core' ) ];
		group: 'Deployment' with: 'Superluminal-Model'.

	spec
		package: 'Superluminal-RESTfulAPI'
		with: [ spec requires: #( 'Superluminal-Model' 'ObjectPool-Core' ) ];
		group: 'Deployment' with: 'Superluminal-RESTfulAPI'.

	spec
		package: 'Superluminal-Service-Discovery';
		group: 'Deployment' with: 'Superluminal-Service-Discovery'.

	spec
		package: 'Superluminal-Model-Tests'
		with: [ spec requires: #( 'Superluminal-Model' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Superluminal-Model-Tests'.

	spec
		package: 'Superluminal-RESTfulAPI-Tests'
		with: [ spec requires: #( 'Superluminal-RESTfulAPI' 'Hyperspace-SUnit' ) ];
		group: 'Tests' with: 'Superluminal-RESTfulAPI-Tests'.

	spec
		package: 'Superluminal-Service-Discovery-Tests'
		with: [ spec requires: #( 'Superluminal-Service-Discovery' 'Hyperspace-SUnit' 'Teapot-Deployment') ];
		group: 'Tests' with: 'Superluminal-Service-Discovery-Tests'
]
