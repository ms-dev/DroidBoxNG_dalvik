%verify "executed"
%include "armv6t2_taint/unopNarrower.S" {"instr":"bl      __aeabi_d2f"}
