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
	jle	.L11
	lea	eax, -1[rsi]
	cmp	eax, 6
	jbe	.L12
	mov	edx, esi
	mov	rax, rdi
	vpxor	xmm0, xmm0, xmm0
	shr	edx, 3
	sal	rdx, 5
	add	rdx, rdi
	.p2align 4
	.p2align 4
	.p2align 3
.L6:
	vpaddd	ymm0, ymm0, YMMWORD PTR [rax]
	add	rax, 32
	cmp	rdx, rax
	jne	.L6
	vextracti128	xmm1, ymm0, 0x1
	mov	eax, esi
	vpaddd	xmm1, xmm1, xmm0
	and	eax, -8
	vpsrldq	xmm0, xmm1, 8
	mov	r8d, eax
	vpaddd	xmm0, xmm1, xmm0
	vpsrldq	xmm2, xmm0, 4
	vpaddd	xmm0, xmm0, xmm2
	vmovd	edx, xmm0
	cmp	esi, eax
	je	.L17
	vzeroupper
.L5:
	mov	ecx, esi
	sub	ecx, r8d
	lea	edx, -1[rcx]
	cmp	edx, 2
	jbe	.L9
	vpaddd	xmm1, xmm1, XMMWORD PTR [rdi+r8*4]
	vpsrldq	xmm0, xmm1, 8
	vpaddd	xmm1, xmm1, xmm0
	vpsrldq	xmm0, xmm1, 4
	vpaddd	xmm0, xmm1, xmm0
	vmovd	edx, xmm0
	test	cl, 3
	je	.L3
	and	ecx, -4
	add	eax, ecx
.L9:
	movsxd	rcx, eax
	lea	r8d, 1[rax]
	vmovd	xmm1, DWORD PTR [rdi+rcx*4]
	vpaddd	xmm0, xmm0, xmm1
	vmovd	edx, xmm0
	cmp	esi, r8d
	jle	.L3
	vmovd	xmm1, DWORD PTR 4[rdi+rcx*4]
	add	eax, 2
	vpaddd	xmm0, xmm0, xmm1
	vmovd	edx, xmm0
	cmp	esi, eax
	jle	.L3
	vmovd	xmm1, DWORD PTR 8[rdi+rcx*4]
	vpaddd	xmm0, xmm0, xmm1
	vmovd	edx, xmm0
.L3:
	mov	eax, edx
	ret
	.p2align 4,,10
	.p2align 3
.L11:
	xor	edx, edx
	mov	eax, edx
	ret
	.p2align 4,,10
	.p2align 3
.L17:
	mov	eax, edx
	vzeroupper
	ret
.L12:
	vpxor	xmm1, xmm1, xmm1
	xor	r8d, r8d
	xor	eax, eax
	vmovdqa	xmm0, xmm1
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
