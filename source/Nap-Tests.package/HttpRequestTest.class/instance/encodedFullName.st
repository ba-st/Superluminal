accessing
encodedFullName

	^ NeoJSONWriter
		toString:
			(Dictionary new
				at: 'first_name' put: 'fran';
				at: 'last_name' put: 'fox';
				yourself)