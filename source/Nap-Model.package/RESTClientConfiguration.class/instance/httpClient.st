initialization
httpClient

	configurationCommands do: [ :command | command applyOn: httpClient ].
	
	^ httpClient
		url: url;
		yourself