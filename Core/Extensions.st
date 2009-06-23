Object extend [
    
    sandStoneDeepCopy [
	<category: '*sandstonedb-serialization'>
    
	"Replaces the receiver (sub) active records
	with Sandstone references where it is needed"
	^self sandstoneDeepCopyVisits: (IdentityDictionary new: self sandstoneInitialHashSize)
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject class index value |
	visitedParts at: self ifPresent: [ :it | ^ it ].
	class := self class.
	class isVariable
	    ifTrue:
		[ index := self basicSize.
		newObject := class basicNew: index.
		[ index > 0 ] whileTrue:
		    [ newObject
			basicAt: index
			put: ((self basicAt: index) sandstoneDeepCopyVisits: visitedParts).
		    index := index - 1 ]]
		ifFalse: [ newObject := class basicNew ].
	    visitedParts at: self put: newObject.
	    index := class instSize.
	    [ index > 0 ] whileTrue:
		[ value := self instVarAt: index.
		newObject
		    instVarAt: index
		    put: (value isSandstoneActiveRecord
			ifTrue: [ value ]
			ifFalse: [ value sandstoneDeepCopyVisits: visitedParts ]).
		    index := index - 1].
		^newObject
    ]

    sandstoneInitialHashSize [
	<category: '*sandstonedb-serialization'>
	^10000
    ]

    sandstoneMarkReferences [
	<category: '*sandstonedb-serialization'>

	"Replaces the receiver (sub) active records
	with Sandstone references where it is needed"
	^self sandstoneMarkReferencesVisits: (IdentityDictionary new: self sandstoneInitialHashSize)
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it].
	visitedParts at: self put: self.
	self class allInstVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    var isSandstoneActiveRecord
		ifTrue:
		    [self
			instVarNamed: name
			put: var asReferenceMarker]
		ifFalse: [var sandstoneMarkRefencesVisits: visitedParts]].
	^self
    ]

    sandstoneResolveReferences [
	<category: '*sandstonedb-serialization'>
	"Replaces the receiver markers with
	active records where it is needed"
	^self sandstoneResolveReferencesVisits: (IdentityDictionary new: self sandstoneInitialHashSize)
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^ self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^ it ].
	visitedParts at: self put: self.
	self class allInsVarNames do:
	    [:name |
	    | var |
	    var := self instVarNamed: name.
	    (var isSandStoneMarker)
		ifTrue:
		    [ self
			instVarNamed: name
			put: var asOriginalObject ]
		ifFalse: [var sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]

    deservesSandstoneReferenceMark [
	<category: '*sandstonedb-testing'>
	^true
    ]

    isSandstoneActiveRecord [
	<category: '*sandstonedb'>

	"Answers true if the receiver is
	a Sandstone Active Record."
	^false
    ]

    isSandstoneMarker [
	<category: '*sandstonedb'>
	^false
    ]
]

Collection extend [
    
    sandstoneDeepCopyVisits: visitedParts[
	<category: '*sandstonedb'>
    
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^it ].
	newObject := self copy.
	newObject do:
	    [:each |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject remove: each.
		newObject add: (each sandstoneDeepCopyVisits: visitedParts) ]].
	^newObject
    ]
    
    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>

	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self ].
	visitedParts at: self put: self.
	self copy do: [:each |
	    each isSandstoneActiveRecord
		ifTrue: [ self remove: each; each; add: each asReferenceMarker ]
		ifFalse: [ each sandstoneMarkReferencesVisits: visitedParts ]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
    
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self at: index put: each asOriginalObject ]
		ifFalse: [ each sandstoneResolveReferencesVisits: visitedParts ]].
	^self
    ]
]

Array extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^ {Array. DependentsArray. WeakArray } includes: self class
    ]
    
    deserveSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^false
    ]
]

Boolean extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Bag extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^ it ].
	newObject := self copy.
	newObject valuesAndCounts sandstoneDeepCopyVisits: visitedParts.
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	<category: '*sandstonedb'>

	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	self deservesSandstoneReferenceMark ifFalse: [:it | ^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self valuesAndCounts sandstoneMarkReferencesVisits: visitedParts.
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category:'*sandstonedb'>
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."

	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self copy valuesAndCounts sandstoneResolveReferencesVisits: visitedParts.
	^self
    ]
]


Character extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

Complex extend [

    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandsonedb'>
	^self
    ]
]

