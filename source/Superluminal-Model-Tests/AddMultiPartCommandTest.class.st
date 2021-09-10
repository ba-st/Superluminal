Class {
	#name : #AddMultiPartCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
AddMultiPartCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := AddMultiPartCommand named: 'name' pairedTo: 'fran'.
	command applyOn: httpClient.

	self
		assert: httpClient request contentType main equals: 'multipart';
		assert: httpClient request contentType sub equals: 'form-data'.
	self assert: ( httpClient request entity partNamed: 'name' ) fieldValue equals: 'fran'
]

{ #category : #tests }
AddMultiPartCommandTest >> testApplyOnWhenAttachingFiles [

	self withFileNamed: 'testApplyOnWhenAttachingFiles.txt'
		containing: '0123456789'
		do: [ :filename | 
			| httpClient command |

			httpClient := ZnClient new.
			command := AddMultiPartCommand named: 'file' attaching: filename asFileReference.
			command applyOn: httpClient.

			self
				assert: httpClient request contentType main equals: 'multipart';
				assert: httpClient request contentType sub equals: 'form-data'.

			self assert: ( httpClient request entity partNamed: 'file' ) fieldValue equals: '0123456789'
			]
]
