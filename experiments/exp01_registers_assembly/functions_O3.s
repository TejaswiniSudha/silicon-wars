	.file	"functions.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	add
	.type	add, @function
add:
.LFB23:
	.cfi_startproc
	endbr64
	lea	eax, [rdi+rsi]
	ret
	.cfi_endproc
.LFE23:
	.size	add, .-add
	.p2align 4
	.globl	sum
	.type	sum, @function
sum:
.LFB24:
	.cfi_startproc
	endbr64
	test	esi, esi
	jle	.L9
	lea	eax, -1[rsi]
	cmp	eax, 2
	jbe	.L10
	mov	edx, esi
	mov	rax, rdi
	pxor	xmm0, xmm0
	shr	edx, 2
	sal	rdx, 4
	add	rdx, rdi
	.p2align 5
	.p2align 4
	.p2align 3
.L6:
	movdqu	xmm2, XMMWORD PTR [rax]
	add	rax, 16
	paddd	xmm0, xmm2
	cmp	rdx, rax
	jne	.L6
	movdqa	xmm1, xmm0
	mov	edx, esi
	psrldq	xmm1, 8
	and	edx, -4
	paddd	xmm0, xmm1
	movdqa	xmm1, xmm0
	psrldq	xmm1, 4
	paddd	xmm0, xmm1
	movd	eax, xmm0
	test	sil, 3
	je	.L12
.L5:
	movsxd	rcx, edx
	lea	r8d, 1[rdx]
	add	eax, DWORD PTR [rdi+rcx*4]
	cmp	esi, r8d
	jle	.L3
	add	edx, 2
	add	eax, DWORD PTR 4[rdi+rcx*4]
	cmp	esi, edx
	jle	.L3
	add	eax, DWORD PTR 8[rdi+rcx*4]
	ret
	.p2align 4,,10
	.p2align 3
.L9:
	xor	eax, eax
.L3:
	ret
	.p2align 4,,10
	.p2align 3
.L12:
	ret
.L10:
	xor	edx, edx
	xor	eax, eax
	jmp	.L5
	.cfi_endproc
.LFE24:
	.size	sum, .-sum
	.p2align 4
	.globl	max3
	.type	max3, @function
max3:
.LFB25:
	.cfi_startproc
	endbr64
	cmp	esi, edx
	mov	eax, edi
	cmovl	esi, edx
	cmp	esi, edi
	cmovge	eax, esi
	ret
	.cfi_endproc
.LFE25:
	.size	max3, .-max3
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Addition: %d\n"
.LC1:
	.string	"Array Sum: %d\n"
.LC2:
	.string	"Maximum: %d\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB26:
	.cfi_startproc
	endbr64
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	mov	edx, 30
	mov	edi, 2
	xor	eax, eax
	lea	rsi, .LC0[rip]
	call	__printf_chk@PLT
	mov	edx, 150
	lea	rsi, .LC1[rip]
	xor	eax, eax
	mov	edi, 2
	call	__printf_chk@PLT
	mov	edx, 25
	lea	rsi, .LC2[rip]
	xor	eax, eax
	mov	edi, 2
	call	__printf_chk@PLT
	xor	eax, eax
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE26:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 15.2.0-16ubuntu1) 15.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
