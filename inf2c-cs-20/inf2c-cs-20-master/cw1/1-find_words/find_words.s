#=========================================================================
# Word Finder 
#=========================================================================
# Finds words in a given text.
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

input_text_file_name:         .asciiz  "input_words.txt"
newline:                      .asciiz  "\n"
blankSpace: 			      .ascii  " " 
        
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

lb $a3, blankSpace				# blankSpace variable stored in a3 register
 addi $t0, $zero, 0				# initialise index to 0

while: 
	lb $t6, input_text($t0)		# store input_text[index] in t6 register
	addi, $t0, $t0, 1			# add 1 to index
	beq $t6, 0, exit			# stop program if end of file	
	beq  $t6, $a3, printWhiteSpace		# print blank space when input_text[index] == " "
	
	li $v0, 11				# tell system to print a character
	move $a0, $t6				# store t6 content in a0
	syscall					# print character
	
	
	j while					# keep looping

printWhiteSpace:
	li $v0, 4				# tell system to print a string
	la $a0, newline				# load "\n" string into a0 register
	syscall					# print string	
	
	j while					# jump to while
	
exit:

#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
