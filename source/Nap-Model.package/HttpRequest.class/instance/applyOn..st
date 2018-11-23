applying
applyOn: anHttpClient

	anHttpClient
		url: url;
		method: method.

	commands isNil ifFalse: [ commands applyOn: anHttpClient ].

	^ anHttpClient
		execute;
		response