# Quick Start

When an application crash appears after a recent code change, it can be straightforward to reason about the crash and look at the relevant code changes.  Often, crashes just appear due to a change in operating environment.  Those can be the most annoying.  For example, the app runs fine in the Office but crashes at the customer Site.  You don't have time to get into why, but need a quick fix or workaround.  Another common problem is when a new project is being explored.  This is where we have no past experience with the code base but immediately face crash problems after compilation and running the app.

In this chapter we explore possible reasons for crashing due to a change in operating environment.  There are a variety of problems that can be dealt with without getting into logical analysis of the specifics of the problem at hand.  In reality sometimes you just need to make progress, whilst making a note to go back and address the root cause.

## Troubleshooting operating environment crashes

### Missing resource issue

Sometimes your app crashes on startup due to a missing resource issue.

Try compiling and running other Xcode targets within the same project.  Sometimes a specific target is the one that sets up your environment as part of the build.  If so, make a note to address that later.

### Binary compatibility issue

Sometimes your app crashes on startup due to a binary compatibility issue.

If you've recently updated Xcode, or pulled code updates on top of a compiled project, do a Option-Command-Shift-K clean which cleans the build area of intermediates, and then re-build as normal.

### Simulator only issue
Somtimes your app crashes only on simulator.

Try Simulator Hardware->Reset all content and settings.  Try iPad simulator instead of iPhone simulator and vice-versa. Sample projects are often used to explain a particular technology without regard to productisation or generality.

### Site specific issues

Sometimes your app only crashes when at customer site.

Check Wi-Fi settings or try hot-spotting your iPad to iPhone.  Sometimes network issues such as connectivity, or latency are overlooked when developing your app in your office/home environment.  Make a note to fix networking assumptions if that is the problem.

### Customer device deployment issues

Sometimes your app only crashes when deploying on a customer device gives problems.

If you cable up your laptop to the customer's device, you're probably doing a Debug release deployment.  This means push notification tokens will be the development tokens not the production tokens.  It also may mean that resource access grants (to Camera for example) are no longer valid as they may have been approved via a TestFlight or App Store version of the app previously (production version).

Try switching deployment configuration via  Command-< select Run in the left panel, Info tab in the right panel, Build Configuration setting Release (not Debug).  Also manually check any resource access grants in the iPad/iPhone settings.

### Locale specific issues

Sometimes deploying with the customer's locale causes a crash.

Resource files might be absent in the wrong locale.  Furthermore, locale handling is rife with undocumented special cases.  Try changing the locale temporarily to a known working one.  Make a note to return to the issue when back in the office.

## The Crash Mindset

One take away lesson from the above examples are that we need to think of our code in a wider context.  Think of the operating environment for your app.  This comprises:

- the compiled code
- binary incompatibilities between code modules (different language versions, compilers and toolchains)
- resource files bundled or downloaded into the app
- the build configuration (e.g. Release or Debug)
- the network environment, availability/latency/speed
- permissions granted to the app
- permissions denied to the app (in a Mobile Device Managment secured environment)
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

As a first step in getting into the correct mindset to tackle app crashes, its worthwhile working through each of the above operating environment differences and trying to note down if such a difference ever resulted in a crash that you know about or suspect could happen.  This will teach you that crashes are much more about **environment** than about **source code**.  Another secondary insight is that the more able you are to produce a list of hypotheses given a specific environment difference, the more easily and quickly you will be able to find the root cause of crashes that seem mysterious to other people, and almost magical that you came up with a suggestion of where the problem could be.

Here are some curious examples of crashes from the Information Technology folklore to whet your appetite and get you thinking:

Trigger for Crash | Reason for crash | Historical Notes
--|--|--
Locale | Only Russian locale caused a crash during date processing.  This was because 1984-04-01 was being used as a sentinel date marker.  However, in Russia, there is no such date/time because there is no midnight at that point in time.  Daylight time started in Russia on that date with a +1 hour. | This was seen during development of the WecudosPro iPad app when it was tested in Russia
Geographic Location | A computer was crashing each day; each time a different reason.  The actual problem was the computer was near a window next to a estuary where ships passed by.  At high tide, a military ship would sail past and its RADAR would disrupt the electronics and cause a crash. | This folklore story was told to Sun Microsystems Answer Center engineers in the UK during Kepner-Tregoe formal problem solving training.
Bus Noise | When a computer was under both heavy network load and disk load the system would crash to due corruption on disk.  There was always a zero very 64 bytes.  It was the cache line size of the computer.  The memory board was not wired up correctly causing noise at 64 byte boundaries picked up by the disk ribbon cable sitting next to it. | This was seen during the development of Sun Volume Systems Group prototype hardware build.
