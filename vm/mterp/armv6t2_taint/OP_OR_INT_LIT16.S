%verify "executed"
%include "armv6t2_taint/binopLit16.S" {"instr":"orr     r0, r0, r1"}
