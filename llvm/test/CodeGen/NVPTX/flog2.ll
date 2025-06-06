; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mcpu=sm_50 -mattr=+ptx32 -nvptx-approx-log2f32 | FileCheck --check-prefixes=CHECK %s
; RUN: %if ptxas-12.0 %{ llc < %s -mcpu=sm_50 -mattr=+ptx32 -nvptx-approx-log2f32 | %ptxas-verify -arch=sm_50 %}
target triple = "nvptx64-nvidia-cuda"

; CHECK-LABEL: log2_test
define float @log2_test(float %in) {
; CHECK-LABEL: log2_test(
; CHECK:       {
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.f32 %f1, [log2_test_param_0];
; CHECK-NEXT:    lg2.approx.f32 %f2, %f1;
; CHECK-NEXT:    st.param.f32 [func_retval0], %f2;
; CHECK-NEXT:    ret;
entry:
  %log2 = call float @llvm.log2.f32(float %in)
  ret float %log2
}

; CHECK-LABEL: log2_ftz_test
define float @log2_ftz_test(float %in) #0 {
; CHECK-LABEL: log2_ftz_test(
; CHECK:       {
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.f32 %f1, [log2_ftz_test_param_0];
; CHECK-NEXT:    lg2.approx.ftz.f32 %f2, %f1;
; CHECK-NEXT:    st.param.f32 [func_retval0], %f2;
; CHECK-NEXT:    ret;
entry:
  %log2 = call float @llvm.log2.f32(float %in)
  ret float %log2
}

; CHECK-LABEL: log2_test_v
define <2 x float> @log2_test_v(<2 x float> %in) {
; CHECK-LABEL: log2_test_v(
; CHECK:       {
; CHECK-NEXT:    .reg .b32 %f<5>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.v2.f32 {%f1, %f2}, [log2_test_v_param_0];
; CHECK-NEXT:    lg2.approx.f32 %f3, %f2;
; CHECK-NEXT:    lg2.approx.f32 %f4, %f1;
; CHECK-NEXT:    st.param.v2.f32 [func_retval0], {%f4, %f3};
; CHECK-NEXT:    ret;
entry:
  %log2 = call <2 x float> @llvm.log2.v2f32(<2 x float> %in)
  ret <2 x float> %log2
}

; --- f16 ---

; CHECK-LABEL: log2_f16_test
define half @log2_f16_test(half %in) {
; CHECK-LABEL: log2_f16_test(
; CHECK:       {
; CHECK-NEXT:    .reg .b16 %rs<3>;
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.b16 %rs1, [log2_f16_test_param_0];
; CHECK-NEXT:    cvt.f32.f16 %f1, %rs1;
; CHECK-NEXT:    lg2.approx.f32 %f2, %f1;
; CHECK-NEXT:    cvt.rn.f16.f32 %rs2, %f2;
; CHECK-NEXT:    st.param.b16 [func_retval0], %rs2;
; CHECK-NEXT:    ret;
entry:
  %log2 = call half @llvm.log2.f16(half %in)
  ret half %log2
}

; CHECK-LABEL: log2_f16_ftz_test
define half @log2_f16_ftz_test(half %in) #0 {
; CHECK-LABEL: log2_f16_ftz_test(
; CHECK:       {
; CHECK-NEXT:    .reg .b16 %rs<3>;
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.b16 %rs1, [log2_f16_ftz_test_param_0];
; CHECK-NEXT:    cvt.ftz.f32.f16 %f1, %rs1;
; CHECK-NEXT:    lg2.approx.ftz.f32 %f2, %f1;
; CHECK-NEXT:    cvt.rn.f16.f32 %rs2, %f2;
; CHECK-NEXT:    st.param.b16 [func_retval0], %rs2;
; CHECK-NEXT:    ret;
entry:
  %log2 = call half @llvm.log2.f16(half %in)
  ret half %log2
}

; CHECK-LABEL: log2_f16_test_v
define <2 x half> @log2_f16_test_v(<2 x half> %in) {
; CHECK-LABEL: log2_f16_test_v(
; CHECK:       {
; CHECK-NEXT:    .reg .b16 %rs<5>;
; CHECK-NEXT:    .reg .b32 %r<3>;
; CHECK-NEXT:    .reg .b32 %f<5>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.b32 %r1, [log2_f16_test_v_param_0];
; CHECK-NEXT:    mov.b32 {%rs1, %rs2}, %r1;
; CHECK-NEXT:    cvt.f32.f16 %f1, %rs2;
; CHECK-NEXT:    lg2.approx.f32 %f2, %f1;
; CHECK-NEXT:    cvt.rn.f16.f32 %rs3, %f2;
; CHECK-NEXT:    cvt.f32.f16 %f3, %rs1;
; CHECK-NEXT:    lg2.approx.f32 %f4, %f3;
; CHECK-NEXT:    cvt.rn.f16.f32 %rs4, %f4;
; CHECK-NEXT:    mov.b32 %r2, {%rs4, %rs3};
; CHECK-NEXT:    st.param.b32 [func_retval0], %r2;
; CHECK-NEXT:    ret;
entry:
  %log2 = call <2 x half> @llvm.log2.v2f16(<2 x half> %in)
  ret <2 x half> %log2
}

; --- bf16 ---

; CHECK-LABEL: log2_bf16_test
define bfloat @log2_bf16_test(bfloat %in) {
; CHECK-LABEL: log2_bf16_test(
; CHECK:       {
; CHECK-NEXT:    .reg .pred %p<2>;
; CHECK-NEXT:    .reg .b16 %rs<2>;
; CHECK-NEXT:    .reg .b32 %r<9>;
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.u16 %r1, [log2_bf16_test_param_0];
; CHECK-NEXT:    shl.b32 %r2, %r1, 16;
; CHECK-NEXT:    mov.b32 %f1, %r2;
; CHECK-NEXT:    lg2.approx.f32 %f2, %f1;
; CHECK-NEXT:    mov.b32 %r3, %f2;
; CHECK-NEXT:    bfe.u32 %r4, %r3, 16, 1;
; CHECK-NEXT:    add.s32 %r5, %r4, %r3;
; CHECK-NEXT:    add.s32 %r6, %r5, 32767;
; CHECK-NEXT:    setp.nan.f32 %p1, %f2, %f2;
; CHECK-NEXT:    or.b32 %r7, %r3, 4194304;
; CHECK-NEXT:    selp.b32 %r8, %r7, %r6, %p1;
; CHECK-NEXT:    { .reg .b16 tmp; mov.b32 {tmp, %rs1}, %r8; }
; CHECK-NEXT:    st.param.b16 [func_retval0], %rs1;
; CHECK-NEXT:    ret;
entry:
  %log2 = call bfloat @llvm.log2.bf16(bfloat %in)
  ret bfloat %log2
}

; CHECK-LABEL: log2_bf16_ftz_test
define bfloat @log2_bf16_ftz_test(bfloat %in) #0 {
; CHECK-LABEL: log2_bf16_ftz_test(
; CHECK:       {
; CHECK-NEXT:    .reg .pred %p<2>;
; CHECK-NEXT:    .reg .b16 %rs<2>;
; CHECK-NEXT:    .reg .b32 %r<9>;
; CHECK-NEXT:    .reg .b32 %f<3>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.u16 %r1, [log2_bf16_ftz_test_param_0];
; CHECK-NEXT:    shl.b32 %r2, %r1, 16;
; CHECK-NEXT:    mov.b32 %f1, %r2;
; CHECK-NEXT:    lg2.approx.ftz.f32 %f2, %f1;
; CHECK-NEXT:    mov.b32 %r3, %f2;
; CHECK-NEXT:    bfe.u32 %r4, %r3, 16, 1;
; CHECK-NEXT:    add.s32 %r5, %r4, %r3;
; CHECK-NEXT:    add.s32 %r6, %r5, 32767;
; CHECK-NEXT:    setp.nan.ftz.f32 %p1, %f2, %f2;
; CHECK-NEXT:    or.b32 %r7, %r3, 4194304;
; CHECK-NEXT:    selp.b32 %r8, %r7, %r6, %p1;
; CHECK-NEXT:    { .reg .b16 tmp; mov.b32 {tmp, %rs1}, %r8; }
; CHECK-NEXT:    st.param.b16 [func_retval0], %rs1;
; CHECK-NEXT:    ret;
entry:
  %log2 = call bfloat @llvm.log2.bf16(bfloat %in)
  ret bfloat %log2
}

; CHECK-LABEL: log2_bf16_test_v
define <2 x bfloat> @log2_bf16_test_v(<2 x bfloat> %in) {
; CHECK-LABEL: log2_bf16_test_v(
; CHECK:       {
; CHECK-NEXT:    .reg .pred %p<3>;
; CHECK-NEXT:    .reg .b16 %rs<3>;
; CHECK-NEXT:    .reg .b32 %r<19>;
; CHECK-NEXT:    .reg .b32 %f<5>;
; CHECK-EMPTY:
; CHECK-NEXT:  // %bb.0: // %entry
; CHECK-NEXT:    ld.param.b32 %r1, [log2_bf16_test_v_param_0];
; CHECK-NEXT:    mov.b32 {%rs1, %rs2}, %r1;
; CHECK-NEXT:    cvt.u32.u16 %r2, %rs2;
; CHECK-NEXT:    shl.b32 %r3, %r2, 16;
; CHECK-NEXT:    mov.b32 %f1, %r3;
; CHECK-NEXT:    lg2.approx.f32 %f2, %f1;
; CHECK-NEXT:    mov.b32 %r4, %f2;
; CHECK-NEXT:    bfe.u32 %r5, %r4, 16, 1;
; CHECK-NEXT:    add.s32 %r6, %r5, %r4;
; CHECK-NEXT:    add.s32 %r7, %r6, 32767;
; CHECK-NEXT:    setp.nan.f32 %p1, %f2, %f2;
; CHECK-NEXT:    or.b32 %r8, %r4, 4194304;
; CHECK-NEXT:    selp.b32 %r9, %r8, %r7, %p1;
; CHECK-NEXT:    cvt.u32.u16 %r10, %rs1;
; CHECK-NEXT:    shl.b32 %r11, %r10, 16;
; CHECK-NEXT:    mov.b32 %f3, %r11;
; CHECK-NEXT:    lg2.approx.f32 %f4, %f3;
; CHECK-NEXT:    mov.b32 %r12, %f4;
; CHECK-NEXT:    bfe.u32 %r13, %r12, 16, 1;
; CHECK-NEXT:    add.s32 %r14, %r13, %r12;
; CHECK-NEXT:    add.s32 %r15, %r14, 32767;
; CHECK-NEXT:    setp.nan.f32 %p2, %f4, %f4;
; CHECK-NEXT:    or.b32 %r16, %r12, 4194304;
; CHECK-NEXT:    selp.b32 %r17, %r16, %r15, %p2;
; CHECK-NEXT:    prmt.b32 %r18, %r17, %r9, 0x7632U;
; CHECK-NEXT:    st.param.b32 [func_retval0], %r18;
; CHECK-NEXT:    ret;
entry:
  %log2 = call <2 x bfloat> @llvm.log2.v2bf16(<2 x bfloat> %in)
  ret <2 x bfloat> %log2
}

declare float @llvm.log2.f32(float %val)

declare <2 x float> @llvm.log2.v2f32(<2 x float> %val)

declare half @llvm.log2.f16(half %val)

declare <2 x half> @llvm.log2.v2f16(<2 x half> %val)

declare bfloat @llvm.log2.bf16(bfloat %val)

declare <2 x bfloat> @llvm.log2.v2bf16(<2 x bfloat> %val)

attributes #0 = {"denormal-fp-math"="preserve-sign"}
