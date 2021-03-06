#ifndef RAW_SYSCALL_FUNCTION
#error must define RAW_SYSCALL_FUNCTION before including this file
#endif
#ifndef SYSCALL_ENTRY_POINT
#error must define SYSCALL_ENTRY_POINT before including this file
#endif

#define ENTRY_POINT_IP .L##RAW_SYSCALL_FUNCTION##entry_point_ip

	.text
	.globl RAW_SYSCALL_FUNCTION
	.type RAW_SYSCALL_FUNCTION, @function
RAW_SYSCALL_FUNCTION:	/* syscallno = 4(%esp) */
	.cfi_startproc
	pushl %ebx	/* syscallno = 8(%esp) */
	.cfi_adjust_cfa_offset 4
	.cfi_rel_offset %ebx, 0
	pushl %esi	/* syscallno = 12(%esp) */
	.cfi_adjust_cfa_offset 4
	.cfi_rel_offset %esi, 0
	pushl %edi	/* syscallno = 16(%esp) */
	.cfi_adjust_cfa_offset 4
	.cfi_rel_offset %edi, 0
	pushl %ebp	/* syscallno = 20(%esp) */
	.cfi_adjust_cfa_offset 4
	.cfi_rel_offset %ebp, 0

	movl 20(%esp), %eax /* %eax = syscallno */
	movl 24(%esp), %ebx /* %ebx = a0 */
	movl 28(%esp), %ecx /* %ecx = a1 */
	movl 32(%esp), %edx /* %edx = a2 */
	movl 36(%esp), %esi /* %esi = a3 */
	movl 40(%esp), %edi /* %edi = a4 */
	movl 44(%esp), %ebp /* %ebp = a5 */

	int $0x80		/* syscall() */
	/* When the tracee is in the traced syscall, its $ip will be
	 * the value of this label.  We need to be able to recognize
	 * when the tracees are in traced syscalls. */
ENTRY_POINT_IP:

	popl %ebp
	.cfi_adjust_cfa_offset -4
	.cfi_restore %ebp
	popl %edi
	.cfi_adjust_cfa_offset -4
	.cfi_restore %edi
	popl %esi
	.cfi_adjust_cfa_offset -4
	.cfi_restore %esi
	popl %ebx
	.cfi_adjust_cfa_offset -4
	.cfi_restore %ebx
	ret
	.cfi_endproc
	.size RAW_SYSCALL_FUNCTION, . - RAW_SYSCALL_FUNCTION

	.globl SYSCALL_ENTRY_POINT
	.type SYSCALL_ENTRY_POINT, @function
SYSCALL_ENTRY_POINT:
	call .L1
.L1:
	pop %eax
	addl $(ENTRY_POINT_IP - .L1), %eax
	ret
	.size SYSCALL_ENTRY_POINT, . - SYSCALL_ENTRY_POINT

#undef ENTRY_POINT_IP
	.section .note.GNU-stack,"",@progbits
	.previous
