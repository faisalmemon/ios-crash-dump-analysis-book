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

Another complementary approach for analysing and proactively avoiding crashes is to run the Code Analyser.
This is invoked using Command-Shift-B

In the sample app `icdab_sample` the Analyser reports:

```
/Users/faisalm/dev/icdab/source/icdab_sample/icdab_sample/macAddress.m:22:12:
 warning: Null pointer argument in call to string length function
    assert(strlen(nullPointer) == 0);
```

and conveniently marks up your source code

![](screenshots/analyser_null.png)

For a large project that has never had an Analysis report done, the output can be overwhelming.
There will be some noise in the report but it generally does a good job.  There will be duplication in the report because certain classes of error will repeat throughout the code.

If you are developing code using the Agile software methodology, then it is possible to frame the report as potential backlog items that can be worked upon during the time allocated for refactoring and maintenance.

In a large software project refactoring and maintenance should be around 20% of the work in a Sprint.  Different viewpoints arise in this area.  The author recommends doing such work alongside the normal development activities so long as no high risk changes are amongst the work being done.  For risky changes, leave that till after a major update of the app has been done.  There is usually a lull where planning and strategy is developed following a release which allows a convenient software engineering window to tackle such matters.

#### iOS QuickEdit App Case Study

Where the analyser identifies potential crashes, from an economic point of view it is good investment to fix the problem.  For example in the case of the QuickEdit iOS App, about 1 million lines of Objective-C, with 70 000 daily active users, the analyser was run and found 13 clear crashing issues.  We created one engineering story ("Fix top analyser errors").  All 13 issues were fixed in the same day with testing taking two more days.  Crashes are a top complaint from customers.  Bugs found in the field typically are 20 times the effort and cost compared those found in development.  With a large population of users, potentially experiencing a severe crash bug, the cost of those 13 bugs could be 20 * 3 days = 60 days wasted effort.  

QuickEdit due to its age only used manual reference counting in Objective-C.  Despite this it had a reliability of 99.5% based on app analytics.  Only about 5% of engineering effort was needed to maintain this stability over time once the initial issues had been addressed.

### Process Methodology

One way to drive out crashes from your app, particularly when you are in a large organisation, is to factor it in your software development process.

When a developer proposes a code change in a pull request, get the developer to ensure no new analyser warnings are introduced.  You might consider the analyser report as a robotically generated code review available to you for free.

When code is committed to a feature branch, have the automated tests run on it, with different diagnostics settings set.  This can shake out problems automatically.

Before each release, schedule time to run some specific user cases under the memory profiler (Xcode instruments will be covered later on) to look at memory usage or other key metrics.  Record the highlights such as the peak memory usage as well as the profile file.  Then when the following release is made you have a yardstick to see how things have changed both quantitatively and qualitatively.

## The Middle Road

Most software developers know what they "should" be doing; clean code, proper tests, code reviews, etc.

We recommend to take a measured approach.  There is a time for hacking together a sample app to understand a concept.  There is a time to write a prototype which just needs to prove a business use case.  There is a time to write heavily trusted code used by many people.

We take the view that maximising economic impact is the one that matters most because most developers are involved in professional software development.

We recommend:

- For Sample apps and concept exploration, just code the app.
- For Prototype development, just use the Execution Methodology when you hit problems.
- For Product development, from the beginning run the Analyser regularly and informally incorporate it into your workflow when you see something important.  From the beginning write tests but selectively where you get big impact.
- Team based product development.  Here add in the Process Methodology.  Start becoming comprehensive with Testing.
