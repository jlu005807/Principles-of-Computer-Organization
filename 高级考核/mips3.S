   	.text
    
main:
	ori		$t0, $zero, 0x0   	# t0 = 0
	ori		$t1, $zero, 0xffff	# t1 = 0xffff
	addu		$t3, $t0, $t1		# t3 = 0xffff
	ori		$s1, $zero, 0x4   	# s1 = 4
	lui		$a0, 0x1001       	# a0 = 0x80400000
	addiu	$a1, $a0, 0x200		# a1 = 0x80400200
	ori		$t5, $t0, 0x1		# t5 = 1
    
loop:
	addu		$t2, $t0, $t1
	sll		$t2, $t2, 1
	addu		$t1, $t1, $t3
	sub		$t3, $t3, $t5
	sw		$t2, 0($a0)
	lw		$t0, 0($a0)
	bne		$t0, $t2, end
	ori		$zero, $zero, 0
	addu		$a0, $a0, $s1
	slt		$t6, $a1, $a0
	beq		$t6, $zero, loop
	ori		$zero, $zero, 0
	sw		$a0, 0($a0)
	sw		$zero, 4($a0)
    
end:
	j		end
	ori		$zero, $zero, 0
	sw		$t1, 4($a0)
