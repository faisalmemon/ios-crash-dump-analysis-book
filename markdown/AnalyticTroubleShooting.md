# Analytic Troubleshooting

This chapter discusses a formal technique for solving problems.  The idea is to provide a framework that prompts the right questions to be asked.

There is a famous phrase cautioning us on taking an overzealous approach:

> "Don't use a sledgehammer to crack a nut."

Most problems have a direct and obvious way forward to progress towards their resolution.  As engineers, developers, and testers, we are well acquainted with such problem solving.  This chapter does not concern those types of problems.

There is another less well-known phrase:

> "When you hold a hammer, everything looks like a nail."

A hammer is best for hammering in nails, and smashing things generally, but not useful for other types of task.  A hammer is a solution to a restricted set of problems.
Furthermore, our way of thinking about problems is framed to the available tools at our disposal.  If we increase the available tools, we can start thinking about problems in different ways, one of which may lead to the answers we desire.

Suppose we had a spanner and a hacksaw in our toolbox.  We wanted to remove an old bathroom fitting held in place with rusty bolts.  Using the spanner might not work, due to the bolts not turning.  However, using a hack saw to remove the bolt heads might be a workable next best solution.  Observing an experienced plumber, or mechanic, reveals such tricks of the trade.

In this context, we introduce "Analytic Troubleshooting".  @kepnertregoe
This will help us move forwards on problems when the obvious things have already been tried, and we are running out of ideas.

This methodology is a cut-down version of that taught by Kepner Tregoe.

## Prioritizing our problem

If we are a sole developer of an app, perhaps with a few customers, and receive a crash report, it can feel like we are being offered a curious intellectual challenge.

In a professional software engineering context, the reality is starkly different.  There is typically a team of people involved, we are some levels removed from the customer, and there are many different crash reports from different customers, for different products and product variants.

We have to prioritize which crash to work on.  We can consider three different aspects of the problem: Seriousness, Urgency and Growth.

### Prioritizing based upon impact

In many development teams, crashes are considered top-priority "P1" bugs because the customer can no longer do anything further with the app.  To judge the seriousness of the bug, we need to assess the **impact** of the bug.  What use cases were being done at the time of the problem?  

If the customer is in the middle of doing an e-commerce purchase, then clearly revenue is at stake if the problem is not solved.  

If whilst updating our privacy settings, we see a crash, we have a privacy issue.  Depending on the type of market we are operating in, that could be a major problem.

One way to assess impact is to build analytics into our app.  Then the set of steps, and more broadly, the customer use case, can be studied alongside the crash.  Crashes from the most important use cases can then be identified as high impact bugs to fix.  One advantage of third party crash reporting services, described in a later chapter, is that they allow logs to be recorded that are delivered to the crash report server along with the crash.

Any time a life-cycle event occurs, such as foregrounding, backgrounding, appearing, disappearing, button clicks, segues, notifications, alert pop ups, and launching helper components such as the photo picker, a log message should record the action.

### Prioritizing based upon deadlines

To judge the urgency of a bug fix, we need to assess the **deadline** associated with the bug.  Whenever Apple updates their product line, for example, historically iPhone\index{trademark!iPhone} is updated in September, then a natural product lifecycle cadence is seen in the market.  New customers will come to the App Store to provision new apps.  There will be a lot of discussion of Apple product features in the press.  Consequently, it becomes a good market window to target.  Any crash that prevents app store approval or app first time use issues becomes more important at this time.  Occasionally, Apple introduces a new app category, for example watch apps, or sticker packs.  Being available on the first day provides a first-mover advantage, and the possibility of being featured as part of the Apple launch event.

### Prioritizing based upon trend

The growth in the number of crash reports we see can be alarming, and needs to be assessed by analyzing the **trend**.  We can see how many crash reports we get over time, and see if there is a spike, or an upward trend.  

If our app crashes due to features in a new major release of iOS then the first people to experience the problem are early adopters of the beta releases of iOS.  After that, iOS devices will start being automatically upgraded.  Sometimes the new version of iOS is released in geographic staggered updates.  We would expect to see this reflected in the trend we see amongst our crash reports.  

