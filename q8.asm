#S5 - Q8
#Nima kelidari
#SN:98108124


.macro  input					#define macro for input string and store in buffer
	addi $v0,$zero,8			#make $v0 8 for get string by syscall
	addi $a1 ,$zero, 1024		#make $a1 1024 (limit of input)
	la $a0,filename				#set adress for $a0, it store input
	syscall					#set adress for $a0, it store input
.end_macro

.macro print							#define macro for print string which addressed in $a0
	li      $v0, 4						#make $v0 8 for print string by syscall
	syscall							#syscall command for print string
.end_macro

.data
call_Table: .word L0,L1,L2,L3,L4,L5,L6,L7   #jump table definition  
msg:    .asciiz "\n0: Exit\n1: Push\n2: Pop\n3: Print\n4: Add\n5: Multiply\n6: Dump\n7: Load\nPlease enter your choice: "
heap:    .asciiz "\nEnter heap size:  "
enter:    .asciiz "\nPlease enter number:  "
inputname:    .asciiz "\nPlease enter filename:  "

err1:    .asciiz "\n*************ERROR************* : Please import a number between 0 and 7\n "
err21:    .asciiz "\n*************ERROR************* : This add operation has overflow, try again\n "
err22:    .asciiz "\n*************ERROR************* : This multiply operation has overflow, try again\n "
err3:    .asciiz "\n*************ERROR************* : You cant add or multiply 2 last elements of stack, because numbers of element! \n "
err4:    .asciiz "\n*************ERROR************* : You cant push an element to stack, because stack is full! \n "
err5:    .asciiz "\n*************ERROR************* : You cant pop last element of stack, because stack is empty! \n "
err6:    .asciiz "\n*************ERROR************* : We couldn't find this file. please  try again\n "
err7:    .asciiz "\n*************ERROR************* : Size of program stack is not eaual with loaded stack. please try again.\n "
err8:    .asciiz "\n*************ERROR************* : heap size should be dividable by 4 and positive\n "

nxtline:    .asciiz "\n"
done:    .asciiz "\nDone!\n"
done1:    .asciiz "\nStack saved in file successfully!\n"
done2:    .asciiz "\nStack loaded from file successfully!\n"
star:    .asciiz "*"
filename: .space 1024
float:    .float 265.9784
txt: .asciiz ".txt"
buffer: .space 1024
.text

start:

li  $v0,4           #print string
la  $a0,heap         #get string address
syscall

li  $v0,5           #get stack size from user
syscall
ble $v0,$zero,error8	#check its positive else show error 8
li $a0,4
div $v0,$a0
mfhi $a0	
bnez   $a0,error8		#check its dividable by 4
move $a0,$v0
move $k0,$v0		#save size permanently in k0
li  $v0,9           #allocate heap memory by v0=9
syscall
move $t8,$v0
move $t7,$v0

loop:
li  $v0,4           #print string of menu
la  $a0,msg         
syscall

li  $v0,5           #get a menu option from user(0 to 7)
syscall

bge $v0,8,error1	#check inputed number of menu is between 0 and 7 else show error 1
ble $v0,-1,error1

move    $s0,$v0         #get index in $s0

sll $s0,$s0,2       #$s0=index*4
la  $t0,call_Table      #$t0=base address of the call table
add $s0,$s0,$t0     #$s0+$t0 = actual address of call label
lw  $s0,($s0)       # load target address 
jalr   $s0             #jump to label
j loop			#get back to first of endless loop


L0:   
j finish			#finish program

L1:   
sub $t6,$t8,$t7
beq $t6,$k0,error4	#check stack has space or its full else print error4

li  $v0,4           #print prompt that want users number for stack
la  $a0,enter         
syscall

li  $v0,5           #get a number from user to put on stack
syscall
move $t1,$v0
sw   $t1,($t8)	#save number in stack
addi $t8,$t8,4	#increase $t8 by 4

li $v0,4		#show message DONE!
la $a0,done
syscall
  
jr $ra		#back to endless loop

L2:   
beq $t7,$t8,error5	#check stack has element or its empty else print error5
addi $t8,$t8,-4
lw   $t1,($t8)		#lead last element of stack in $t1
move $a0,$t1		
sw   $zero,($t8)	#set that zero

