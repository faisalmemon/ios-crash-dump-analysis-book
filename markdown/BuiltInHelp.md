# Xcode Built In Help

Xcode provides a lot of help to developers in understanding and preventing crashes.

We think of Xcode in layers of sophistication, where at the lowest layer of sophistication Xcode directly tells you the common error it has seen with suggested corrections, up to the highest level were Xcode is telling the raw information, but you need Operating Systems knowledge to interpret the information yourself.

We shall revisit Xcode configuration, setup and tooling many times.  But let us first start off with the simple but high value assistance Xcode provides.

## Xcode Diagnostic Settings

By opening the project `icdab_sample` @icdabgithub and looking at the Schema definition and then highlighting the Diagnostics tab we see the following options:

![](screenshots/diagnostic_settings.png)

### Execution Methodology

If you have a crash which is reproducible from your own developer environment and source code, then a methodology for finding the cause of the crash can be:

1.  Write a Unit Test Case or UI Test Case that hits the problem.
1.  Enable just one of the Diagnostic options from above.
1.  Run your tests.
1.  Take note of any warning or console message from Xcode.
1.  Repeat again but choosing a different diagnostic option if the problem is not understood.

It may feel like the above approach is somewhat of a caveman approach to software engineering.
But Apple engineering has gone to the trouble of automating the detection of most of the common types of problems seen in apps.  Whilst you are at the beginning of your crash dump analysis journey it is best just to use the out of the box tooling to see what it finds for very little effort on your behalf.

As we go deeper into the topic of crash dump analysis, we shall explore each diagnostic option more closely and at that point you will be able to make selective use of these tools according to the problem at hand.

### Analysis Methodology

Another complementary approach to analysing and proactively avoiding crashes is to run the Code Analyser.
This is invoked using Command-Shift-B

In the sample app `icdab_sample` the Analyser reports:

```
/Users/faisalm/dev/icdab/source/icdab_sample/icdab_sample/macAddress.m:22:12:
 warning: Null pointer argument in call to string length function
    assert(strlen(nullPointer) == 0);
```

and conveniently marks up your source code

![](screenshots/analyser_null.png)
