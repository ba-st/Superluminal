Class {
	#name : #CompositeHttpRequestCommandTest,
	#superclass : #TestCase,
	#category : #'Superluminal-Model-Tests-Commands'
}

{ #category : #tests }
CompositeHttpRequestCommandTest >> testApplyOn [

	| httpClient command |

	httpClient := ZnClient new.
	command := CompositeHttpRequestCommand ofAll: ( Array
			             with: ( AddQueryStringFieldCommand named: 'first_name' pairedTo: 'fran' )
			             with: ( AddQueryStringFieldCommand named: 'last_name' pairedTo: 'fox' ) ).

	command applyOn: httpClient.

	self assertUrl: httpClient request uri equals: '/?last_name=fox&first_name=fran'
]

{ #category : #tests }
CompositeHttpRequestCommandTest >> testShortcutCreation [

	| httpClient command |

	httpClient := ZnClient new.
	command := ( AddQueryStringFieldCommand named: 'first_name' pairedTo: 'fran' )
	           + ( AddQueryStringFieldCommand named: 'last_name' pairedTo: 'fox' ).

	command applyOn: httpClient.

	self assertUrl: httpClient request uri equals: '/?last_name=fox&first_name=fran'
]
