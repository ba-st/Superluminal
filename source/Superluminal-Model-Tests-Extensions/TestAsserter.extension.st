Extension { #name : 'TestAsserter' }

{ #category : '*Superluminal-Model-Tests-Extensions' }
TestAsserter >> withFileNamed: aFileName containing: aContents do: aBlock [

	| filename |

	ZnFileSystemUtils deleteIfExists: aFileName.
	filename := ZnFileSystemUtils fullNameFor: aFileName.
	ZnFileSystemUtils newFileNamed: filename do: [ :stream | stream nextPutAll: aContents ].

	aBlock cull: filename.

	ZnFileSystemUtils deleteIfExists: aFileName
]
