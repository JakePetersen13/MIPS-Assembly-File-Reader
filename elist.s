#---------------------------------------------------------------------------------------------------------
# Name: Petersen, Jake
# Project: 4
# Due: 4/26/24
# Course: cs-2640-02-sp24
# Description:
# A linked list read from element data file 
#---------------------------------------------------------------------------------------------------------
			.data
intro:		.asciiz	"Elements by J. Petersen v0.1\n\n"
ptfname:	.asciiz	"C:\Users\jakep\Downloads\enames.dat"
elements:	.asciiz " elements\n"

head: 		.word 	0
input: 		.space 	80

DATA = 0
NEXT = 4

			.text

#----------------#
# STRING METHODS #
#----------------#

cstrlen: 
	li		$v0, 0	
	move 	$t0, $a0
cstrlenWhile:
	lb   	$t1, ($t0)					# checks character, if equal to zero, stop counting
	beqz 	$t1, endCstrlenWhile		# if another character, increment length by one
	addiu 	$t0, $t0, 1
	addiu	$v0, $v0, 1
	b 		cstrlenWhile
endCstrlenWhile:
	beq		$v0, 79, setMaxCstrlenWhile	# if max length string, set length to 40
	jr   	$ra
setMaxCstrlenWhile:
	la		$v0, 80
	jr		$ra

malloc:
	addiu  $sp, $sp, -4   			#makes room on stack
	sw     $a0, ($sp)      			#saves to stack

	addi   $a0, $a0, 3 				#ensures memory needed is multiple of 4
	srl    $a0, $a0, 2
	sll    $a0, $a0, 2
	li     $v0, 9
	syscall
	
	lw     $a0, ($sp)     			#loads from stack
	addiu  $sp, $sp, 4    			#removes from stack

	jr     $ra
cstrdup:
	addiu	$sp, $sp, -8			# saves $ra and $a0 to the stack
	sw		$ra, 4($sp)
	sw		$a0, ($sp)

	jal		cstrlen					# allocates x bytes of memory
	addi	$a0, $v0, 1				# x = length of string + 1
	jal		malloc
	lw		$a0, ($sp)
	addiu	$sp, $sp, 4
	move	$t0, $a0
	move	$t1, $v0
cstrdupWhile:
	lb		$t2, ($t0)				# copies string character by character
	sb		$t2, ($t1)
	beqz	$t2, endCstrdupWhile
									# if complete, go to end
	addiu	$t0, $t0, 1				# if not, increment to the next character
	addiu	$t1, $t1, 1
	b		cstrdupWhile
endCstrdupWhile:		
	lw		$ra, ($sp)
	addiu	$sp, $sp, 4
	jr		$ra

#--------------#
# NODE METHODS #
#--------------#

getNode:
	addiu	$sp, $sp, -4			# saves the string, head, and return address in stack
	sw		$ra, ($sp)
	addiu	$sp, $sp, -4
	sw		$a0, ($sp)

	li		$a0, 8					# allocates memory for node
	jal 	malloc

	lw		$a0, ($sp)				# gets string and head from stack
	addiu	$sp, $sp, 4

	sw		$a0, DATA($v0)			# sets data of node to the string
	sw		$a1, NEXT($v0)			# sets the next node to head

	lw		$ra, ($sp)				# gets return address from stack
	addiu	$sp, $sp, 4

	jr		$ra					

# $a0 = head, $a1 = print proc
traverse:

	beqz    $a0, traverseEndIf		# If node is empty, end the traversal
    addiu   $sp, $sp, -4			# Stores $a0, and $ra onto stack
    sw    	$ra, ($sp)
    addiu   $sp, $sp, -4
    sw    	$a0, ($sp)
    lw    	$a0, NEXT($a0)    		# Load the next node portion as parameter
    jal    	traverse       

traverseEndIf:
	lw		$a0, DATA($sp)
	lw    	$a0, DATA($a0)			# Loads the string address of node and outputs it
    jalr    $a1

    lw    	$ra, 4($sp)
	lw		$a0, ($sp)
    addiu   $sp, $sp, 8

    jr    	$ra


print:
	addiu	$sp, $sp, -8			# saves $ra and $a0
	sw		$a0, ($sp)
	sw		$ra, 4($sp)

	jal		cstrlen

	move	$a0, $v0				# prints length of element
	li		$v0, 1
	syscall

	li 		$a0, ':'	
	li		$v0, 11
	syscall
	
	lw		$a0, ($sp)				# prints element
	li		$v0, 4
	syscall

	lw		$a0, ($sp)				# loads $ra & $a0
	lw		$ra, 4($sp)
	addiu	$sp, $sp, 8
	jr	  	$ra		

#--------------#
# FILE METHODS #
#--------------#

nofile:
	lw		$s0, 4($sp)
	lw 		$ra, 0($sp)	
	addiu	$sp, $sp, 8

	jr		$ra

#--------------#
# MAIN METHODS #
#--------------#

main:
	la		$a0, intro
	li		$v0, 4
	syscall

	li		$t9, 0					# t9: element counter

	### --- File Reading --- ###

	addiu	$sp, $sp, -8
	sw		$s0, 4($sp)				# s0:file descriptor (fd)
	sw 		$ra, 0($sp)

	la 		$a0, ptfname
	li		$a1, 0					# gives instruction to read file
	jal		open					# s0 = fopen(ptfname) for reading
	beq		$v0, -1, nofile
	move	$s0, $v0		 
while:	
	move 	$a0, $s0				# while can read a line
	la 		$a1, input
	jal 	fgetln
	blez	$v0, endw
	la 		$a0, input 				# output the line
	jal 	cstrdup					# duplicates string
	move	$a0, $v0
	lw		$a1, head
	jal		getNode					# saves duplicated string and head into node
	sw		$v0, head
	addiu	$t9, $t9, 1				# increments counter

	b 		while

endw:	
	move	$a0, $s0
	jal		close					# close file

	move	$a0, $t9				# prints number of elements
	li		$v0, 1
	syscall

	la		$a0, elements
	li		$v0, 4
	syscall

	la		$a0, '\n'				# prints newline
	li		$v0, 11
	syscall

	lw		$a0, head				# calls traverse with head and print as parameters
	la		$a1, print	
	jal		traverse
	

exit:
	li		$v0, 10					# exits
	syscall