If we see a spike (a sharp rise and then a sharp fall) in our crash reports, then there may be other factors of components of the system architecture in play.  For example, if our app relies on a back-end server that is updated in a problematic way for our app, we could see crashes until the server has been fixed.

The timing of problems can be awkward.  For example, when dealing with security credentials such as certificates, it is best to set their expiry date not during traditional vacation periods (such as Christmas or Chinese New Year) because when they expire, there might be few staff available to rectify the problem.

It is bad practice to release a major software update prior to a popular vacation period.  If our market opportunity requires the product be released for a vacation period, staffing needs to be setup to accommodate potential problems.

Keeping an eye on trends allows us to schedule work to fix problems before they become widespread amongst our customers.  Different apps have different risk profiles.  For example, a Mobile Device Management API sensitive app should be tested with Beta versions of iOS because at the systems level, subtle changes can have dramatic impact and need to be picked up early.  If we have a graphics sensitive app, then we should keep an eye on new hardware devices, hardware specification updates, and we should have a test suite that exercises the key APIs in the platform we depend upon, so a new OS version, or hardware platform, can be quickly assessed.

The crash report trend need not be adverse.  If an unusual crash is seen only on older hardware, then we expect the trend to be downwards over time, so it might be possible to de-prioritize such crashes.

## Stating the problem

The information we have for a crash: the crash report, customer logs, analytic data etc. should be summarized into an OBJECT / DEFECT style short problem statement.  This is often a critical first step in triaging a potentially large number of crash reports.  This gives us a first level approximation of what is at hand and allows managers and other interested parties to get a feel for where we are with product quality, maturity, risks, etc.

First, we state the object of the problem. That is the app, or product, that is failing.  Then, we state the defect. That is the "undesirable behavior" we see.  It should be as simple as "CameraApp Lite  crashes during when Apple Share button event used".  The problem should be tracked in a bug management system.

## Specifying the problem

Specifying the problem is the most important step in the Analytic Troubleshooting methodology because here we see the gaps in our knowledge, and that prompts the questions that lead us forwards to a resolution.

We write out a large grid with four rows and two columns as follows:

Item|IS|IS NOT
--|--|--
WHAT|Seen|Not Seen
WHERE|Seen|Not Seen
WHEN|Seen|Not Seen
EXTENT|Seen|Not Seen

Analytical Troubleshooting works well in a team setting.  By having some domain experts, together with people from other disciplines, and non-technical staff, makes for a good troubleshooting team.  Experts sometimes overlook asking the basic questions, and less informed staff could ask good clarifying questions that further shake out implicit assumptions in the problem specification.  Hot customer problems can cause anxiety, so having the team come together to troubleshoot can ease tensions and build morale.  Sometimes our customer can be invited to participate; that can often speed up the process and shake out even more assumptions.

When troubleshooting as a team, we can just use a whiteboard divided up into a grid as above.  Each person can be given a handout that enumerates the questions to ask for each box within the grid.

On the web site associated with this book are support materials and handouts for Analytic Troubleshooting.  @icdabgithub

When troubleshooting on our own, having a print out of the questions and writing up a grid of answers is a good approach.
Being away from our computer, and making a list of items to check is good because it can remove the immediate impulse to dive into details.  Instead, once we have our list of items for follow up, we can prioritize our work.

We fill out details in the IS column first.  Then we fill out the IS NOT column.  Often we notice a big blank area in the grid where we have no data.  That is a signal for us to go and collect more data or do research.  The idea is to make  _relevant_ differences between the IS and IS NOT columns as small as possible.  This allows us to develop a good hypothesis that we can test, or perhaps a number of hypotheses we can prioritize for testing.

Any potential solution to the problem must entirely explain **all** the IS and IS NOT parts of the problem specification.  Often the first solution we think of only explains part of the pattern of defects seen in the problem specification.  Spending a little more time thinking about potential causes, or doing a little more research can be a good investment of time particularly if it is difficult or time-consuming to try out different candidate solutions.

