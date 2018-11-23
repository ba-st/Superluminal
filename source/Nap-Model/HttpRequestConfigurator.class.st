Class {
	#name : #HttpRequestConfigurator,
	#superclass : #Object,
	#instVars : [
		'commands'
	],
	#category : #'Nap-Model-Builders'
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
HttpRequestConfigurator >> queryString [

	^ HttpRequestQueryStringBuilder new
]

{ #category : #configuring }
HttpRequestConfigurator >> queryString: aMonadycBlock [

	| builder |

	builder := HttpRequestQueryStringBuilder new.
	aMonadycBlock value: builder.
	^ builder build
]
