Class {
	#name : #HttpRequestConfigurator,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Superluminal-Model-Builders'
}

{ #category : #configuring }
HttpRequestConfigurator >> body [

	^ HttpRequestBodySupplier new 
]

{ #category : #configuring }
HttpRequestConfigurator >> headers [
	
	^ HttpRequestHeadersSupplier new
]

{ #category : #configuring }
HttpRequestConfigurator >> queryString: aMonadycBlock [

	| builder |

	builder := HttpRequestQueryStringBuilder new.
	aMonadycBlock value: builder.
	^ builder build
]
