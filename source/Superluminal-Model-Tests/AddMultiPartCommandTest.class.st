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

	self withFileNamed: 'testApplyOnWhenAttachingFiles-1.txt'
		containing: '12121212'
		do: [ :filename | 
			self withFileNamed: 'testApplyOnWhenAttachingFiles-2.txt'
				containing: '34343434'
				do: [ :anotherFilename | 
					| httpClient command |

					httpClient := ZnClient new.
					command := AddMultiPartCommand named: 'file' attaching: filename asFileReference.
					command applyOn: httpClient.
					command := AddMultiPartCommand named: 'anotherFile' attaching: anotherFilename asFileReference.
					command applyOn: httpClient.

					self
						assert: httpClient request contentType main equals: 'multipart';
						assert: httpClient request contentType sub equals: 'form-data'.

					self
						assert: ( httpClient request entity partNamed: 'file' ) fieldValue equals: '12121212';
						assert: ( httpClient request entity partNamed: 'anotherFile' ) fieldValue equals: '34343434'
					]
			]
]
