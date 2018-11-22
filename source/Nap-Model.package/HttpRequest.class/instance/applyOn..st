applying
applyOn: anHttpClient

	anHttpClient
		url: url;
		method: method.

	commands applyOn: anHttpClient.

	^ anHttpClient
		execute;
		response