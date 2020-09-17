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
		baseline: 'Buoy' with: [ spec repository: 'github://ba-st/Buoy:v6/source' ];
		project: 'Buoy-Deployment' copyFrom: 'Buoy' with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'NeoJSON' with: [ spec repository: 'github://svenvc/NeoJSON:master/repository' ];
		project: 'NeoJSON-Core' copyFrom: 'NeoJSON' with: [ spec loads: 'core' ]
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpPackages: spec [

	spec
		package: 'Superluminal-Model' with: [ spec requires: 'Buoy-Deployment' ];
		group: 'Deployment' with: 'Superluminal-Model'.

	spec
		package: 'Superluminal-Model-Tests' with: [ spec requires: #('Superluminal-Model' 'NeoJSON-Core') ];
		group: 'Tests' with: 'Superluminal-Model-Tests'
]
