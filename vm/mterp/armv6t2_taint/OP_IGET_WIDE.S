%verify "executed"
%verify "null object"
%verify "field already resolved"
%verify "field not yet resolved"
%verify "field cannot be resolved"
    /*
     * Wide 32-bit instance field get.
     */
    /* iget-wide vA, vB, field@CCCC */
    mov     r0, rINST, lsr #12          @ r0<- B
    ldr     r3, [rSELF, #offThread_methodClassDex]    @ r3<- DvmDex
    FETCH(r1, 1)                        @ r1<- field ref CCCC
    ldr     r2, [r3, #offDvmDex_pResFields] @ r2<- pResFields
// begin WITH_TAINT_TRACKING
    bl      .L${opcode}_taint_prop
// end WITH_TAINT_TRACKING
    cmp     r0, #0                      @ is resolved entry null?
    bne     .L${opcode}_finish          @ no, already resolved
8:  ldr     r2, [rSELF, #offThread_method] @ r2<- current method
    EXPORT_PC()                         @ resolve() could throw
    ldr     r0, [r2, #offMethod_clazz]  @ r0<- method->clazz
    bl      dvmResolveInstField         @ r0<- resolved InstField ptr
    cmp     r0, #0
    bne     .L${opcode}_finish
    b       common_exceptionThrown
%break

    /*
     * Currently:
     *  r0 holds resolved field
     *  r9 holds object
     */
.L${opcode}_finish:
    cmp     r9, #0                      @ check object for null
    ldr     r3, [r0, #offInstField_byteOffset]  @ r3<- byte offset of field
    beq     common_errNullObject        @ object was null
// begin WITH_TAINT_TRACKING
    ldrd    r0, [r9, r3]                @ r0/r1<- obj.field (64-bit align ok)
    add     r3, r3, #8
    ldr     r3, [r9, r3]
    orr	    r10, r3, r10
    ubfx    r2, rINST, #8, #4           @ r2<- A
    FETCH_ADVANCE_INST(2)               @ advance rPC, load rINST
    add     r3, rFP, r2, lsl #3         @ r3<- &fp[A]
// end WITH_TAINT_TRACKING
    GET_INST_OPCODE(ip)                 @ extract opcode from rINST
// begin WITH_TAINT_TRACKING
//    stmia   r3, {r0-r1}                 @ fp[A]<- r0/r1
    str    r0, [r3, #0]
    str    r10, [r3, #4]
    str    r1, [r3, #8]
    str    r10, [r3, #12]
// end WITH_TAINT_TRACKING
    GOTO_OPCODE(ip)                     @ jump to next instruction

.L${opcode}_taint_prop:
    GET_VREG(r9, r0)                    @ r9<- fp[B], the object pointer
    SET_TAINT_FP(r3)
    GET_VREG_TAINT(r10, r0, r3)
    ldr     r0, [r2, r1, lsl #2]        @ r0<- resolved InstField ptr
    bx      lr
