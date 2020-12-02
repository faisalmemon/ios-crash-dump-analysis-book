### `icdab_avx` 矢量指令崩溃

当在使用翻译运行应用程序的 Apple Silicon Mac 上遇到英特尔 AVX 矢量指令\index{Vector instruction!AVX} 时，我们就会崩溃。我们用一个示例应用程序 `icdab_avx  `来演示了这一点。

崩溃代码类型将为：
```
Code Type:             X86-64 (Translated)
```

崩溃类型将为`EXC_BAD_INSTRUCTION`，如下所示：\index{signal!SIGILL}
```
Exception Type:        EXC_BAD_INSTRUCTION (SIGILL)
Exception Codes:       0x0000000000000001, 0x0000000000000000
Exception Note:        EXC_CORPSE_NOTIFY

Termination Signal:    Illegal instruction: 4
Termination Reason:    Namespace SIGNAL, Code 0x4
Terminating Process:   exc handler [26823]
```

在我们的情况下，崩溃时的线程状态为：

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

应用程序二进制文件（程序文本）按如下方式加载:
```
Binary Images:
       0x1047d4000 -        0x1047d7fff
 +perivalebluebell.com.icdab-avx (1.0 - 1)
 <3D9E0DED-2C66-30EE-AC6C-7C426246332E>
 /Users/USER/Desktop/*/icdab_avx.app/Contents/MacOS/icdab_avx
```

如果我们发现Apple Silicon Mac 以这种方式使我们的应用程序崩溃，如果我们有这样的怀疑，我们可以迅速搜索任何矢量指令 \index{Vector instruction!AVX}。

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

但是，更确切地说，我们可以在崩溃时使用指令指针。
我们从崩溃的线程状态中看到，我们有：

```
  rip: 0x00000001047d56cb  rfl: 0x0000000000000206
```
我们从Binary Images中看到，该程序已加载到地址`0x1047d4000`。

使用我们在 _Symbolification_ 章节中探讨的技术，我们可以在 Hopper 中加载icdab_avx 二进制文件，将二进制文件的基址更改为`0x1047d4000`，然后转到指令指针`rip`和地址`0x00000001047d56cb`。

然后，我们看到程序集转储：
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

因此，虽然我们没有找到失败的确切指令，但是找到了出现错误的函数 `compute_delta`，它位于`runVectorOperationsButtonAction `方法中，它看起来已经被内联到这个版本二进制文件中。尽管如此，我们已经获得了足够的帮助，能够在相关区域中探索二进制文件并确定确认进行了向量操作`vmovss`。 Rosetta不支持此功能。


导致该问题的原始代码为：
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

为了避免此问题，我们应该使用一个有用的方法来检测环境是否支持 AVX\index{Vector instruction!AVX}，如下所示：
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

如果支持 AVX 版本1（并且在检索信息时没有错误），此函数返回 `true`。

