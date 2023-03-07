.data  
filename: .asciiz "test.txt"     # filename for input
instructions: .space 1024	# space for instructions
memory: .space 2048		# space for program memory
addrbook: .word 256		# space for addressbook

.text

main:

jal load_file_to_instructions

la $s0, memory
la $s1, addrbook
move $s2, $s1
addi $s3, $s1, 1024
move $a0, $zero

la $t0, instructions
addi $t1, $t0, 1024

sb $t1, ($s1)

get_instruction:

lb $t2, ($t0)

beq $t2, 43, plus
beq $t2, 44, pull
beq $t2, 45, minus
beq $t2, 46, put
beq $t2, 60, left
beq $t2, 62, right
beq $t2, 91, loop
beq $t2, 93, exit_loop

return_instruction:
addi $t0, $t0, 1
return_instruction_npp:
blt $t0, $t1, get_instruction

# todo
# command parser, loops
# optimization

j exit_program

# methods ---------------------------------------------------------------------

# command processing 	- s0 is pointer, a0 is value, s1 is addrbook base, s2 is addrbook pointer, s3 is addrbook end,
#			- t0 is instruction memory pointer, t1 is end of instruction memory
right:
addi $s0, $s0, 4
bne $s0, 1024, update_value
move $s0, $zero
j update_value

left:
subi $s0, $s0, 4
bne $s0, $zero, update_value
addi $s0, $zero, 1023
j update_value

update_value:
lb $a0, ($s0)
j return_instruction

plus:
addi $a0, $a0, 1
j save_value

minus:
subi $a0, $a0, 1
j save_value

save_value:
sb $a0, ($s0)
j return_instruction

put:
li $v0, 11
syscall
j return_instruction

pull:
li $v0, 12
syscall
j return_instruction

loop:
blez $a0, sprint_end_loop
addi $s2, $s2, 4
sw $t0, ($s2)
j return_instruction

sprint_end_loop:
addi $t0, $t0, 1
beq $t0, $t1, exit_program
lb $t2, ($t0)
beq $t2, 93, return_instruction
j sprint_end_loop

exit_loop:
blez $a0, trim_addrbook
lw $t0, ($s2)
subi $s2, $s2, 4
j return_instruction_npp

trim_addrbook:
subi $s2, $s2, 4
j return_instruction

load_file_to_instructions:
# open the file
li $v0, 13
la $a0, filename
li $a1, 0
li $a2, 0
syscall
move $s0, $v0

# read from file
li $v0, 14
la $a0, ($s0)
la $a1, instructions
li $a2, 1024
syscall

# close the file 
li   $v0, 16
move $a0, $s0
move $a1, $zero
move $a2, $zero
syscall
jr $ra

exit_program: