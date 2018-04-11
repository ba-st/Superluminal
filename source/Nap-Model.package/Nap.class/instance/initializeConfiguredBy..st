initialization
initializeConfiguredBy: aClientConfiguration 

	configuration := aClientConfiguration.
	
	queryStringFields := OrderedCollection new.
	resourceBinding := Binding undefinedExplainedBy: 'Not yet defined'