as yet unclassified
queryString: aMonadycBlock

	| builder |

	builder := QueryStringBuilder new.
	aMonadycBlock value: builder.
	commands addAll: builder build