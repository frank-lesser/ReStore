﻿"Filed out from Dolphin Smalltalk 7"!

SSWReStoreQueryTest subclass: #SSWReStoreFunctionTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
SSWReStoreFunctionTest guid: (GUID fromString: '{c689d42a-c99a-43b0-8365-4f70102d7fb8}')!
SSWReStoreFunctionTest comment: 'ReStore
©2019 John Aspinall
https://github.com/rko281/ReStore'!
!SSWReStoreFunctionTest categoriesForClass!Unclassified! !
!SSWReStoreFunctionTest methodsFor!

addClassesTo: aReStore

	super addClassesTo: aReStore.
	aReStore
		addClass: SimpleProductOrder!

testConditionAsFunctionReceiver

	"Test where the a function is applied to a condition rather than a field.
	Previously unsupported"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || ((each age > 20) then: 'old' else: 'young')].

	self assert: (results allSatisfy: [ :each | each first age > 20 ifTrue: [each last = 'old'] ifFalse: [each last = 'young']])!

testDifferentClassAsFunctionCriteriaDateYear

	"Test a query where the result of a function is a different class to the source field"

	| orders |

	((2017 to: 2020) collect: [ :index | SimpleProductOrder new quantity: index; date: (Date newDay: 1 monthIndex: 2 year: index); yourself]) storeAllIn: reStore.

	orders := SimpleProductOrder storedInstancesIn: reStore.
	2017 to: 2020 do: 
		[ :index |
		self assert: (orders detect: [ :each | each date year = index]) quantity equals: index]!

testDifferentClassAsFunctionCriteriaStringSize

	"Test a query where the result of a function is a different class to the source field"

	| threes |

	threes := (SimplePerson storedInstancesIn: reStore) select: [ :each | each firstName size = 3].
	self assert: (threes collect: [ :each | each firstName]) asSortedCollection asArray equals: #('Jim' 'Zoe')!

testModelClassAsFunctionReceiver

	"Test where the receiver of a function is a model class (as opposed to Number, String etc. type).
	Previously unsupported"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend ifNull: each ifNotNull: each friend)].

	self assert: (results allSatisfy: [ :each | each first friend isNil ifTrue: [each last == each first] ifFalse: [each last == each first friend]])!

testModelClassAsFunctionReceiverWithJoin

	"Test where the receiver of a function is a model class (as opposed to Number, String etc. type), where there are multiple function classes encountered in the function, including a join.
	Previously failed"

	| persons results |

	persons := SimplePerson storedInstancesIn: reStore.
	(persons detect: [ :each | each fullName = 'John Smith']) address: (SimpleAddress new line1: 'somewhere'; yourself); store.

	"Previously the 'each friend' final argument to the function overrode the 'each friend address' receiver. Ensure this is no longer the case"
	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend address ifNull: each ifNotNull: each friend)].

	self assert: 
		(results allSatisfy: 
			[ :each || person result |
			person := each first.
			result := each last.
			(person friend isNil or: [person friend address isNil])
				ifTrue: [result == person] 
				ifFalse: [result == person friend]])!

testOversizeStringAsFunctionCriteria

	"Test a query where an oversize string (compared to the originating field) is the criteria"

	| daves |

	"first_name field is 8 characters; query with a function whose result is 10 characters"
	daves := (SimplePerson storedInstancesIn: reStore) select: [ :each | (each firstName, each firstName) = 'DavidDavid'].
	self assert: (daves collect: [ :each | each firstName]) asArray equals: #('David')!

testStaticValueAsFunctionResult

	"Test where the result of a function is a fixed value, not a field"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || (each friend ifNull: 1 ifNotNull: 2)].

	self assert: (results allSatisfy: [ :each | each first friend isNil ifTrue: [each last = 1] ifFalse: [each last = 2]])!

testTargetFieldFromArgument

	"Test where the result of a function is the class of an argument, not the class of the receiver"

	| results |

	results := (SimplePerson storedInstancesIn: reStore) collect: [ :each | each || ((each age > 20) then: each else: each friend)].

	self assert: (results allSatisfy: [ :each | each first age > 20 ifTrue: [each last == each first] ifFalse: [each last == each first friend]])! !
!SSWReStoreFunctionTest categoriesFor: #addClassesTo:!public!Running! !
!SSWReStoreFunctionTest categoriesFor: #testConditionAsFunctionReceiver!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testDifferentClassAsFunctionCriteriaDateYear!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testDifferentClassAsFunctionCriteriaStringSize!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testModelClassAsFunctionReceiver!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testModelClassAsFunctionReceiverWithJoin!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testOversizeStringAsFunctionCriteria!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testStaticValueAsFunctionResult!public!unit tests! !
!SSWReStoreFunctionTest categoriesFor: #testTargetFieldFromArgument!public!unit tests! !

!SSWReStoreFunctionTest class methodsFor!

shouldInheritSelectors

	^false! !
!SSWReStoreFunctionTest class categoriesFor: #shouldInheritSelectors!public! !

