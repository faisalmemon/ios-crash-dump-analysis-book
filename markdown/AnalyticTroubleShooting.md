# Analytic Troubleshooting

This chapter discusses a formal technique for solving problems.  The idea is to provide a framework that prompts the right questions to be asked.

There is a famous phrase cautioning us on taking an overzealous approach:

> "don't use a sledgehammer to crack a nut"

Most problems have a direct and obvious way forward to progress towards their resolution.  As engineers, developers, and testers, we are well acquainted with such problem solving.  This chapter does not concern those types of problems.

There is another less well-known phrase:

> "when you hold a hammer, everything looks like a nail"

A hammer is best for hammering in nails, and smashing things generally, but not useful for other types of task.  A hammer is a solution to a restricted set of problems.
Furthermore, our way of thinking about problems is framed to the available tools at our disposal.  If we increase the available tools, we can start thinking about problems in different ways, one of which may lead to the answers we desire.

Suppose we had a spanner and a hack saw in our toolbox.  We wanted to remove an old bathroom fitting held in place with rusty bolts.  Using the spanner might not work, due to the bolts not turning.  However, using a hack saw to remove the bolt heads might be a workable next best solution.  Observing an experienced plumber, or mechanic, reveals such tricks of the trade.

In this context we introduce "Analytic Troubleshooting".  @kepnertregoe
This will help us move forwards on problems when the obvious things have already been tried, and we are running out of ideas.

This methodology is a cut-down version of that taught by Kepner Tregoe.

## Prioritising our problem

If we are a sole developer of an app, perhaps with a few customers, and receive a crash report, it can feel like we are being offered a curious intellectual challenge.

In a professional software engineering context, the reality is starkly different.  There is typically a team of people involved, we are some levels removed from the customer, and there are many different crash reports from different customers, for different products and product variants.

We have to prioritise which crash to work on.  We can consider three different aspects of the problem: Seriousness, Urgency and Growth.

### Prioritising based upon impact

In many development teams, crashes are considered top-priority "P1" bugs because the customer can no longer do anything further with the app.  To judge the seriousness of the bug, we need to assess the **impact** of the bug.  What use cases were being done at the time of the problem?  If the customer is in the middle of doing an e-commerce purchase, then clearly revenue is at stake if the problem is not solved.  If the customer is updating their privacy settings and see a crash, then privacy is a problem area.  

One way to assess impact is to build analytics into our app.  Then the set of steps, and more broadly, the customer use case, can be studied alongside the crash.  Crashes from the most important use cases can then be identified as high impact bugs to fix.  One advantage of third party crash reporting services, described in a later chapter, is that they allow logs to be recorded that are delivered to the crash report server along with the crash.

Any time a life-cycle event occurs, such as foregrounding, backgrounding, appearing, disappearing, button clicks, segues, notifications, alert pop ups, and launching helper components such as the photo picker, a log message should record the action.

### Prioritising based upon deadlines

To judge the urgency of a bug fix, we need to assess the **deadline** associated with the bug.  Whenever Apple update their product line, for example historically iPhone\index{trademark!iPhone} is updated in September, then a natural product lifecycle cadence is seen in the market.  New customers will come to the App Store to provision new apps.  There will be a lot of discussion of Apple product features in the press.  Consequently, it becomes a good market window to target.  Any crash that prevents app store approval, or app first time use is becomes more important at this time.  Occasionally, Apple introduce a new app category, for example watch apps, or sticker packs.  Being available on the first day provides a first-mover advantage, and the possibility of being featured as part of the Apple launch event.

### Prioritising based upon trend

The growth in the number of crash reports we see can be alarming, and needs to be assessed by analysing the **trend**.  We can see how many crash reports we get over time, and see if there is a spike, or an upward trend.  

If our app crashes due to features in a new major release of iOS then the first people to experience the problem are early adopters of the beta releases of iOS.  After that, iOS devices will start being automatically upgraded.  Sometimes the new version of iOS is released in geographic staggered updates.  We would expect to see this reflected in the trend we see amongst our crash reports.  

If we see a spike (a sharp rise and then a sharp fall) in our crash reports, then there may be other factors of components of the system architecture in play.  For example, if our app relies on a back-end server which is updated in a problematic way for our app, we could see crashes until the server has been fixed.

The timing of problems can be awkward.  For example, when dealing with security credentials such as certificates, it is best to set their expiry date not during traditional vacation periods (such as Christmas or Chinese New Year) because when they expire, there might be few staff available to rectify the problem.

It is bad practice to release a major software update prior to a popular vacation period.  If our market opportunity requires the product be released for a vacation period, staffing needs to be setup to accommodate potential problems.

Keeping an eye on trends allows us to schedule work to fix problems before they become widespread amongst our customers.  Different apps have different risk profiles.  For example, a Mobile Device Management API sensitive app should be tested with Beta versions of iOS because at the systems level, subtle changes can have dramatic impact and need to be picked up early.  If we have a graphics sensitive app, then we should keep an eye on new hardware devices, hardware specification updates, and we should have a test suite that exercises the key APIs in the platform we depend upon, so a new OS version ,or hardware platform, can be quickly assessed.

The crash report trend need not be adverse.  If an unusual crash is seen only on older hardware, then we expect the trend to be downwards over time, so it might be possible to de-prioritise such crashes.
