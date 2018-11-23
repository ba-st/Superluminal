configuring
to: aString encodedAs: aMediaType
	
	^ (SetBodyCommand to: (ZnStringEntity with: aString type: aMediaType ))