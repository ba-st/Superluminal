Extension { #name : #ZnClient }

{ #category : #'*Superluminal-Model' }
ZnClient >> resetRequest [

	request := ZnRequest empty.
	response := nil
]

{ #category : #'*Superluminal-Model' }
ZnClient >> setIfNoneMatchTo: etag [

	request setIfNoneMatchTo: etag
]
