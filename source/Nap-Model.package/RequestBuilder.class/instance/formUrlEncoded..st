as yet unclassified
formUrlEncoded: aMonadycBlock

	| builder |

	builder := FormUrlEncodedBuilder new.
	aMonadycBlock value: builder.
	commands addAll: builder build