We have an understanding of the system specification and its behavior when operating within those constraints.  In practice, the system evolves over time with new software and hardware releases.  Therefore, we must keep going back to primary information sources, and perform experimentation to refine this understanding.  This allows us to discover good questions, and allows us to develop a hypothesis.  There is normally a positive feedback loop here between asking questions, learning about our system, and then discovering new relevant questions.

### Questions to ask

- WHAT IS
  - What things have a problem?
  - What is wrong with them?  
- WHAT IS NOT
  - What things could have a problem but don't?
  - What could be wrong but is not?  
- WHERE IS
  - When the problem was noticed, where was it geographically?
  - Where is the problem on the thing?  
- WHERE IS NOT
  - Where could the thing be when we should have seen the problem but did not?
  - Where could be problem be on the thing but isn't?  
- WHEN IS
  - When was the problem first noticed?
  - When has the problem been seen again?
  - Is there any pattern in the timing?
  - When in the lifecycle of the thing was the problem first noticed?  
- WHEN IS NOT
  - When could the problem have been noticed but wasn't?
  - When could it have been seen again but wasn't?
  - When else in the lifecycle of the thing could the problem be seen but wasn't?  
- EXTENT IS
  - How many things have the problem?
  - What is the extent of the defect?
  - How many defects are on the thing?
  - What is the trend?  
- EXTENT IS NOT
  -  How many things could have the problem but don't?
  -  What could be the extent of the problem but isn't?
  -  How many defects could be present but aren't?
  -  What could the trend be but isn't?  

## Example problem specifications

The problem specification questions seem unusual at first, and awkwardly phrased.  Looking at some practical examples helps explain things more clearly.  Here will use different hypothetical examples to focus in on particular questions but we don't do the full suite of questions on any given example, for the sake of brevity.

### CameraApp What Is / Is Not Example

Consider the problem "The Camera App crashes when the customer presses the Apple Share Button"

- WHAT IS
  - What things have a problem?
    - Version 1.4.5 of CameraApp on iOS 10.1, 10.2, 10.3.
    - On the main thread.
    - Function isAllowedToShare()
    - Apple Share Button  
  - What is wrong with them?
    - The share button causes the app to crash.  
- WHAT IS NOT
  - What things could have a problem but don't?
    - Version 1.4.4 of CameraApp on iOS 9.3.5
    - The background thread never has a crash.
    - Other functions for startup and photo taking work ok.
    - Taking a photo button works.  
  - What could be wrong but is not?
    - Other buttons could cause a crash but those work ok.
    - We don't see any system pop up errors.

To make progress we need to match up and tighten the IS and IS NOT answers.  We look at the IS NOT section first as this is often the side of the grid that is fairly empty and requires some thought and inspiration to come up with extra IS NOT answers that are relevant to the IS section.

The obvious thing to find out is if app version 1.4.4 works on iOS 10.x.

iOS 10.x is a major update to iOS 9.3.5, so its specification and requirements on apps will differ.  Therefore, the next thing to look at is the "What's New" section in the Apple documentation to see at a high level what is new in iOS 10.x over 9.x.  That will prompt us to ask clarifying questions.  

If 10.x requires apps to have certain `Info.plist` settings then in our grid above we can explain any `Info.plist` differences in our Camera App, as well as `Info.plist` differences with other Apps known to work on iOS 10.x and 9.x that do sharing.

In this example the share button is broken.  We could get some sample code that uses the share button and see if it crashes in a similar environment to our problem.  We could test the code in a standalone app, as well as grafted into our Camera App to see if it works there.

In this example, we only said system pop ups did not appear.  How about console messages?  We might find that tell us the reason why the system is crashing our app.

A candidate solution would be "iOS 10.x requires different `Info.plist` settings in order for sharing to work otherwise the system is specified to crash our app as we have seen."

### iMac Where Is / Is Not Example

Consider the problem "An iMac crashes regularly needing constant hardware repair."

- WHERE IS
  - When the problem was noticed, where was it geographically?
    - The Apple iMac was sitting in the first floor corner office by the window.  
  - Where is the problem on the thing?
    - The problems were electrical faults on the power supply, the screen, the main system board, and the memory chips (multiple instances of problems).  
