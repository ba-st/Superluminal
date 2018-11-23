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

			spec package: 'Nap-Model' with: [ spec requires: #('Buoy') ].

			spec
				group: 'Deployment' with: #('Nap-Model');
				group: 'Development' with: #('Deployment');
				group: 'default' with: #('Deployment') ]
]

{ #category : #baselines }
BaselineOfNap >> setUpDependencies: spec [

	spec
		baseline: 'Buoy'
		with: [ spec
				repository: 'github://ba-st/Buoy:master/source';
				loads: #('Deployment') ]
]
