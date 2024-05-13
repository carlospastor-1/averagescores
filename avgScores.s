.data
orig: .space 100 # In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100
str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
space: .asciiz " "
newline: .asciiz "\n"
.text
# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted
#scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account
#for dropped scores).
# It then prints out average score with the specified number of (lowest) scores
#dropped from the calculation.
main:
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4
	la $a0, str0
	syscall
	li $v0, 5 # Read the number of scores from user
	syscall
	move $s0, $v0 # $s0 = numScores
	move $t0, $0
	la $s1, orig # $s1 = orig
	la $s2, sorted # $s2 = sorted
loop_in:
	li $v0, 4
	la $a0, str1
	syscall
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5 # Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	move $a0, $s0
	jal selSort # Call selSort to perform selection sort in original array
	li $v0, 4
	la $a0, str2
	syscall
	move $a0, $s1 # More efficient than la $a0, orig
	move $a1, $s0
	jal printArray # Print original scores
	li $v0, 4
	la $a0, str3
	syscall
	move $a0, $s2 # More efficient than la $a0, sorted
	jal printArray # Print sorted scores
	li $v0, 4
	la $a0, str4
	syscall
	li $v0, 5 # Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1 # numScores - drop
	move $a0, $s2
	move $v0, $zero
	jal calcSum # Call calcSum to RECURSIVELY compute the sum of scores that are
	#not dropped
# Your code here to compute average and print it
	move $t2, $v0
	la $a0, str5
	li $v0, 4
	syscall 
	
	move $v0, $t2
	div $v0, $v0, $a1
	move $a0, $v0
	li $v0, 1
	syscall
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10
	syscall
# printList takes in an array and its size as arguments.
# It prints all the elements in one line with a newline at the end.
printArray:
# Your implementation of printList here
	move $t2, $zero
	move $t3, $a0
	loop:
		addi $v0, $zero, 1
		lw $a0, 0($t3)
		syscall
		addiu $t3, $t3, 4
		addi $t2, $t2, 1
		addi $v0, $zero, 4
		la $a0, space
		syscall
		
		blt $t2, $a1, loop
		 
	addi $v0, $zero, 4
	la $a0, newline
	syscall
	jr $ra
# selSort takes in the number of scores as argument.
# It performs SELECTION sort in descending order and populates the sorted array
selSort:
# Your implementation of selSort here
	add $sp, $sp, -12
	sw $s0, 4($sp)
	sw $ra, 8($sp)
	move $t2, $zero
	la $t3, orig
	la $t4, sorted
	first:
		lw $t5, 0($t3)
		sw $t5, 0($t4)
		addu $t2, $t2, 1
		addu $t3, $t3, 4
		addu, $t4, $t4, 4
		blt $t2, $s0, first
		
	move $t5, $zero
	i_loop:
		move $t6, $t5 #maxindex = i
		move $t7, $t5 # j = i+1
		addiu $t7, $t7, 1
		j j_loop
		return_j:
		la $t4, sorted
		mul $t6, $t6, 4 #maxindex times 4 to access element in array
		addu $t4, $t4, $t6
		lw $s3, 0($t4)
		div $t6, $t6, 4 #divide 
		la $t4, sorted
		mul $t5, $t5, 4
		addu $t4, $t4, $t5
		lw $s4, 0($t4)
		sw $s3, 0($t4)
		div $t5, $t5, 4
		la $t4, sorted
		mul $t6, $t6, 4
		addu $t4, $t4, $t6
		sw $s4, 0($t4)
		div $t6, $t6, 4
		lw $s0, 4($sp)
		sub $s0, $s0, 1
		addiu $t5, $t5, 1
		blt $t5, $s0, i_loop
		j done
	
	j_loop:
		la $t4, sorted
		mul $t7, $t7, 4
		addu $t4, $t4, $t7
		lw $s3, 0($t4)
		div $t7, $t7, 4
		la $t4, sorted
		mul $t6, $t6, 4
		addu $t4, $t4, $t6
		lw $s4, 0($t4)
		div $t6, $t6, 4
		bgt $s3, $s4, greater
		return_greater:
		lw $s0, 4($sp)
		addiu $t7, $t7, 1
		blt $t7, $s0, j_loop
		j return_j
		
	greater:
		move $t6, $t7	
		j return_greater
	done:
	lw $ra, 8($sp)
	lw $s0, 4($sp)
	addi $sp, $sp, 12
	jr $ra
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.
calcSum:
# Your implementation of calcSum here
	la $t4, sorted
	add $sp, $sp, -12
	sw $ra, 4($sp)
	sw $a1, 8($sp)
	ble $a1, $zero, zero_return
	sub $a1, $a1, 1
	jal calcSum
	la $t4, sorted
	mul $a1, $a1, 4
	addu $t4, $t4, $a1
	div $a1, $a1, 4
	lw $t5, 0($t4)
	addu $v0, $v0, $t5
	lw $a1, 8($sp)
	j end_calcSum

zero_return:
	addiu $v0, $v0, 0
	j end_calcSum
	
end_calcSum:
	lw $a1, 8($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 12
	jr $ra