- WHERE IS NOT
  - Where could the thing be when we should have seen the problem but did not?
    -  The same Apple iMac was fine when it was in the basement, when it was in the IT department staging area, and when it was tested at the Apple factory.  
  - Where could be problem be on the thing but isn't?
    - The problem could have been in software but wasn't.
    - The problem could have been the USB peripherals but weren't.
    - The problem could have been electrical faults in the printer, desk lamp, lights or air conditioning but wasn't.
    - The problem could have been the laptop computer in the desk drawer but wasn't.  

In this example, we have many items in the IS NOT column.  Immediately it feels like we can think about good hypotheses consequently.  Contrast this with the WHAT IS NOT section in the earlier example where we had to do a lot more research before suggesting a hypothesis.

We notice that only the iMac has a problem, not the printer.  If we swap the location of the printer and the iMac, since they are both sensitive electronic products, we could get a good contrast between IS and IS NOT.

Electronic equipment can only operate within certain specified environmental conditions.  Correct voltage, current, temperature, humidity, limited electromagnetic interference, etc. is needed.  If we do a site survey with such a requirements specification in mind, we can discover what may be the reason for this location specific issue.  We could also try with and without surge protectors since it is known that power spikes can damage electronic equipment.

### Database app When Is / Is Not Example

Consider the problem "A database app crashes during app review"

- WHEN IS
  - When was the problem first noticed?
    - App store review team was the first time we found out about the problem.  
  - When has the problem been seen again?
    - The second time we submitted the app for review.  
  - Is there any pattern in the timing?
    - The problem happens at the same amount of elapsed time since launch.  
  - When in the lifecycle of the thing was the problem first noticed?
    - The problem is always during app launch.  
- WHEN IS NOT
  - When could the problem have been noticed but wasn't?
    - The problem was never seen on the developer environment.  
  - When could it have been seen again but wasn't?
    - Subsequent launches of the app we all fine also.  
  - When else in the lifecycle of the thing could the problem be seen but wasn't?  
    - When the Update button is pressed in the app, or the target database connection string is changed, the problem is not seen.  

This is clearly an app start up issue.  This example highlights that sometimes questions in one area trigger questions and research in another area.  How clean the environment is and what configuration state it is launched with are obvious questions for the WHAT IS / IS NOT section.

One clue is found in the WHEN IS NOT section.  Database connection strings can be setup and re-configured.  It could be that a null connection string, or absent setting, or first time use setup code is not being triggered.  Maybe the code for debug builds has a hack to skip first time use workflows to speed up development of features but such features are not present in the release deployment of the app used for App Store review.

### Game app Extent Is / Is Not Example

Consider the problem "AlienGame performance issue/crash during playing different game levels"

- EXTENT IS
  - How many things have the problem?
    - 500 distinct installs of the app, out of 2000 in total.  
  - What is the extent of the defect?
    - Sometimes severe; we get a crash. Sometimes mild; we get a dropped frames.
    - Sometimes the frame rate stays good the whole time.  
  - How many defects are on the thing?
    - 5 different types of game rendering thread end up crashing (different occasions).  
  - What is the trend?
    - A slight downward trend in number of crashes as our installed base grows.  
- EXTENT IS NOT
  - How many things could have the problem but don't?
    - It could be all installs, or no installs that have a problem, but we see 25%.
  - What could be the extent of the problem but isn't?
    - We never see the frame rate drop and then improve.
    - We never see good installs ever hitting the crash problem or dropped frame problem.  
  - How many defects could be present but aren't?
    - We never see the main thread crash.
    - Of the 6 types of rendering thread, one is special because it has never been seen in a crash or dropped frame rate.  
  - What could the trend be but isn't?
    - The trend could be the crashes become more commonplace (going above 25%) but we don't.
    - The trend could be the crashes only occur on certain days, but that is not the case.  

This example is harder to understand.  We need an understanding of the architecture of the app to ask good questions.  Some clues appear.  There are 6 types of rendering thread, one of whom is fine.  In addition, the main thread is fine.  We need to explore the relevant differences between them.

