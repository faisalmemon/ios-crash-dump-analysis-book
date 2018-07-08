# Introduction

This book fills a gap that has emerged between Application Developers and the platform they are developing for when a crash occurs.  The mindset of the Application developer is largely understanding high level concepts and abstractions.  When a crash occurs, you can often feel rudely transported into a command line UNIX world of low level constructs, pointers and raw data.

We cover specifically the Apple ecosystem using the Swift programming language.  Our main focus is iOS but we touch upon other platforms and languages also.
The approach we take is to combine three different perspectives on the problem to give a rounded and robust view of the situation and how to resolve it.

Our three perspectives are:

1. A practical HOW-TO guide for using the excellent tooling available from Apple.
1. A discussion of software engineering concepts tailored to preventing and resolving crashes.
1. A formal problem-solving approach but applied to crash analysis.
 
Programming literature comprehensively has documented software engineering concepts, and Apple has documented their crash dump tooling via Guides and WWDC videos.  

Formal problem solving is less discussed in software engineering circles, perhaps because it’s considered a table stakes skill for an engineer.  It is however a discipline of its own and when directly studied can only enhance the “natural” abilities that seem to mark out the “technically-minded” folks from the rest of the population.

Our goal is not the shy away from repeating knowledge we’ve probably seen or read elsewhere but instead we take the view point of explaining the whole narrative in a cohesive manner.  What makes crash dump analysis hard is that significant background knowledge is often assumed in order to make room to concentrate on the particulars of a specific tool or crash report.  That causes a barrier to entry which this book aims to overcome.

@tn2151
