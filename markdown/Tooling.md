# Tooling

## Overview

We have a rich set of tools available to assist crash dump analysis.  When used properly they can save a huge amount of time.

Xcode provides much help out of the box.  But using and comprehending the information Xcode tools provide is daunting.  In later chapters we go through examples showing the use of such tools.

Additionally there are command line tools provided as standard in macOS.  These are helpful when used in particular usage scenarios when you already know what you want to find out.  We shall go through specific scenarios and show how the tools are used.

Next come software tools that help you reverse engineer programs.  Sometimes you cannot get your program to work with a third party library.  Aside from looking at Documentation or raising a Support Request, it's possible to do some investigation yourself using these tools.

## Reverse Engineering

Reverse engineering is where you take an already built binary (such as an application, library, or helper process daemon), and work out how it was engineered to work.  For example:

- what are the lifecycles of the objects it is provided?
- what checks does it do on objects?
- what files or resources does it depend on?
- why did it return a failure code?

You generally do not want to know everything, only something specific to help build a hypothesis which you will test related to the crash dump you are dealing with.

How far should you go with reverse engineering and how much money and time to invest in it is a good question.  We offer the following recommendation.

- If you are just starting your application developer journey or you have limited funds, then just stick with the standard Xcode tooling, macOS command line, and the open source class-dump tool.
- If you are a professional application developer, strongly consider buying a commercial reverse engineering tool.  The one that draws most attention is Hopper; it provides a lot of functionality offered by IDA Pro (a high end tool).  It is well priced and can pay for itself in gained productivity even if only used a handful of times.  We show how Hopper can be used in this book.
- If you are a professional penetration tester, reverse engineer, or security researcher, then you will be probably wanting to invest in the top of the line software tool, IDA Pro.  The tool costs thousands but is often purchased as an company wide expense.

## Class Dump Tool

One of the great things about the Objective-C runtime is that it carries lots of rich program structure information in its built binaries.  These allow the dynamic aspects of the language to work.  In fact its flexibility of dynamic dispatch is a source for many crashes.

We recommend installing the `class-dump` tool right away because we shall reference its usage in later chapters.  See @class-dump-tool

The class dump tool allows us to look at what Objective C classes, methods and properties are present in a given program.