When we have a problem that does not always happen, one strategy is to think about what could make the problem worse, and thus happen more frequently.  Then when we have a candidate solution we can set a confidence threshold for the fix given that we are able to induce the otherwise rare or less frequent problem.

Another clue is that 25% of installs have the problem.  If the problem was due to the population of different hardware and thus varying hardware capability, we could see that about 25% of users are on iPad versus iPhone.  However, being strictly a 25% problem without it varying is a marker to tell us maybe something else in the environment is affecting the behavior of the app.  Perhaps during installation, a server is picked in round-robin fashion amongst four servers that host the back-end for the game.  Furthermore, during development, perhaps the server used is a special development server different from production servers used by our customers.  Again, the IS NOT section provides the most revealing clues as to where to look for a potential solution.

If we did not do Analytic Troubleshooting, in this example the first instinct would be to check for memory leaks, memory pressure, hardware limitations, etc.  That kind of analysis can easily consume a week of engineering effort.  Whilst it is possible for such issues to result in dropped frames that would not fully explain the pattern of defects we see; they would not explain why exactly 25% of users hit the problem.

## The 2018 MacBook Pro T2 Problem

This section describes a problem with 2018 MacBook Pro computers that were crashing.
The narrative has been built up from discussion group postings of affected users @macbookproT2
and media reports @appleinsiderimacpro

**Problem Description:** 2018 MacBook Pro computers crash during sleep with a Bridge OS Error.

- WHAT IS
  - What things have a problem?
    - MacBook Pro Mid 2018 (13-inch, 15-inch)
    - iMac Pro
    - iBridge2,1
    - iBridge2,3
    - A configuration instance with USB devices connected
    - A configuration instance with no USB devices, waking from sleep
    - A configuration instance with no USB devices but the power adapter, waking from sleep
    - A configuration instance with legacy kernel extensions (xboxcontroller)
    - A configuration instance with xboxcontroller removed (less frequent crash)
    - macOS high sierra 10.13.6, with supplemental update, from erase disk and clean install
    - Crash during sleep
    - `panic: ANS2 Recoverable Panic - assert failed`
    - `panic: macOS watchdog detected`
    - `panic: x86 global reset detected`
    - `panic: x86 CPU CATERR detected`
    - An instance with DiskUtility->First Aid crypto_val errors
    - An instance with erased disk to remove crypto_val errors
    - Fully replaced MacBook Pro hardware with same customer configuration
    - Mid 2018 MacBook Pro with Power Nap disabled
    - Not touching the Touch Bar still has the sleep/wake problem
  - What is wrong with them?
    - System restarts following a Bridge OS panic
    - Computer gets hot
    - Disk checking fails
    - Peripherals are woken up spuriously
- WHAT IS NOT
  - What things could have a problem but don't?
    - MacBook Pro Mid 2017 models or older MacBook Pros
    - iBridge1,1
    - MacBook Pro booted in Safe Mode
    - iPad, iPhone, Apple Watch
  - What could be wrong but is not?  
    - It's never a panic whilst the computer is actively running
    - It's never a problem during booting
    - It's never a problem when the system is being shutdown by user
- WHERE IS
  - When the problem was noticed, where was it geographically?
    - At customer premises
    - On desks, and in laptop bags
  - Where is the problem on the thing?
    - In the T2 chip (watchOS-derived) BridgeOS operating system software
- WHERE IS NOT
  - Where could the thing be when we should have seen the problem but did not?
    - Apple hardware validation facilities (presumably - only Apple knows)
  - Where could be problem be on the thing but isn't?  
    - On the main CPU/board
    - On boot loaders
    - On Multimedia chips and Network chips (these have their own OS)
- WHEN IS
  - When was the problem first noticed?
    - After about 30 minutes of sleep, then waking the computer
  - When has the problem been seen again?
    - Randomly, say 5 instances in a day or week
  - Is there any pattern in the timing?
    - Always after a sleep, after at least around 30 minutes
  - When in the lifecycle of the thing was the problem first noticed?
    - After customer purchase and installation of software
    - After re-installs
    - After re-erase and install
