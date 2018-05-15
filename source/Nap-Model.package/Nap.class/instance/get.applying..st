http methods
get: anUrl applying: aMonadycBlock

	| builder |

	builder := RequestBuilder new.
	aMonadycBlock value: builder.
	commands addAll: builder build.

	httpClient url: anUrl.

	commands do: [:command | command applyOn: httpClient ].

	^ httpClient
		get;
		response