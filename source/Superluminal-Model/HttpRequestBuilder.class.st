Class {
	#name : #HttpRequestBuilder,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Superluminal-Model-Builders'
}

{ #category : #configuring }
HttpRequestBuilder >> body [

	^ HttpRequestBodyBuilder new 
]

{ #category : #configuring }
HttpRequestBuilder >> headers [
	
	^ HttpRequestHeadersBuilder new
]

{ #category : #configuring }
HttpRequestBuilder >> queryString: aMonadycBlock [

	| builder |

	builder := HttpRequestQueryStringBuilder new.
	aMonadycBlock value: builder.
	^ builder build
]