- WHEN IS NOT
  - When could the problem have been noticed but wasn't?
    - At Apple assembly and validation facilities (presumably - only Apple knows)
  - When could it have been seen again but wasn't?
    - At returns department for handed back equipment (presumably - only Apple knows)
  - When else in the lifecycle of the thing could the problem be seen but wasn't?
    - Never during active use of the computer
- EXTENT IS
  - How many things have the problem?
    - By indirect measurement, amongst iMac Pro service returns, 4 of 103 see the problem
  - What is the extent of the defect?
    - Kernel panic, likely only one type of panic, maybe three
  - How many defects are on the thing?
    - Single instance kernel panic failure
  - What is the trend?
    - Repeats again after a random future sleep period, sometimes less frequent without peripherals
- EXTENT IS NOT
  -  How many things could have the problem but don't?
    - There is a boot loader, main Operating System, and other electronic parts which never see a problem
  -  What could be the extent of the problem but isn't?
    - It could be sustained panic after panic crashes but this is not seen.
    - It could be a one time panic per machine, but panics are seen again
  -  How many defects could be present but aren't?
    - It could be warning or informational messages but we instead only have a panic
  -  What could the trend be but isn't?
    - The problem for each customer is randomly frequent but never increasing or decreasing


### Analysis of failures

The above information resembles what we often see in hard problems.  There is a lot of data in the WHAT IS column.

The key first conclusion is that the problem must be the newer T2 chip used in iMac Pro and MacBook Pro.  The pattern of defects and the actual panic (in Bridge OS that runs on the T2 chip) make this clear.

The second point is that the volume of failures is low.  The iMac Pro is a low volume computer compared to the MacBook Pro so the problem most likely could have been seen during iMac Pro production but wasn't due to it being a low probability failure.

We see the problem is never during boot up, orderly shutdown, heavy usage.  This is interesting because during hardware validation computers are generally stress tested to shake out problems.  They are not normally left in a sleep state to see if they still perform wake up functions.  Therefore, it is possible that there is a testing strategy gap.

Replacement hardware still has the same problem for customers.  This is a helpful sign because it shows the stability of the defect.  Over time, Apple will collect computers known to have the problem, so their faulty batch of computers, to do validation on, improves dramatically.

A major gap in the above data set is there are no `pmset` logs.  These provide detailed sleep/wake behavior logs.

A potentially key data point is that a customer, using Safe Mode boot, never saw the problem.  Is there something special about Safe Mode boot in respect of how Bridge OS behaves?

It seems that 30 minutes is a key figure in the sleep time.  There may be a threshold at 30 minutes, perhaps to go into a deep sleep rather than a quick nap.

One strategy for understanding the problem is to make it occur more frequently.  For example, it might be possible to make the computer very quickly go into deep sleep.  That may make the problem appear after say 30 seconds, instead of randomly after 30 minutes of sleeping.

If the problem can be made more frequent then an automated system test could be written.  Then any fix to the Bridge OS would have a robust test suite to validate it.

We do not have the source code of the Bridge OS.  It would be interesting to discern the different between the three crashes seen.
For example, sometimes there is a case statement of 20 possible faults, and only one is being entered.  This reveals something about WHERE IS NOT in the problem specification.

We do not have machine fault register information.  When a low level problem occurs, the processor documentation will allow the system architect to look up exactly the kind of failure (timeouts, parity errors, etc.)  In our problem specification, we need to be more precise WHERE the problem is.  The BridgeOS may just be a canary telling us of a problem elsewhere.  Some customers have received a full hardware replacement, but still see the problem.  It indicates a software problem.

Intel have described an update in their architecture where a CATERR signal can be sent instead of IERR or MCERR. @intelrob
So a update in specification could mean system software is no longer aligned, and thus BridgeOS needs updating.

An approach would be to follow the Intel debugging guide @intelrob.  It has many good suggestions.  When BridgeOS sees a problem, it should be updated to print out the relevant diagnostic registers.
