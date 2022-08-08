# Written by Rachel Vargo CS2340 NetID: rmv200000
# Started April 13th, 2022
# This is the encrypt/decrypt function for asg 6, here the file and key is already 
# verifyed or entered and it uses this key to either add to encrypt or subtract
# to decrypt the entered file. File is then saved as either a .txt or .enc. Afterwards
# it is linked back to the main menu function.                                                                                                                                                                                                                                                      

	.data
	.include	"SysCalls.asm"
buffer:
	.space		1024					#space for reading file
	.eqv	block	1024	
	.text
	
	.globl	cryption
cryption:
	move	$a0, $s1					#file descriptor
	la	$a1, buffer					#buffer address
	li	$a2, block					#buffer length block of 1024
	li	$v0, SysReadFile
	syscall
	add	$s1, $a0, $zero					#save file descriptor
	move	$s3, $v0					#save the length of the file	
	beq	$v0, $zero, closeFile
	li	$t4, 0						#initiate counter for loop
	li	$t7, 1						#to compare with
cryption1:
	beq	$t4, $s3, writeToFile				#branches back to top as the full file was read				
	lbu	$t3, 0($a1)					#loads bytes from file
	lbu	$t0, 0($s2)					#loads bytes from key
	beq	$t0, $t1, keyReset				#checks if key is /n to restart it
	beq	$s0, $t7, encrypt				#branches to add for encrypt if menu option 1
	subu	$t3, $t3, $t0					#subtracts for decryption
	b	finishCrypt					#braches to skip encryption addition
encrypt:							#branches if integer from menu 1
	addu	$t3, $t3, $t0					#adds them together
finishCrypt:		
	sb	$t3, 0($a1)					#stores the new byte
	addi	$a1, $a1, 1					#increment to next byte in file
	addi	$s2, $s2, 1					#increment to next byte in key
	addi	$t4, $t4, 1
	b	cryption1					#branches back to continue loop until file is done
keyReset:	
	sub	$s2, $s2, $t5					#resets the key to continue
	b	cryption1
writeToFile:
	li	$t5, '.'					#load period in $t5 for file name
	li	$t4, 0						#length of file name
fileName:
	lb	$t2, 0($s4)					#loads the bytes in the file name
	beq	$t2, $t5, replaceExt				#branches out when period is found
	addi	$s4, $s4, 1					#increment the filename address
	addi	$t4, $t4, 1					#increment length of file name
	b	fileName					#branch to continue loop
replaceExt:							#makes the ext enc
	addi	$s4, $s4, 1					#move to after '.' in extention
	lb	$t2, 0($s4)					#loads next byte to check
	beq	$t2, 'e', txtExt				#checks if extention should be .txt or .enc
	li	$t7, 'e'
	sb	$t7, ($s4)
	addi	$s4, $s4, 1
	li	$t7, 'n'
	sb	$t7, ($s4)
	addi	$s4, $s4, 1
	li	$t7, 'c'
	sb	$t7, ($s4)
	b	createFile
txtExt:								#makes the ext txt
	li	$t7, 't'
	sb	$t7, ($s4)
	addi	$s4, $s4, 1
	li	$t7, 'x'
	sb	$t7, ($s4)
	addi	$s4, $s4, 1
	li	$t7, 't'
	sb	$t7, ($s4)
createFile:
	addi	$t4, $t4, 3					#3 for extention 
	sub	$s4, $s4, $t4 					#length of filename without extention
	move	$a0, $s4
	li	$v0, SysOpenFile				#opens the new file
	li	$a2, 0
	li	$a1, 1						#flags the file to write mode
	syscall
## $a0 = file descriptor $a1 = address of output buffer $a2 = number of characters to write	
	move	$a0, $v0					#moves file descriptor to $a0
	la	$a1, buffer					#buffer block 
	li	$a2, block					#length to write, block = 1024
	li	$v0, SysWriteFile				#write to the file
	syscall
	move	$t6, $v0					#save to close new file later
	j	cryption					#jump back to top to read next block
closeFile:
	move	$a0, $s1					#restore file 
	li	$v0, SysCloseFile				#closes user entered file
	syscall
	move	$a0, $t6
	li	$v0, SysCloseFile				#closes newly created file
	syscall
	jr	$ra