DataStream class extend [

    fileNamed: aName do: aBlock [
	<category:'*sandstonedb'>
	| file |
	file := self fileNamed: aName.
	^ file
	    ifNil: [nil]
	    ifNotNil: [[aBlock value: file] ensure: [file close]
    ]

    newFileNamed: aName do: aBlock [
	<category: '*sandstonedb'>
	| file |
	file := self newFileNamed: aName.
	^file
	    ifNil: [nil]
	    ifNotNil: [[aBlock value: file ] ensure: [ file close ]
    ]

    oldFileNamed: aName do: aBlock [
	<category: '*sandstonedb'>
	| file |
	file := self oldFileNamed: aName.
	^ file
	    ifNil: [nil]
	    ifNotNil: [[aBlock value: file] ensure: [file close]]
    ]

    readOnlyFileNamed: aString [
	<category: '*sandstonedb'>
	| strm |
	strm := self on: (FileStream readOnlyFileNamed: aString).
	strm byteStream setFileTypeToObject.
	^strm
    ]

    readOnlyFileNamed: aName do: aBlock [
	<category: '*sandstonedb'>
	file := self readOnlyFileNamed: aName.
	^file
	    ifNil: [nil]
	    ifNotNil: [[aBlock value: file] ensure: [file close]]
    ]
]

Dictionary extend [
    
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>

	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	|newOject|
	visitedParts at: self ifPresent: [ :it | ^it].
	newObject := self copy.
	newObject keysAndValuesDo:
	    [:key :each |
	    each isSandstoneActiveRecord ifFalse:
		[newObject 
		    at: key
		    put: (each sandstoneDeepCopyVisits: visitedParts)]].
	^newObject
    ]	

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the instrospectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self keysAndValuesDo:
	    [:key :each |
	    each isSandstoneActiveRecord
		ifTrue: [self at: key put: each asReferenceMarker]
		ifFalse: [each sandstoneMarkReferencesVisits:  visitedParts]].
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy keysAndValuesDo:
	    [ :key :each |
	    each isSandstoneMarker
		ifTrue: [self at: key put: each asOriginalObject]
		ifFalse: [each sandstoneResolveReferencesVisits: visitedParts]]
	^self
    ]
]

Integer extend [
    
    asReducedSumOfDigits [
	"Answers the sum of the digits present in the
	decimal representation of the receiver
	but also repeating the procedure if the answers is greater than 9."
	
	^10 <= self
	    ifFalse: [self]
	    ifTrue:
		[self = 10
		    ifTrue: [0]
		    ifFalse:
			[(self printString
			    inject: 0
			    into: [:sum :e | sum + e digitValue ]) asReducedSumOfDigits ]]
    ]
]

LookupKey extend [

    deservesSandstoneReferenceMark [
    <category: '*sandstonedb'>
    ^true
    ]
]

Magnitude extend [
    
    deservesSandstoneReferenceMark [
	<category: '*sandstonedb'>
	^false
    ]
]

Number extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]
	
    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
    
    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]

SequenceableCollection extend [

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"sandstoneDeepCopy works just like deepCopy until it hits another active record
	at which point the copying stops, and the actual references is returned."
	| newObject |
	visitedParts at: self ifPresent: [:it | ^it ].
	newObject := self copy.
	"optimized implementation taking advantaged of ordering"
	newObject doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord ifFalse:
		[ newObject at: index put: (each sandstoneDeepCopyVisits: visitedParts)]].
	^newObject
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone active records to become references.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	self deservesSandstoneReferenceMark ifFalse: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	self doWithIndex:
	    [:each :index |
	    each isSandstoneActiveRecord
		ifTrue: [self at: index put: each asReferenceMarker]
		ifFalse: [each sandstoneMarkReferencesVisits: visitedParts]].
	^self
    ]	
]

Set extend [
    
    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	
	"Make components of the introspectee which are
	Sandstone references to active record to become active records.
	Do this deeply (sub components)."
	self class isMeta ifTrue: [^self].
	visitedParts at: self ifPresent: [:it | ^self].
	visitedParts at: self put: self.
	"It is crucial to modify the introspectee by iterating a copy of it"
	self copy doWithIndex:
	    [:each :index |
	    each isSandstoneMarker
		ifTrue: [self remove: each; add: each asOriginalObject]
		ifFalse: [each sandstoneResolveReferencesVisits: visitedParts]].
	^self
    ]
]

String extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb-serialization'>
	^self shallowCopy
    ]

    sandstoneDeepCopy [
	<category: '*sandstonedb-serialization'>
	^self shalloxCopy
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb-serialization'>
	^self
    ]
]

UndefinedObject extend [
    
    sandstoneDeepCopy [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneDeepCopyVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneMarkReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]

    sandstoneResolveReferencesVisits: visitedParts [
	<category: '*sandstonedb'>
	^self
    ]
]