li  $v0,1          		#show the popped number from stack
syscall

li $v0,4
la $a0,nxtline		#go to next line
syscall

  
jr $ra			#back to endless loop

L3:   

li $v0,4
la $a0,nxtline	#go to next line
syscall
move $s1,$t8

print_loop:	#enter to a loop for print
addi $t8,$t8,-4	#get back in elements of stack
lw   $t1,($t8)	#load element in $ta
move $a0,$t1
li  $v0,1           	#print element
syscall

li $v0,4		#go to next line
la $a0,nxtline
syscall

beq $t7,$t8,end_print	#if we arrived in first of stack, go to end_print to back to loop
j print_loop		#else go to top of print_loop for printing next element

end_print:
move $t8,$s1
jr $ra			#back to endless loop

L4:   
beq $t7,$t8,error3p	#check we have at least 2 elements in stack for this operation
addi $t8,$t8,-4
beq $t7,$t8,error3
lw   $t1,($t8)		#load first in $t1
move $a0,$t1


addi $t6,$t8,-4
lw   $t1,($t6)		#load second in $t1

#++++++++++++++++++++++++++++++++++++++
xor $t2,$t1,$a0						#check for overflow, if we had overflow problem, error21 will be shown
addu $t3,$t1,$a0
move $t5,$a0
move $a0,$t2
li $v0,1
syscall 
move $a0,$t5
bgez  $t2,check
j resume
check:

xor $t2,$t1,$t3
bltz  $t2,error21
#++++++++++++++++++++++++++++++++++++++

resume:
move $t1,$t3
sw   $zero,($t8) #set last element 0
addi $t8,$t8,-4
sw   $t1,($t8)	#save result in the stack
addi $t8,$t8,4

li $v0,4
la $a0,done		#show DONE! message
syscall

jr $ra			#back to endless loop



L5:   
beq $t7,$t8,error3p			#check we have at least 2 elements in stack for this operation
addi $t8,$t8,-4
beq $t7,$t8,error3
lw   $t1,($t8)				#load first in $t1
move $a0,$t1

addi $t6,$t8,-4
lw   $t1,($t6)				#load second in $t1
#+++++++++++++++++++++
mul $t1,$t1,$a0			#check for overflow, if we had overflow problem, error22 will be shown
mfhi $v0
blt  $v0,-1,error22
bgt $v0,0,error22
#+++++++++++++++++++++++
sw   $zero,($t8)		#set last element 0
addi $t8,$t8,-4
sw   $t1,($t8)			#save result in the stack
addi $t8,$t8,4

li $v0,4
la $a0,done		#show DONE! message
syscall

jr $ra			#back to endless loop


L6:
	 move $s4,$ra
   	 move $s3,$t8
   	 la $a0,inputname				# addressing inputname ("file name: ") in $a0 and print by print macro (line 32)
   	 print
   
###############################################################
  # Open (for writing) a file that does not exist
 	 input					#get file name
  	 la $a0,filename
  	 jal start_str				#add .txt at the end of filename for save as .txt

  
 	 li   $v0, 13       # system call for open file
  	 li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
	 li   $a2, 0        # mode is ignored
  	 syscall            # open a file (file descriptor returned in $v0)
 	 move $s6, $v0      # save the file descriptor 
 	 la   $a1, buffer   # $a1 = address of string where converted number will be kept
	 move $t5,$t7
	
write_loop:			#enter a loop for write every single element of stack
	
  	lw   $a0,($t5)		#get an element of stack and cconvert to staring and save in $a1
  	li      $v1,    1
	jal   ItoA			#make it 
	move $a0, $s6      # file descriptor 
 	move   $a2,  $v1       # set buffer length
 	li   $v0, 15       # system call for write to file
 	syscall  # write to file
 	addi $t5,$t5,4
	beq $t5,$t8,end_write 	#if elements completed go to end write for close file and return
	j write_loop			#else go to first of write_loop

