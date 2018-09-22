# Quick Start

When an application crash appears after a recent code change, it can be straightforward to reason about the crash and look at the relevant code changes.  Often, crashes just appear due to a change in operating environment.  Those can be the most annoying.  For example, the app runs fine in the Office but crashes at the customer Site.  We don't have time to get into why, but need a quick fix or workaround.  Another common problem scenario arises when a new project is being explored.  This is where we have no prior experience with the code base but immediately face crash problems after compilation and running the app.

In this chapter, we explore possible reasons for crashing due to a change in operating environment.  Many problems can be dealt with without getting into logical analysis of the specifics of the problem at hand.  In reality sometimes we just need to make progress, whilst making a note to go back and address the root cause.

## Troubleshooting

### Missing resource issue

Sometimes our app crashes on startup due to a missing resource\index{crash!missing resource} issue.

We should try compiling and running other Xcode\index{trademark!Xcode} targets within the same project.  Sometimes a specific target is the one that sets up the needed environment as part of the build.  If so, we can make a note to address that later.

### Binary compatibility issue

Sometimes our app crashes on startup due to a binary compatibility\index{crash!binary compatibility} issue.

If we've recently updated Xcode, or pulled code updates on top of a compiled project, we can perform an Option-Command-Shift-K clean which cleans the build area of intermediates, and then re-build as normal.

### Simulator only issue
Sometimes our app crashes only on simulator\index{crash!simulator only}.

Here we should try Simulator Hardware->Reset all content and settings.  We can try iPad\index{trademark!iPad} simulator instead of iPhone\index{trademark!iPhone} simulator or vice-versa. Sample projects are often used to explain a particular technology without regard to productisation or generality.

### Site specific issues

Sometimes our app only crashes when at customer site\index{crash!site specific}.

We can check Wi-Fi\index{Wi-Fi} settings or try hot-spotting our iPad to an iPhone.  Sometimes network issues such as connectivity\index{network!connectivity}, or latency\index{network!latency} are overlooked when developing our app in the office/home environment.  We should make a note to fix networking assumptions if that is the problem.

### Customer device deployment issues

Sometimes our app only crashes when deployed onto a customer device.

If we cable up our laptop to the customer's device, we're probably doing a
Debug\index{deployment!debug} release deployment.  This means push notification tokens will be the development tokens not the production tokens.  It also may mean that resource access grants (to Camera for example) are no longer valid as they may have been approved via a TestFlight\index{trademark!TestFlight} or App Store version of the app previously (production version).

We should try switching deployment configuration via Command-< selecting Run in the left panel, Info tab in the right panel, Build Configuration setting
Release\index{deployment!release}
(not Debug).  We should also manually check any resource access grants in the iPad/iPhone settings.

### Locale specific issues

Sometimes deploying with the customer's locale\index{crash!locale} causes a crash.

Resource files might be absent in the wrong locale.  Furthermore, locale handling is rife with undocumented special cases.  We should try changing the locale temporarily to a known working one.  Make a note to return to the issue when back in the office.

## The Crash Mindset

One take away lesson from the above examples is that we need to think of our code in a wider context.  We should think of the operating environment\index{operating environment} of our app.  This comprises:

- the compiled code
- binary incompatibilities between code modules (different language versions, compilers and toolchains)
- resource files bundled or downloaded into the app
- the build configuration (e.g. Release or Debug)
- the network environment, availability/latency/speed
- permissions granted to the app
- permissions denied to the app (in a Mobile Device Management secured environment)
- platform variants
- orientation
- foreground and background operating modes
- hardware performance (old slow hardware versus faster newer devices)
- hardware components (GPU, Memory, CPU, accessories, etc.)
- geographic location related issues
- locale issues
- presence of diagnostics settings
- presence of a debugger or profiler
- the OS version of the target device

As a first step in getting into the correct mindset to tackle app crashes, its worthwhile working through each of the above operating environment differences and trying to note down if such a difference ever resulted in a crash that we know about or suspect could happen.  This teaches us that crashes are much more about **environment** than about **source code**.  Another secondary insight is that the more able we are to produce a list of hypotheses given a specific environment difference, the more easily and quickly we will be able to find the root cause of crashes that seem mysterious to other people, and almost magical that we came up with a suggestion of where the problem could be.

Here are some curious examples of crashes from the Information Technology folklore to whet our appetite and get us thinking:

### Locale based Crash

The Russian locale caused a crash during date processing.

This was because 1984-04-01 was being used as a sentinel date marker.  However, in Russia, there is no such date/time because there is no midnight at that point in time.  Daylight time started in Russia on that date with a +1 hour.

This was seen during development of the WecudosPro iPad app when it was tested in Russia


### Geographic Location Crash

A computer was crashing each day at a different time.

The actual problem was the computer was near a window next to an estuary where ships passed by.  At high tide, a military ship would sail past and its RADAR would disrupt the electronics and cause a crash.

This folklore story was told to Sun Microsystems\index{trademark!Sun Microsystems} Answer Center engineers in the UK during Kepner-Tregoe\index{trademark!Kepner-Tregoe} formal problem solving training.


### Bus Noise Crash

When a computer was under both heavy network load, and disk load, the system would crash.

The crash was due to corruption on disk.  There were zeroes every 64 bytes.  It was the cache line size of the computer.  The memory board was not wired up correctly causing noise at 64 byte boundaries picked up by the disk ribbon cable sitting next to it.

This was seen in an early prototype of a Sun Volume Systems Group computer.
