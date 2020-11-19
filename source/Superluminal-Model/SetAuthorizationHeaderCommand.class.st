"
I'm an HTTP Request command. I will set the Authorization header in the HTTP request once applied.

## HTTP Reference
The HTTP Authorization request header contains the credentials to authenticate a user agent with a server, usually, but not necessarily, after the server has responded with a 401 Unauthorized status and the WWW-Authenticate header.
Authorization: <type> <credentials>
Directives
- <type>
    Authentication type. A common type is ""Basic"". See [IANA registry of Authentication schemes](http://www.iana.org/assignments/http-authschemes/http-authschemes.xhtml)
- <credentials>
    If the ""Basic"" authentication scheme is used, the credentials are constructed like this: The username and the password are combined with a colon (aladdin:opensesame). The resulting string is base64 encoded (YWxhZGRpbjpvcGVuc2VzYW1l).

"
Class {
	#name : #SetAuthorizationHeaderCommand,
	#superclass : #HttpRequestCommand,
	#instVars : [
		'authorizationDirectives'
	],
	#category : #'Superluminal-Model-Commands'
}

{ #category : #'instance creation' }
SetAuthorizationHeaderCommand class >> to: anAuthorizationDirective [

	AssertionChecker
		enforce: [ anAuthorizationDirective notEmpty ]
		because: 'An Authorization header cannot include empty directives.'
		raising: InstanceCreationFailed.

	^ self new initializeTo: anAuthorizationDirective
]

{ #category : #'instance creation' }
SetAuthorizationHeaderCommand class >> toBearerToken: token [

	^ self to: ( #'Bearer <1p>' expandMacrosWith: token )
]

{ #category : #applying }
SetAuthorizationHeaderCommand >> applyOn: httpClient [

	httpClient headerAt: #Authorization put: authorizationDirectives
]

{ #category : #initialization }
SetAuthorizationHeaderCommand >> initializeTo: anAuthorizationDirective [

	authorizationDirectives := anAuthorizationDirective
]
