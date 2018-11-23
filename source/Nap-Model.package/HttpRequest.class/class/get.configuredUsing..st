instance creation
get: aUrl configuredUsing: aMonadycBlock
	
	^ self performing: #GET at: aUrl configuredUsing: aMonadycBlock 