end_write:				#here we end loop and close opened file

	write_size:			#here we write stack size at the end of writing elements
	move $a0, $s6      # file descriptor 
	la   $a1,star	#set * char in a1
 	li   $a2,  1       # hardcoded buffer length
 	li   $v0, 15       # system call for write to file
 	syscall  # write to file
 	move $a0,$k0
 	li   $v1,   1
	jal   ItoA		#convert size of stack (k0) to string and write just after printing *
	move $a0, $s6      # file descriptor 
 	move   $a2,  $v1       # hardcoded buffer length
 	li   $v0, 15       # system call for write to file
 	syscall  # write to file
	
       
 	li   $v0, 16       # system call for close file
  	move $a0, $s6      # file descriptor to close
  	syscall            # close file
	 la $a0,done1		#show message for successfully writing 
   	 print
	move $t8,$s3
  	jr $s4		#back to endless loop
  
start_str:			#load .txt in a3
	move $t1,$a0
	add $a1,$a1,-1
	la $a3,txt

strcopier:			#go forward in input name until arrive in \n char
        addi $a0,$a0,1
	lb $t0,0($a0)
	beq  $t0,'\n',loopstr		#then go to loopstr subroutine
	j strcopier				#else back to first of this loop
	
loopstr:					#here we type .txt after name
	lb $t0,0($a3)			#load from .txt
	beq $t0,$0,end		#if arrive in last of .txt, loop will be ended
	sb $t0,0($a0)			#save to filename space
	addi $a0,$a0,1
	addi $a3,$a3,1
	j loopstr				#else back to first of this loop
	
end:					#return to L6 and $a0 have created filename text
	move $a0,$t1
	jr $ra
	
	

ItoA:			#this loop is for convert integer to string
  bnez $a0, ItoA.non_zero  # first, handle the special case of a value of zero
  nop
  li   $t0, '0'
  sb   $t0, 0($a1)
  sb   $zero, 1($a1)
  li   $v0, 1
  li   $t2, ' '
  sb   $t2, 1($a1)
  addi    $v1,    $v1,    1
  jr   $ra

ItoA.non_zero:
  addi $t0, $zero, 10     # now check for a negative value
  li $v0, 0

  
    
  bgtz $a0, ItoA.recurse
  nop
  li   $t1, '-'				#check for negative number
  sb   $t1, 0($a1)
  addi $v0, $v0, 1
  neg  $a0, $a0
  addi    $v1,    $v1,    1 

ItoA.recurse:			#recursive subroutine for put digits as string
  addi $sp, $sp, -24
  sw   $fp, 8($sp)
  addi $fp, $sp, 8
  sw   $a0, 4($fp)
  sw   $a1, 8($fp)
  sw   $ra, -4($fp)
  sw   $s0, -8($fp)
  sw   $s1, -12($fp)
   
  div  $a0, $t0       # $a0/10
  mflo $s0            # $s0 = quotient
  mfhi $s1            # s1 = remainder  
  addi    $v1,    $v1,    1 
  beqz $s0, ItoA.write

ItoA.continue:		#continue: parsing digits
  move $a0, $s0  
  jal ItoA.recurse
  nop

ItoA.write:		#write digits in buffer  to use
  add  $t1, $a1, $v0
  addi $v0, $v0, 1    
  addi $t2, $s1, 0x30 # convert to ASCII
  sb   $t2, 0($t1)    # store in the buffer
  sb   $zero, 1($t1)
    li   $t2, ' '		#add ' ' in last of strings for later uses
  sb   $t2, 1($t1)
  
ItoA.exit:			#at the end of number we will exit from this subroutins

  lw   $a1, 8($fp)
  lw   $a0, 4($fp)
  lw   $ra, -4($fp)
  lw   $s0, -8($fp)
  lw   $s1, -12($fp)
  lw   $fp, 8($sp)    
  addi $sp, $sp, 24
  jr $ra			#back to L6 code
  nop

  
  L7:   			
 	move $s4,$ra
   	 la $a0,inputname				# addressing inputname ("filename : ") in $a0 and print by print macro
   	 print
   
