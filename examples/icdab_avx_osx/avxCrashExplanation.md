### `icdab_avx` vector instruction crash

When an Intel AVX vector instruction\index{Vector instruction!AVX} is encountered on a Apple Silicon Mac running the app using translation, we get a crash.  We have a sample application, `icdab_avx`, that demonstrates this.

The crash Code Type will be:
```
Code Type:             X86-64 (Translated)
```

The crash type will be `EXC_BAD_INSTRUCTION` as follows:
\index{signal!SIGILL}
```
Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
Exception Codes:       0x0000000000000001, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Illegal instruction: 4
Termination Reason:    Namespace SIGNAL, Code 0x4
Terminating Process:   exc handler [26823]
```

The thread state upon crash in our case is:

```
Thread 0 crashed with X86 Thread State (64-bit):
  rax: 0x0000000000000001  rbx: 0x0000600001fcf5c0  rcx:
 0x00007f87d143f8c0  rdx: 0x00007f87d143f8c0
  rdi: 0x00000001047d6fa0  rsi: 0x00000001047d770a  rbp:
 0x000000030d132ab0  rsp: 0x000000030d132ab0
   r8: 0x0000000000000003   r9: 0x0000000104b0e000  r10:
 0x00000001047dc702  r11: 0x00000001047d57d0
  r12: 0x00006000012d5100  r13: 0x00007fff6a9d4000  r14:
 0x00007f87d143f8c0  r15: 0x00000001047d770a
  rip: 0x00000001047d56cb  rfl: 0x0000000000000206
```

The application binary (program text) is loaded as follows:
```
Binary Images:
       0x1047d4000 -        0x1047d7fff
 +perivalebluebell.com.icdab-avx (1.0 - 1)
 <3D9E0DED-2C66-30EE-AC6C-7C426246332E>
 /Users/USER/Desktop/*/icdab_avx.app/Contents/MacOS/icdab_avx
```

If we see that an Apple Silicon Mac has crashed our app in this way, we could quickly search for any vector instructions\index{Vector instruction!AVX} if we have such a suspicion.

```
# objdump -d icdab_avx.app/Contents/MacOS/icdab_avx | grep vmov |
 head
100004527: c5 fa 10 84 24 a4 00 00 00      vmovss    164(%rsp),
 %xmm0
100004530: c5 fa 10 8c 24 a0 00 00 00      vmovss    160(%rsp),
 %xmm1
10000453f: c5 fa 10 8c 24 a8 00 00 00      vmovss    168(%rsp),
 %xmm1
10000454e: c5 fa 10 8c 24 ac 00 00 00      vmovss    172(%rsp),
 %xmm1
10000455d: c5 fa 10 8c 24 b4 00 00 00      vmovss    180(%rsp),
 %xmm1
100004566: c5 fa 10 94 24 b0 00 00 00      vmovss    176(%rsp),
 %xmm2
100004575: c5 fa 10 94 24 b8 00 00 00      vmovss    184(%rsp),
 %xmm2
100004584: c5 fa 10 94 24 bc 00 00 00      vmovss    188(%rsp),
 %xmm2
100004593: c5 f8 29 8c 24 90 00 00 00      vmovaps    %xmm1,
 144(%rsp)
10000459c: c5 f8 29 84 24 80 00 00 00      vmovaps    %xmm0,
 128(%rsp)
```

However, to be more precise, we can make use of the instruction pointer at the time of the crash.
We see that from the crashed thread state, we have:
```
  rip: 0x00000001047d56cb  rfl: 0x0000000000000206
```
and we see from Binary Images, the program was loaded at address `0x1047d4000`.

Using the techniques we explored in the _Symbolification_ chapter, we can load up the icdab_avx binary in Hopper, change the base address of the binary to `0x1047d4000` and then goto the instruction pointer, `rip`, address `0x00000001047d56cb`.

We then see the assembly dump:
```
_compute_delta:
push       rbp          ; CODE
 XREF=_$s9icdab_avx14ViewControllerC31runVectorOperationsButtonAc
tionyySo12NSButtonCellCF+32
mov        rbp, rsp
and        rsp, 0xffffffffffffffe0
sub        rsp, 0x160
mov        dword [rsp+0x160+var_A4], 0x40000000
mov        dword [rsp+0x160+var_A8], 0x40800000
mov        dword [rsp+0x160+var_AC], 0x40c00000
mov        dword [rsp+0x160+var_B0], 0x41000000
mov        dword [rsp+0x160+var_B4], 0x41200000
mov        dword [rsp+0x160+var_B8], 0x41400000
mov        dword [rsp+0x160+var_BC], 0x41600000
mov        dword [rsp+0x160+var_C0], 0x41800000
vmovss     xmm0, dword [rsp+0x160+var_BC]
vmovss     xmm1, dword [rsp+0x160+var_C0]
```

So we didn't land on the exact instruction that failed, but we did land on the function at fault, `compute_delta`, which looks to have been inlined in this Release binary due to it being within the `runVectorOperationsButtonAction` method.  Nevertheless, we've been given enough help to be able to explore the binary in the relevant area and establish confirmation that the vector operation, `vmovss` was called.  This is not supported by Rosetta.


Our original code that caused the issue was:
```
void
compute_delta() {
    /* Initialize the two argument vectors */
    __m256 evens = _mm256_set_ps(2.0, 4.0, 6.0, 8.0, 10.0, 12.0,
 14.0, 16.0);
    __m256 odds = _mm256_set_ps(1.0, 3.0, 5.0, 7.0, 9.0, 11.0,
 13.0, 15.0);
    
    /* Compute the difference between the two vectors */
    __m256 result = _mm256_sub_ps(evens, odds);
    
    /* Display the elements of the result vector */
    float* f = (float*)&result;
    printf("%f %f %f %f %f %f %f %f\n",
           f[0], f[1], f[2], f[3], f[4], f[5], f[6], f[7]);
    
    return;
}
```

In order to avoid the problem we should have used a utility function to detect if the environment supported AVX\index{Vector instruction!AVX}, as follows:
```
bool
avx_v1_supported() {
    int ret = 0;
    size_t size = sizeof(ret);
    if (sysctlbyname("hw.optional.avx1_0", &ret, &size, NULL, 0)
 == -1)
    {
       if (errno == ENOENT)
          return false;
       return false;
    }
    bool supported = (ret != 0);
    return supported;
}
```

This function returns `true` is AVX version 1 is supported (and there was no error in retrieving the information).

