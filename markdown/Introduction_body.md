This book fills a gap that has emerged between Application Developers and the platform they are developing for when a crash occurs.  The mindset of the Application developer is largely understanding high-level concepts and abstractions.  When a crash occurs, you can often feel rudely transported into a command line UNIX world of low level constructs, pointers and raw data.

We focus exclusively on the Apple ecosystem.

We cover macOS\index{trademark!macOS}, tvOS\index{trademark!tvOS}, watchOS\index{trademark!watchOS} and BridgeOS\index{trademark!BridgeOS} platforms, ARM\index{trademark!ARM} Assembly, and C (CoreFoundation), Objective-C\index{trademark!Objective-C}, and Objective-C++\index{trademark!Objective-C++} and Swift\index{trademark!Swift} programming languages.  This is because the older languages are more prone to crash bugs.  Real world applications tend to end up being a hybrid between the safer Swift language and older technologies.

We assume you have at least an introductory knowledge of iOS programming and software engineering, and have access to a Mac with Xcode.

The approach we take is to combine three different perspectives on the problem to give a rounded and robust view of the situation and how to resolve it.

Our first perspective is to deliver a HOW-TO guide for using the excellent tooling available from Apple.

Our second perspective is to provide a discussion of software engineering concepts tailored to preventing and resolving crashes.

Our third perspective is to offer a formal problem-solving approach but applied to crash analysis.

Programming literature comprehensively has documented software engineering concepts, and Apple has documented their crash dump tooling via Guides and WWDC videos.  

Formal problem solving is less discussed in software engineering circles, perhaps because it’s considered a table stakes skill for an engineer.  It is however a discipline of its own and when directly studied can only enhance the "natural" abilities that seem to mark out the "technically-minded" folks from the rest of the population.

Our goal is not the shy away from repeating knowledge we’ve probably seen or read elsewhere but instead we take the viewpoint of explaining the whole narrative in a cohesive manner.  What makes crash dump analysis hard is that significant background knowledge is often assumed in order to make room to concentrate on the particulars of a specific tool or Crash Report.  That causes a barrier to entry, which this book aims to overcome.

To complement the book, there is a website of resources which is intended to be used alongside the printed material so example projects can be setup and run by yourself and experimented with.  All references in this book are collected into the Bibliography Chapter at the end of the book.  There you will find URLs to resources,
 for example.

The GitHub website supporting the book is at @icdabgithub
