| branchName |

EpMonitor current disable.

branchName := Smalltalk os environment at: 'BRANCH_NAME' ifAbsent: [Error signal: 'BRANCH_NAME environment variable not set'].
branchName ifEmpty: [ Error signal: 'BRANCH_NAME environment variable value is empty'].

Metacello new
	baseline: 'Superluminal';
	repository: ('github://ba-st/Superluminal:<1s>' expandMacrosWith: branchName);
	load: 'Examples'.
