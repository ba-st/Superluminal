baselines
baseline: spec

	<baseline>
	spec
		for: #common
		do: [ self setUpDependencies: spec.
			spec package: 'RESTSt'.

			spec
				group: 'Deployment' with: #('RESTSt');
				group: 'Development' with: #('Deployment');
				group: 'default' with: #('Deployment') ]