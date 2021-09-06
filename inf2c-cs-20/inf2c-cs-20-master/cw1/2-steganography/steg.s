#=========================================================================
# Steganography
#=========================================================================
# Retrive a secret message from a given text.
# 
# Inf2C Computer Systems
# 
# Dmitrii Ustiugov
# 9 Oct 2020
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data
#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_text_file_name:         .asciiz  "input_steg.txt"
newline:                      .asciiz  "\n"
blankSpace:			.asciiz  " "

#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
input_text:                   .space 10001       # Maximum size of input_text_file + NULL
.align 4                                         # The next field will be aligned

# You can add your data here!

#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_text_file_name  # input_text file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # input_text[idx] = c_input
        la   $a1, input_text($t0)             # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_text_file);
        blez $v0, END_LOOP              # if(feof(input_text_file)) { break }
        lb   $t1, input_text($t0)          
        beq  $t1, $0,  END_LOOP        # if(c_input == '\0')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
END_LOOP:
        sb   $0,  input_text($t0)       # input_text[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_text_file)


#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------
# You can add your code here!

addi $t0, $zero, 0 					# index counter
addi $t1, $zero, 0		       			# newline counter
addi $t2, $zero, 0					# blankSpace counter
#addi $t4, $zero, 0

lb $a3, blankSpace					# load blankSpace string in a3 register
lb $a2, newline						# load newline string in a2 register

while: 
	#beq $t0, 0x20, printNextChar
	lb $t6, input_text($t0)			# load input_text[index]
	beq $t6, $0, exit				# exit if EOF
	beq  $t6, $a3, addtoBlankSpaceCounter		# add to blankspace counter if input_text[index] == " "
	
	beq  $t6, $a2, addtoNewLineCounter 		# add to newline counter if input_text[index] == "\n"
	beq $t1, $t2, 	printWords			# go to printwords label if line counter == blankspace counter
	
	addi, $t0, $t0, 1				# increment index by 1
	
	j while						# repeat until one of the conditions above is meet

# the sun is shining\n   - CEOL = 2
# the cake is ready\n   -CBS = 2
# the dog is barking 

addtoBlankSpaceCounter:
addi $t2, $t2, 1					# add 1 to blankspace counter	
addi $t0, $t0, 1					# increment index by 1

j while							# jump back to while loop

addtoNewLineCounter:
bgt $t1, $t2, printNewLine				# if line number > spaces then go to printNewLine label

addi $t0, $t0, 1					# increment index by 1
addi $t1, $t1, 1					# add 1 to line counter
#addi $t3, $t1, 1					
addi $t2, $zero, 0					# set space counter back to 0

j while							# jump to while loop

printWords:
	lb $t6, input_text($t0) 			# load input_text[index] into t6 register
	beq $t6, $a2, addtoNewLineCounter		# if input_text[index] == "\n" then go to addtoNewLineCounter label
	beq $t6, $a3, printWhiteSpace			# if input_text[index] == " " then go to printWhiteSpace label
	
	li $v0, 11					# tell system to print a char
	move $a0, $t6					# move input_text[index] to a0 register
	syscall						# tell system to print
	
	addi, $t0, $t0, 1				# increment index by 1
	
	j printWords					# keeping looping until of the above conditions is met

printWhiteSpace:
	li $v0, 4					# tell system to print a string
	la  $a0, blankSpace				# load address of blankSpace constant into a0 register
	syscall						# tell system to print
	j incrementCounter				# go to incrementCounter label

incrementCounter:
lb $t6, input_text($t0) 				# load input_text[index] into t6 register
beq $t6, $a2, addtoNewLineCounter			# if input_text[index] == "\n" then go to addtoNewLineCounter label
beq $t6, $0, exit					# if EOF then exit
addi $t0, $t0, 1					# increment index by 1

j incrementCounter					# keep repeating until one of the conditions above are met

printNewLine:
	li $v0, 4					# tell system to print a string
	la $a0, newline					# load address of blankSpace constant into a0 register
	syscall						# tell system to print

	add $t0, $t0, 1					# increment index by 1
	addi $t2, $zero, 0				# set blankspace counter to 0
	addi $t1, $t1, 1				# add 1 to line counter
	#addi $t3, $t1, 1
	 j while					# jump to while loop

exit:
	
	li $v0, 4
	la $a0, newline					# print a newline
	syscall
	
	j main_end					# go to main_end label



#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