###############################################################
  
 	 input			#input file name to load
  	 la $a0,filename	#same as before, we add .txt to end of filename space
  	 jal start_str
  	 

	#open a file for writing
	li   $v0, 13       # system call for open file
	li   $a1, 0        # Open for reading
	li   $a2, 0
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor 
	beq $s6,-1,error6

	#read from file
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, buffer   # address of buffer to which to read
	li   $a2, 1024     # hardcoded buffer length
	syscall            # read from file

	# Close the file 
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file
	
	 la $a0,buffer				# addressing buffer to use the string in file 
	 
	 jal check_stack_size		#find size of stack from string in file and save in a1

	 bne $a1,$k0,error7			#check that a1 is equal to k0 or not
	 move $t6,$t7
	 la $a0,buffer	
	 add $a0,$a0,-1
   	 jal define_nums  			#save all of elements in string form file in stacks
   	 
   	 la $a0,done2				#show message for successfully  loading 
   	 print
	addi $t8,$t8,4
  	jr $s4					#back to endless loop
  	

check_stack_size:				#catch the address of * in string of file
	lb $t0,($a0)				#load byte in $t0
	beq $t0,'*',s				#if we arrived in *, continue
	addi $a0,$a0,1
	j check_stack_size		#else return upthere

s:
	li $a1,0
	addi $a0,$a0,1

stack_size_loop:				#here we find number after *
	lb $t0,($a0)				#load ($a0) byte in $0
	beq $t0,' ',end_stack_size	#if we find ' ' end the loop
	beq $t0,$0,end_stack_size	#if string ended end the loop too
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	subi $t0,$t0,48		#these parts is for convert from ascii and add to earlier value
	mul $a1,$a1,10
	add $a1,$a1,$t0	
	addi $a0,$a0,1
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	j stack_size_loop	#else return upthere
	
end_stack_size:	#end the loop and stack size wich we found saved in a1
	jr $ra

 
define_nums:		#this subroutine is for filling stacks with string in file
	li $a1,0
	li $v0,0
	addi $a0,$a0,1
	
num_loop:		#here we find number after *
	lb $t0,($a0)	#load ($a0) byte in $0
	beq $t0,'*',end_define	#if we find '*' end the loop
	beq $t0,$0,end_define	#if string ended end the loop too
	beq $t0,' ',brk				#if we find ' ' means number is complete so go to next number
	beq $t0,'-',negative		#if we -ind ' ' means number is negative so make sign flag (v0) 1
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	subi $t0,$t0,48		#these parts is for convert from ascii and add to earlier value
	mul $a1,$a1,10
	add $a1,$a1,$t0
	addi $a0,$a0,1
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	j num_loop		#else return upthere
	
	
negative:			#we found '-', so here make v0 equal 1
	li $v0,1
	addi $a0,$a0,1
	j num_loop
	
brk:				#we found a number and its ended. here add it to stack
	beq $v0,1,do_negative	#if v0 was 1, negatiate it
	sw $a1,($t6)			#save number in stack
	addi $t6,$t6,4			
	j define_nums		#else return upthere

do_negative:				#make number negative here and back to brk
	mul $a1,$a1,-1
	li $v0,0
	j brk
	
end_define:				#here we back to L7 code
	blt  $t8,$t6,setnewpointer	#if t8 was litterler than last pointer of new stack, we set t6-4 to t8
	addi $t8,$t8,-4
	jr $ra	#back to L7
	
setnewpointer:			#t8 is litteler than t6 so
	sub $t8,$t6,4	#set t8=t6 - 4
	jr $ra		#back to L7
	

#MANAGE ERROR PARTS:	they show errors and jump to first of main endless loop (by their own manners)
##############################################
error1:   
la $a0,err1
print
j loop
error21:   
addi $t8,$t8,4
la $a0,err21
print
j loop
error22:   
addi $t8,$t8,4
la $a0,err22
print
j loop
error3:
addi $t8,$t8,4
error3p:
la $a0,err3
print
jr $ra
error4:
la $a0,err4
print
jr $ra
error5:
la $a0,err5
print
jr $ra
error6:
la $a0,err6				
print
jr $s4
error7:
la $a0,err7				
print
jr $s4	 
error8:
la $a0,err8				
print
j start
  ##############################################
  
finish:#finish the program
li  $v0,10      #Exit
syscall         #Exit
