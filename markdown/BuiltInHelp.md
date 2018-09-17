# Xcode Built-In Help

Xcode provides significant help to developers in understanding and preventing crashes.

We think of Xcode in layers of sophistication, where at the lowest layer of sophistication Xcode directly tells us the common error it has seen with suggested corrections, up to the highest level were Xcode is telling the raw information, but we need Operating Systems knowledge to interpret the information ourselves.

We shall revisit Xcode configuration, setup and tooling many times.  Nevertheless, let us first start off with the simple but high value assistance Xcode provides.

## Xcode Diagnostic Settings

By opening the project `icdab_sample` @icdabgithub and looking at the Schema definition and then highlighting the Diagnostics\index{software!diagnostics} tab we see the following options:

![](screenshots/diagnostic_settings.png)

### Execution Methodology

If we have a crash that is reproducible from our own developer environment and source code, then a methodology for finding is to switch on the appropriate diagnostic setting and then re-run our application.

As we become familiar with each diagnostic, we will know which option to switch on.  We shall work through different scenarios so we understand when to use each.  But when we are just starting out its worth just going through each one-by-one to get a feel for what is available.  The basic approach is:

1.  Write a Unit Test Case or UI Test Case that hits the problem.
1.  Enable just one of the Diagnostic options from above starting with our best guess.
1.  Run our tests.
1.  Take note of any warning or console message from Xcode.
1.  Repeat again but choosing a different diagnostic option if the problem is not understood.

### Analysis Methodology

Another complementary approach for analyzing and proactively avoiding crashes is to run the Code Analyzer\index{software!static analysis}.
This is invoked using Command-Shift-B

In the sample app `icdab_sample` the Analyzer reports:

```
/Users/faisalm/dev/icdab/source/icdab_sample/icdab_sample/macAddress.m:22:12:
 warning: Null pointer argument in call to string length function
    assert(strlen(nullPointer) == 0);
```

and conveniently marks up our source code

![](screenshots/analyser_null.png)

This can be switched on for whenever the project is built, either in shallow or deep mode according to how we feel the tradeoff should be done between slower more thorough analysis versus quicker build times with less analysis.  It is in the Build Settings tab for the Xcode project file.

![](screenshots/static_analyser_build.png)

For a large project that has never had an Analysis report done, the output can be overwhelming.
There will be some noise in the report but it generally does a good job.  There will be duplication in the report because certain classes of error will repeat throughout the code.

If we are developing code using the Agile software\index{software!Agile} methodology, then it is possible to frame the report as potential backlog items that can be worked upon during the time allocated for refactoring and maintenance.

In a large software project refactoring and maintenance should be around 20% of the work in a Sprint\index{software!sprint}.  Different viewpoints arise in this area.  The author recommends doing such work alongside the normal development activities so long as no high-risk\index{software!risk} changes are amongst the work being done.  For risky changes, leave that until after a major update of the app has been done.  There is usually a lull where planning and strategy is developed following a release, which allows a convenient software engineering window to tackle such matters.

#### iOS QuickEdit App Case Study

Where the analyzer identifies potential crashes, from an economic point of view, it is a good investment to fix the problem.  For example in the case of the QuickEdit iOS App\index{trademark!QuickEdit}, about 1 million lines of Objective-C, with 70 000 daily active users, the analyzer was run and found 13 clear crashing issues.  We created one engineering story ("Fix top analyzer errors").  All 13 issues were fixed in the same day with testing taking two more days.  Crashes are a top complaint from customers.  Bugs found in the field typically are 20 times the effort and cost compared to those found in development.  With a large population of users, potentially experiencing a severe crash bug, the cost of those 13 bugs could be 20 * 3 days = 60 days wasted effort.  

QuickEdit due to its age only used manual reference counting in Objective-C.  Despite this, it had a reliability of 99.5% based on app analytics\index{software!quality}.  Only about 5% of engineering effort was needed to maintain this stability over time once the initial issues had been addressed.

### Process Methodology

One way to drive out crashes from our app, particularly when we are in a large organization, is to factor it in our software development process\index{software!development process}.

When a developer proposes a code change in a pull request, get the developer to ensure no new analyzer warnings are introduced.  We might consider the analyzer report as a robotically generated code review available to us for free.  That is particularly helpful if we are working alone on a project with no peer to review our code.

When code is committed to a feature branch, have the automated tests run on it, with different diagnostics settings set.  This can shake out problems automatically.

Before each release, schedule time to run some specific user cases under the memory profiler\index{test!memory profiling} to look at memory usage or other key metrics.  Record the highlights such as the peak memory usage as well as the profile file.  Then when the following release is made we have a yardstick to see how things have changed both quantitatively and qualitatively.

## The Middle Road

Most software developers know what they "should" be doing; clean code, proper tests, code reviews, etc.

We recommend taking a measured approach.  There is a time for hacking together a sample app to understand a concept.  There is a time to write a prototype that just needs to prove a business use case.  There is a time to write heavily trusted code used by many people.

We take the view that maximizing economic impact is the one that matters most because most developers are involved in professional software development.  Alternatively, if we are working on non-commercial projects or hobby projects, the economic cost is really our personal free time which we will want to use most effectively.

We recommend:

- For Sample apps and concept exploration, just code the app.
- For Prototype Development, just use the Execution Methodology when we hit problems.
- For Individual Product Development, from the beginning, run the Analyzer automatically and informally incorporate it into our workflow when we see something important.  From the beginning write tests but selectively where we get big impact.
- For Team-based Product Development, add in the Process Methodology.  Start becoming comprehensive with Testing.
