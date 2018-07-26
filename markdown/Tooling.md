# Tooling

## Overview

We have a rich set of tools available to assist crash dump analysis.  When used properly they can save a huge amount of time.

Xcode provides much help out of the box.  However, using and comprehending the information Xcode tools provide is daunting.  In later chapters, we go through examples showing the use of such tools.

Additionally there are command line tools provided as standard in macOS\index{macOS}\index{trademark!macOS}.  These are helpful when used in particular usage scenarios when we already know what we want to find out.  We shall go through specific scenarios and show how the tools are used.

Next come software tools that help us reverse engineer programs.  Sometimes we cannot get our program to work with a third party library.  Aside from looking at Documentation or raising a Support Request, it's possible to do some investigation ourselves using these tools.

## Reverse Engineering

Reverse engineering is where an already built binary (such as an application, library, or helper process daemon), is studied to determine how it works.  Normally, source code not binary code is studied to determine how a program works.  For example:

- what are the lifecycles of the objects it is provided?
- what checks does it do on objects?
- what files or resources does it depend on?
- why did it return a failure code?

We generally do not want to know everything, only something specific to help build a hypothesis.
Once we have a hypothesis\index{hypothesis!development of}, we will test it in relation to the crash dump are dealing with.

How far should we go with reverse engineering, and how much money and time to invest in it is a good question.  We offer the following recommendation.

- If we are just starting our application developer journey, or we have limited funds, then just stick with the standard Xcode tooling, macOS command line, and the open source class-dump tool.
- If we are a professional application developer, we should strongly consider buying a commercial reverse engineering tool.  The one that draws most attention is Hopper\index{trademark!Hopper}; it provides a lot of functionality offered by IDA Pro\index{trademark!IDA Pro} (a high end tool).  It is well priced and can pay for itself in gained productivity even if only used a handful of times.  We show how Hopper can be used in this book.
- If we are a professional penetration tester\index{test!penetration}\index{software!penetration testing}, reverse engineer\index{software!reverse engineering}, or security researcher\index{software!security research}, then we will be probably wanting to invest in the top of the line software tool, IDA Pro.  The tool costs thousands but is often purchased as a company wide expense.

## Class Dump Tool

One of the great things about the Objective-C runtime is that it carries lots of rich program structure information in its built binaries.  These allow the dynamic aspects of the language to work.  In fact, its flexibility of dynamic dispatch is a source for many crashes.

We recommend installing the `class-dump`\index{command!class-dump} tool right away because we shall reference its usage in later chapters.  See @class-dump-tool

The class dump tool allows us to look at what Objective C classes, methods and properties are present in a given program.
