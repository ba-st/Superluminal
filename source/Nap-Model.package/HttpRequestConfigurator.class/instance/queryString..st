configuring
queryString: aMonadycBlock

	| builder |

	builder := HttpRequestQueryStringBuilder new.
	aMonadycBlock value: builder.
	^ builder build