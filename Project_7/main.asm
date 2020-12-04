; Author:	Austin Chayka
; Project name:		Program #7
; Description:
;	Tests the user on calculating combinations based upon
;		random values

INCLUDE irvine32.inc

N_MIN = 3
N_MAX = 12
R_MIN = 1

.data

	;strings
	intro BYTE "Welcome to the Combinations Calculator", 13, 10, "Implemented by Austin Chayka",13, 10, 13, 10, "I’ll give you a combinations problem. You enter your answer, and I’ll let you know if you’re right.", 0
	problem BYTE "Problem:", 13, 10, 0
	nSet BYTE "Number offset elements in the set: ", 0
	cSet BYTE "Number offset elements to choose from the set: ", 0
	prompt BYTE "How many ways can you choose: ", 0
	ans1 BYTE "There are ", 0
	ans2 BYTE " combinations of ", 0
	ans3 BYTE " items from a set of ", 0
	ans4 BYTE ".", 13, 10, 0
	right BYTE "You are correct!", 13, 10, 0
	wrong BYTE "You need more practice.", 13, 10, 0
	errorMsg BYTE "Invalid entry. ", 0
	again BYTE "Another problem? (y/n): ", 0
	goodbye BYTE "OK... goodbye.", 13, 10, 0
	;variables
	n DWORD ?
	r DWORD ?
	result DWORD ?
	temp DWORD ?
	tempStr BYTE 10 DUP(?)
	answer DWORD ?

.code

;display string macro
;	takes in an adress to a string variable
;	prints the string to the terminal using the writeString procedure
displayString MACRO buffer
	;preserve used register
	push	edx
	;sets used register
	mov		edx, buffer
	;call print procedure
	call	WriteString
	;restore register
	pop		edx

ENDM

;introduction procedure
;	takes in nothing
;	displays the intro message
introduction PROC
	;set up the stack
	push	ebp
	mov		ebp, esp
	pushad
	;display intro message
	displayString	 OFFSET intro
	;restore the stack
	popad
	pop		ebp
	ret

introduction ENDP

;show problem procedure
;	takes in the adresses of n and r
;	assigns random values to n and r and then
;		prints the priblem
showProblem PROC
	;set up stack
	push	ebp
	mov		ebp, esp
	pushad
	;gets random value for n
	mov		eax, N_MAX
	sub		eax, N_MIN
	inc		eax
	call	RandomRange
	add		eax, N_MIN
	mov		edx, [ebp + 12]
	mov		[edx], eax
	;gets random value for r
	sub		eax, R_MIN
	inc		eax
	call	RandomRange
	add		eax, R_MIN
	mov		ecx, [ebp + 8]
	mov		[ecx], eax
	;displays the problem
	displayString	OFFSET problem
	displayString	OFFSET nSet
	mov		eax, [edx]
	call	WriteDec
	call	CrLf
	displayString	OFFSET cSet
	mov		eax, [ecx]
	call	WriteDec
	;restores stack
	popad
	pop		ebp
	ret		8

showProblem ENDP

;get data procedure
;	takes in address of where to store the
;		user's input
;	gets input from the user
getData PROC
	;set up stack
	push	ebp
	mov		ebp, esp
	pushad
	;prompts for input
	displayString OFFSET prompt
	;get input
	call	ReadInt
	mov		edx, [ebp + 8]
	mov		[edx], eax
	;restore stack
	popad
	pop		ebp
	ret		4

getData ENDP

;combinations procedure
;	takes in an address to store the result
;		and the values of n and r
;	calculates and stores the number of combinations
combinations PROC
	;set up stack
	push	ebp
	mov		ebp, esp
	pushad
	;find r!
	mov		eax, [ebp + 8]
	mov		temp, eax
	push	OFFSET temp
	call	factorial
	mov		ecx, temp
	;find n!
	mov		eax, [ebp + 12]
	mov		temp, eax
	push	OFFSET temp
	call	factorial
	mov		ebx, temp
	;find (n-r)!
	mov		eax, [ebp + 12]
	sub		eax, [ebp + 8]
	mov		temp, eax
	push	OFFSET temp
	call	factorial	
	mov		eax, temp
	;find n!/(n!(r-n)!)
	mul		ecx
	mov		esi, eax
	mov		edx, 0
	mov		eax, ebx
	div		esi
	mov		edx, [ebp + 16]
	mov		[edx], eax
	;restore stack
	popad
	pop		ebp
	ret		12

combinations ENDP

;factorial procedure
;	takes in the address of a value
;	calculates and stores the factorial
;		of a value
factorial PROC
	;set up stack
	push	ebp
	mov		ebp, esp
	pushad
	;get passed value
	mov		ecx, [ebp + 8]
	;check for base case
	mov		edx, 1
	cmp		[ecx], edx
	je		base
	;factorial call of n-1
	mov		edx, [ecx]
	dec		edx
	mov		[ecx], edx
	push	ecx	
	call	factorial
	;multiply lower factorial by n
	inc		edx
	mov		eax, [ecx]
	mul		edx
	;return value
	mov		[ecx], eax
	jmp		endFact
	;return 1 for base case
	base:
	mov		edx, 1
	mov		[ecx], edx

	endFact:
	;restore stack
	popad
	pop ebp
	ret 4

factorial ENDP

;show results procedure
;	takes in the result of the combination
;		as well as n and r and the user's
;		answer
;	displays the answer and tells the user if
;		they are correct or not
showResults PROC
	;set up stack
	push	ebp
	mov		ebp, esp
	pushad
	;display answers
	displayString	OFFSET ans1
	mov		eax, [ebp + 16]
	call	WriteDec
	displayString	OFFSET ans2
	mov		eax, [ebp + 8]
	call	WriteDec
	displayString	OFFSET ans3
	mov		eax, [ebp + 12]
	call	WriteDec
	displayString	OFFSET ans4
	;check if user asnwer is correct
	mov		edx, [ebp + 20]
	cmp		edx, [ebp + 16]
	je		correct
	;notify the user if wrong
	displayString	OFFSET wrong
	jmp		endShow

	correct:
	;notify the user if correct
	displayString	OFFSET right

	endShow:
	;restore stack
	popad
	pop		ebp
	ret		16

showResults ENDP

main PROC
	;seed the randomizer
	call	Randomize
	;display intro
	call	introduction

	L1:
	
	call	CrLf
	call	CrLf
	;show the problem
	push	OFFSET n ;12
	push	OFFSET r ;8
	call	showProblem
	call	CrLf
	call	CrLf
	;get answer from user
	push	OFFSET answer ;8
	call	getData
	;calculate combination
	push	OFFSET result ;16
	push	n ;12
	push	r ;8
	call	combinations
	call	CrLf
	;show answer
	push	answer ;20
	push	result ;16
	push	n ;12
	push	r ;8
	call	showResults	
	;check if the user wants to go again
	displayString OFFSET again
	call	ReadChar
	cmp		al, 121
	je		L1
	;say goodbye
	displayString	OFFSET goodbye

	exit
main ENDP

end main