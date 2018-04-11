http method
get

	| httpClient | 
	
	httpClient := configuration httpClient.

	(resourceBinding content findTokens: $/) do: [ :segment | httpClient addPathSegment: segment ].
	queryStringFields do: [ :field | httpClient queryAt: field key put: field value ].
	
	^ httpClient 
		get.
