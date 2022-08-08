# Written by Rachel Vargo for CS 2340, rmv200000
# Started April 13th, 2022
# This program encrypts or decrypts a file and is only exited by typing 3
# for the opening message prompt. It encrypts by using a user entered .txt file and encrypting the bytes
# with a user provided key. It decrypts by using a user entered .enc file and decrypting the bytes with a
# user provided key as well. The difference in techniques is the encryption adds the key bytes and the
# decryption subtracts the key bytes.
		
	.include	"SysCalls.asm"
	.data
menu:	.asciiz		"Please select a menu option:\n1. Encrypt the file\n2. Decrypt the file\n3. Exit\n"
error:	.asciiz		"Invalid input.\n"
askFile:	
	.asciiz		"Please enter the filename: "
fileErr:
	.asciiz		"Invalid file entered.\n"
askKey:	.asciiz		"What is the key? "
keyErr:	.asciiz		"Invalid key.\n"
filenm:	.space		60					#for the length of the file name
key:	.space		60					#for the length of the key
	.eqv		block	1024
	.text
main:
	la	$a0, menu					#prompts to select a menu option
	li	$v0, SysPrintString
	syscall
	li	$v0, SysReadInt					#reads in menu integer
	syscall
	move	$s0, $v0					#moved to $s0 to save choice
	beq	$s0, 3, exit					#branches to end the program
	blt	$s0, 3, requestFile				#skips to asking for a file as it was a 1 or 2
	la	$a0, error					#prints error message
	li	$v0, SysPrintString
	syscall
	b	main						#reshows menu as the integer was not an option
requestFile:	
	la	$a0, askFile					#prompts to type the file name
	li	$v0, SysPrintString
	syscall
	la	$v0, SysReadString				#reads user inputed string
	la	$a0, filenm					#stores name in filename
	li	$a1, 60						#holds the length of the filename
	syscall
	li	$t1, '\n'					#load $t1 with newline character
findnl:								#remove newline from file name
	lbu	$t0, 0($a0)					#go through file name one byte at a time	
	beq	$t0, $t1, checkKey				#finds the newline to remove it
	addi	$a0, $a0, 1					#moves to next byte in string
	b	findnl						#loops till newline is found
checkKey:							#opens the file
	sb	$zero, ($a0)					#overwrites the newline with 0
	la	$s4, filenm					#to save file name for extention change 
	la	$a0, askKey					#asks for encrypt/decrypt key
	li	$v0, SysPrintString
	syscall
	la	$a0, key					#allows user to enter the key
	li	$a1, 60
	li	$v0, SysReadString
	syscall
	li	$t5, 0						#initiate key length counter
	move	$s2, $a0					#holds key
	lb	$t0, 0($s2)					#loads first byte of key
	bne	$t0, $t1, keyLength				#checks if first key is newline, if not check file
	la	$a0, keyErr					#key is invalid and zero length
	li	$v0, SysPrintString
	syscall
	b	main						#branches back to the menu
keyLength:			
	lb	$t0, 0($s2)					#loads byte from key
	beq	$t0, $t1, testFile				#branches out if newline
	addi	$t5, $t5, 1					#increments length counter of key 
	addi	$s2, $s2, 1					#increments address of key
	b	keyLength	
testFile:
	li	$v0, SysOpenFile				#opens the user inputed file
	li	$a1, 0						#flags the file to read mode
	la	$a0, filenm					#loads the filename
	syscall
	move	$s1, $v0					#load file descriptor
	bgez	$v0, fileOpened					#if file error ends program
	la	$a0, fileErr					#prints error if file does not exist
	li	$v0, SysPrintString
	syscall
	b	main						#branches back to the menu
fileOpened:	
	jal	cryption					#jumps to functions file to do the algorithm
	b	main						#branches back to the main menu to restart process
exit:
	li	$v0, SysExit					#terminates the program
	syscall