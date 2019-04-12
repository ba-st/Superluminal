Class {
	#name : #BaselineOfSuperluminal,
	#superclass : #BaselineOf,
	#category : #BaselineOfSuperluminal
}

{ #category : #baselines }
BaselineOfSuperluminal >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.

			spec
				package: 'Superluminal-Model'
					with: [ spec requires: #('Buoy-Deployment') ];
				package: 'Superluminal-Tests'
					with: [ spec requires: #('Superluminal-Model' 'NeoJSON') ].

			spec
				group: 'Deployment' with: #('Superluminal-Model');
				group: 'Tests' with: #('Superluminal-Tests');
				group: 'CI' with: #('Superluminal-Tests');
				group: 'Development' with: #('Tests');
				group: 'default' with: #('Development') ].

	spec
		for: #'pharo6.x'
		do: [ spec
				package: 'Superluminal-Tests-Compatibility';
				package: 'Superluminal-Tests'
					with: [ spec
						requires: #('Superluminal-Model' 'NeoJSON' 'Superluminal-Tests-Compatibility') ] ]
]

{ #category : #baselines }
BaselineOfSuperluminal >> setUpDependencies: spec [

	spec
		baseline: 'Buoy'
			with: [ spec repository: 'github://ba-st/Buoy:v5/source' ];
		project: 'Buoy-Deployment'
			copyFrom: 'Buoy'
			with: [ spec loads: 'Deployment' ].

	spec
		baseline: 'NeoJSON'
		with: [ spec
				repository: 'github://svenvc/NeoJSON:master/repository';
				loads: #('core') ]
]