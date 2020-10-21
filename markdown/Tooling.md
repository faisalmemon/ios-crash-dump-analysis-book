# Tooling

## Overview

We have a rich set of tools available to assist crash dump analysis.  When used properly they can save a huge amount of time.

One way to think about crash dump tools is to consider where along the software development and release cycle we are on.

At development time, we have static analysis tools in Xcode, and runtime metrics when running our app via Xcode.  When running on device, we have crash reports that explain problems.  We have Xcode diagnostics which can be switched on to instrument our app in an area of interest.  There are third party tools which we can use to look inside (Reverse Engineer\index{software!reverse engineering) our app binary to help us understand what is happening.  Furthermore, macOS\index{trademark!macOS} also provides a lot of similar functionality from the command line.   Note much of the code in our apps is either in first party frameworks, or third party libraries, for which we generally do not have the source code.

At beta time, we have the Xcode Organiser which can report on how our app is performing in the field.  Xcode retrieves performance and crash information for those beta customers that have opted-in to such data collection.  App Store Connect\index{trademark!App Store} can also provide this information.  Third party crash reporting tools and services can be employed to give further context to the problems.  Introduced in iOS 14\index{iOS!14} diagnostics are provided through the `MetricKit` framework, and this provides a first party API to obtain crash information, and other diagnostics, from our app to such third party crash reporting services.

At release time, we have similiar facilities to what is available at beta time, but we generally have bigger scale - more users, and more crash report instances.  This is usually where the more rare bugs, and unexpected user workflows, show up because we are one step further removed from our customer base.  This is where the phased release\index{software!phased release} option within App Store Connect comes in handy.

Xcode provides much help out of the box.  However, using and comprehending the information Xcode tools provide is daunting.  In later chapters, we go through examples showing the use of such tools.

## Reverse Engineering

Reverse engineering\index{software!reverse engineering} is where an already built binary (such as an application, library, or helper process daemon), is studied to determine how it works.  For a specific Object, we might want to find out:

- what are the lifecycles of the objects it is provided?
- what checks does it do on objects?
- what files or resources does it depend on?
- why did it return a failure code?

We generally do not want to know everything, only something specific to help build a hypothesis.
Once we have a hypothesis\index{hypothesis!development of}, we will test it in relation to the crash dump we are dealing with.

How far should we go with reverse engineering, and how much money and time to invest in it is a good question.  We offer the following recommendation:

- If we are just starting our application developer journey, or we have limited funds, then just stick with the standard Xcode tooling, macOS command line, and the open source class-dump tool.
- If we are a professional application developer, we should strongly consider buying a commercial reverse engineering tool.  The one that draws most attention is Hopper\index{trademark!Hopper}; it provides a lot of functionality offered by IDA Pro\index{trademark!IDA Pro} (a high end tool).  It is well priced and can pay for itself in gained productivity even if only used a handful of times.  We show how Hopper can be used in this book.
- If we are a professional penetration tester\index{test!penetration}\index{software!penetration testing}, reverse engineer\index{software!reverse engineering}, or security researcher\index{software!security research}, then we will be probably wanting to invest in the top of the line software tool, IDA Pro.  This tool costs thousands, but is often purchased as a company wide expense.

## Class Dump Tool

One of the great things about the Objective-C runtime is that it carries lots of rich program structure information in its built binaries.  These allow the dynamic aspects of the language to work.  In fact, its flexibility of dynamic dispatch is a source for many crashes.

We recommend installing the `class-dump`\index{command!class-dump} tool right away because we shall reference its usage in later chapters.  See @class-dump-tool

The class dump tool allows us to look at what Objective C classes, methods and properties are present in a given program.

## Third Party Crash Reporting

The Apple Crash Reporter tool and supporting infrastructure in App Store Connect\index{trademark!App Store} is excellent but has some room for improvement.

A formidable piece of Open Source software, `plcrashreporter`\index{command!plcrashreporter}, has been written by Landon Fuller, of Plausible Labs.  @plcrashreporter

The idea is to make our app handle all the possible signals and exceptions that can occur that would otherwise be unimplemented by the app and thus lead to the underlying Operating System to handle the crash.

With this solution, the crash data can be recorded, and then later communicated to a server of our own choice.

There are two benefits.  Firstly, the crash handler can be fixed to handle edge cases not already handled by the Apple `ReportCrash`\index{command!ReportCrash} tool.  Secondly, a more comprehensive server side solution can be employed.

For those wanting to explore, and understand, the Operating System, and low-level application code, `plcrashreporter` provides an excellent opportunity to study a well-engineered piece of system software.

When a company has many apps, many app variants, and has apps based on competitor platforms such as Android\index{trademark!Android}, a more powerful multi-platform solution is needed.  Handling crash reports soon becomes a management problem.  Which crash is the most serious?  How many customers are affected?  What are the metrics for quality and stability saying?

A number of commercial solutions are available, largely based upon the above Open Source project.

The Mobile Software Development field has grown into a big industry over the last  few years.  Many specialist companies serve App Developers as their customers.  The field is very active in terms of mergers and acquisitions.  Therefore, we cannot name the competitors in the Crash Reporting space in this book, as the list would be constantly changing.

A good place to start is the `rollout.io` blog posting that reviewed different players in the market.
@3rdpartycrashtools

We expect the pace of development to continue in this space because since iOS 14\index{iOS!14} there has been a substantial improvement in first party support for diagnostics reporting.  Firstly, there is the `MetricKit` framework which allows apps in their beta or release phase to report diagnostic information to our app.  We think of this as a well-defined conduit, whose data we would be passed onto a web service to further analyze the crash, or diagnostic condition.  This will place third party crash reporting services on an official API footing.  Secondly, the App Store Connect website overall has been made available as a web service with a public API.  This provides equivalent functionality but improves the developer workflow by allowing continuous integration systems to more deeply embed the true end-to-end lifecycle of app development.  As a hypothetical example, a CI\index{continuous integration}\index{CI} system could detect a high crash rate and push out an emergency update based on an earlier release.  This would reduce the pressure on the engineering staff to conduct an analysis of why a bad release was made, and the appropriate fix for the problem.
