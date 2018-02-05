baselines
baseline: spec

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
			spec package: 'Nap-Model' with: [ spec requires: #('Buoy') ].

			spec
				group: 'Deployment' with: #('Nap-Model');
				group: 'Development' with: #('Deployment');
				group: 'default' with: #('Deployment') ]