	.file	"saxpy_cpu.c"
	.intel_syntax noprefix
	.text
	.p2align 4
	.globl	saxpy_cpu
	.type	saxpy_cpu, @function
saxpy_cpu:
.LFB23:
	.cfi_startproc
	endbr64
	vmovaps	xmm2, xmm0
	test	edi, edi
	jle	.L14
	lea	eax, -1[rdi]
	cmp	eax, 6
	jbe	.L8
	mov	ecx, edi
	vbroadcastss	ymm1, xmm0
	xor	eax, eax
	shr	ecx, 3
	sal	rcx, 5
	.p2align 5
	.p2align 4
	.p2align 3
.L4:
	vmovups	ymm0, YMMWORD PTR [rsi+rax]
	vfmadd213ps	ymm0, ymm1, YMMWORD PTR [rdx+rax]
	vmovups	YMMWORD PTR [rdx+rax], ymm0
	add	rax, 32
	cmp	rax, rcx
	jne	.L4
	mov	eax, edi
	and	eax, -8
	mov	ecx, eax
	cmp	edi, eax
	je	.L16
	vzeroupper
.L3:
	mov	r8d, edi
	sub	r8d, ecx
	lea	r9d, -1[r8]
	cmp	r9d, 2
	jbe	.L6
	vmovups	xmm3, XMMWORD PTR [rdx+rcx*4]
	vbroadcastss	xmm0, xmm2
	vfmadd132ps	xmm0, xmm3, XMMWORD PTR [rsi+rcx*4]
	vmovups	XMMWORD PTR [rdx+rcx*4], xmm0
	test	r8b, 3
	je	.L14
	and	r8d, -4
	add	eax, r8d
.L6:
	movsxd	r9, eax
	lea	r8d, 1[rax]
	lea	rcx, 0[0+r9*4]
	vmovss	xmm0, DWORD PTR [rsi+r9*4]
	vfmadd213ss	xmm0, xmm2, DWORD PTR [rdx+rcx]
	vmovss	DWORD PTR [rdx+rcx], xmm0
	cmp	edi, r8d
	jle	.L14
	vmovss	xmm0, DWORD PTR 4[rsi+rcx]
	vfmadd213ss	xmm0, xmm2, DWORD PTR 4[rdx+rcx]
	add	eax, 2
	vmovss	DWORD PTR 4[rdx+rcx], xmm0
	cmp	edi, eax
	jle	.L14
	vmovss	xmm4, DWORD PTR 8[rdx+rcx]
	vfmadd132ss	xmm2, xmm4, DWORD PTR 8[rsi+rcx]
	vmovss	DWORD PTR 8[rdx+rcx], xmm2
.L14:
	ret
	.p2align 4,,10
	.p2align 3
.L16:
	vzeroupper
	ret
.L8:
	xor	ecx, ecx
	xor	eax, eax
	jmp	.L3
	.cfi_endproc
.LFE23:
	.size	saxpy_cpu, .-saxpy_cpu
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC2:
	.string	"y[0]=%.1f, y[3]=%.1f\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	endbr64
	sub	rsp, 8
	.cfi_def_cfa_offset 16
	mov	edi, 2
	mov	eax, 2
	vmovsd	xmm1, QWORD PTR .LC0[rip]
	vmovsd	xmm0, QWORD PTR .LC1[rip]
	lea	rsi, .LC2[rip]
	call	__printf_chk@PLT
	xor	eax, eax
	add	rsp, 8
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC0:
	.long	0
	.long	1078460416
	.align 8
.LC1:
	.long	0
	.long	1076363264
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
