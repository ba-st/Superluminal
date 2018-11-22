configuring
asFormUrlEncoded: aMonadycBlock

	| builder |

	builder := FormUrlEncodedBuilder new.
	aMonadycBlock value: builder.
	^ builder build