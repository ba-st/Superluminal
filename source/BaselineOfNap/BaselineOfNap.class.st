Class {
	#name : #BaselineOfNap,
	#superclass : #BaselineOf,
	#category : 'BaselineOfNap'
}

{ #category : #baselines }
BaselineOfNap >> baseline: spec [

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.

			spec
				package: 'Nap-Model' with: [ spec requires: #('Buoy') ];
				package: 'Nap-Tests' with: [ spec requires: #('Nap-Model' 'NeoJSON') ].

			spec
				group: 'Deployment' with: #('Nap-Model');
				group: 'Tests' with: #('Nap-Tests');
				group: 'Development' with: #('Tests');
				group: 'default' with: #('Deployment') ]
]

{ #category : #baselines }
BaselineOfNap >> setUpDependencies: spec [

	spec
		baseline: 'Buoy'
		with: [ spec
				repository: 'github://ba-st/Buoy:v4/source';
				loads: #('Deployment') ].

	spec
		baseline: 'NeoJSON'
		with: [ spec
				repository: 'github://svenvc/NeoJSON:master/repository';
				loads: #('core') ]
]
