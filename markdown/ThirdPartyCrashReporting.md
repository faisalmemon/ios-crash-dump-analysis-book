# Third Party Crash Reporting

This chapter discusses alternatives to the Apple provided Crash Reporting solution.

The Apple Crash Reporter tool, and supporting infrastructure in iTunes Connect\index{trademark!iTunes Connect} is excellent but has some room for improvement.

A formidable piece of Open Source software, plcrashreporter, has been written by Landon Fuller, of Plausible Labs.

@plcrashreporter

The idea is to make our app handle all the possible signals and exceptions that can occur that would otherwise be unimplemented by the app and thus lead to the underlying Operating System to handle the crash.

With this solution, the crash data can be recorded, and then later communicated to a server of our own choice.

There are two benefits.  Firstly, the crash handler can be fixed to handle edge cases not already handled by the Apple ReportCrash tool.  Secondly, a more comprehensive server side solution can be employed.

When an company has many apps, many app variants, and has apps based on competitor platforms such as Android\index{trademark!Android}, a more powerful multi-platform solution is needed.  Handling crash reports soon becomes a management problem.  Which crash is the most serious?  How many customers are affected?  What are my metrics for quality and stability?

A number of commercial solutions are available, largely based upon the above Open Source project.
