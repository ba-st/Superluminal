configuring
asFormUrlEncoded: aMonadycBlock

	| builder |

	builder := FormUrlEncodedBodyBuilder new.
	aMonadycBlock value: builder.
	^ builder build