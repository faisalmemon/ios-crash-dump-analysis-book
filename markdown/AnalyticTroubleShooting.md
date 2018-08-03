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

## Prioritizing our problem

If we are a sole developer of an app, perhaps with a few customers, and receive a crash report, it can feel like we are being offered a curious intellectual challenge.

In a professional software engineering context, the reality is starkly different.  There is typically a team of people involved, we are some levels removed from the customer, and there are many different crash reports from different customers, for different products and product variants.

We have to prioritize which crash to work on.  We can consider three different aspects of the problem: Seriousness, Urgency and Growth.

### Prioritizing based upon impact

In many development teams, crashes are considered top-priority "P1" bugs because the customer can no longer do anything further with the app.  To judge the seriousness of the bug, we need to assess the **impact** of the bug.  What use cases were being done at the time of the problem?  If the customer is in the middle of doing an e-commerce purchase, then clearly revenue is at stake if the problem is not solved.  If the customer is updating their privacy settings and see a crash, then privacy is a problem area.  

One way to assess impact is to build analytics into our app.  Then the set of steps, and more broadly, the customer use case, can be studied alongside the crash.  Crashes from the most important use cases can then be identified as high impact bugs to fix.  One advantage of third party crash reporting services, described in a later chapter, is that they allow logs to be recorded that are delivered to the crash report server along with the crash.

Any time a life-cycle event occurs, such as foregrounding, backgrounding, appearing, disappearing, button clicks, segues, notifications, alert pop ups, and launching helper components such as the photo picker, a log message should record the action.

### Prioritizing based upon deadlines

To judge the urgency of a bug fix, we need to assess the **deadline** associated with the bug.  Whenever Apple update their product line, for example historically iPhone\index{trademark!iPhone} is updated in September, then a natural product lifecycle cadence is seen in the market.  New customers will come to the App Store to provision new apps.  There will be a lot of discussion of Apple product features in the press.  Consequently, it becomes a good market window to target.  Any crash that prevents app store approval, or app first time use is becomes more important at this time.  Occasionally, Apple introduce a new app category, for example watch apps, or sticker packs.  Being available on the first day provides a first-mover advantage, and the possibility of being featured as part of the Apple launch event.

### Prioritizing based upon trend

The growth in the number of crash reports we see can be alarming, and needs to be assessed by analysing the **trend**.  We can see how many crash reports we get over time, and see if there is a spike, or an upward trend.  

If our app crashes due to features in a new major release of iOS then the first people to experience the problem are early adopters of the beta releases of iOS.  After that, iOS devices will start being automatically upgraded.  Sometimes the new version of iOS is released in geographic staggered updates.  We would expect to see this reflected in the trend we see amongst our crash reports.  

If we see a spike (a sharp rise and then a sharp fall) in our crash reports, then there may be other factors of components of the system architecture in play.  For example, if our app relies on a back-end server which is updated in a problematic way for our app, we could see crashes until the server has been fixed.

The timing of problems can be awkward.  For example, when dealing with security credentials such as certificates, it is best to set their expiry date not during traditional vacation periods (such as Christmas or Chinese New Year) because when they expire, there might be few staff available to rectify the problem.

It is bad practice to release a major software update prior to a popular vacation period.  If our market opportunity requires the product be released for a vacation period, staffing needs to be setup to accommodate potential problems.

Keeping an eye on trends allows us to schedule work to fix problems before they become widespread amongst our customers.  Different apps have different risk profiles.  For example, a Mobile Device Management API sensitive app should be tested with Beta versions of iOS because at the systems level, subtle changes can have dramatic impact and need to be picked up early.  If we have a graphics sensitive app, then we should keep an eye on new hardware devices, hardware specification updates, and we should have a test suite that exercises the key APIs in the platform we depend upon, so a new OS version ,or hardware platform, can be quickly assessed.

The crash report trend need not be adverse.  If an unusual crash is seen only on older hardware, then we expect the trend to be downwards over time, so it might be possible to de-prioritize such crashes.

## Stating the problem

The information we have for a crash: the crash report, customer logs, analytic data etc. should be summarised into an OBJECT / DEFECT style short problem statement.  This is often a critical first step in triaging a potentially large number of crash reports.  This gives us a first level approximation of what is at hand and allows managers and other interested parties to get a feel for where we are with product quality, maturity, risks, etc.

First we state the object; that is the app or product that is failing.  Then, we state the defect; that is the symptom that is undesirable.  It should be as simple as "CameraApp Lite  crashes during when Apple Share button event used".  The problem should be tracked in a bug management system.

## Specifying the problem

Specifying the problem is the most important step in the Analytic Troubleshooting methodology because here we see the gaps in our knowledge, and that prompts the questions that lead us forwards to a resolution.

We write out a large grid with four rows and two columns as follows:

Item|IS|IS NOT
--|--|--
WHAT|Seen|Not Seen
WHERE|Seen|Not Seen
WHEN|Seen|Not Seen
EXTENT|Seen|Not Seen

Analytical Troubleshooting works well in a team setting.  Having some domain experts together with people from other disciplines and non-technical staff makes for a good troubleshooting team.  Experts sometimes overlook asking the basic questions, and less informed staff can ask good clarifying questions that further shake out implicit assumptions in the problem specification.  Hot customer problems can cause anxiety, so having the team come together to troubleshoot can ease tensions and build morale.  Sometimes our customer can be invited to participate; that can often speed up the process and shake out even more assumptions.

When troubleshooting as a team, we can just use a whiteboard divided up into a grid as above.  Each person can be given a handout that enumerates the questions to ask for each box within the grid.

On the web site associated with this book are support materials and handouts for Analytic Troubleshooting.  @icdabgithub

When troubleshooting on our own, having a print out of the questions and writing up a grid of answers is a good approach.  It seems that holding a pen gives us more creative freedom when sketching out possible causes to a problem.  It is even better to take ourselves away from our computer at this point.  We can always make notes on items to chase up. Once we have our list of items, immediately it can become clear the best way to spend our time.

We fill out details in the IS column first.  Then we fill out the IS NOT column.  Often we notice a big blank area in the grid where we have no data.  That is a signal for us to go and collect more data or do research.  The idea is to make  _relevant_ differences between the IS and IS NOT columns as small as possible.  This allows us to develop a good hypothesis that we can test, or perhaps a number of hypotheses we can prioritize for testing.

Any potential solution to the problem must entirely explain **all** the IS and IS NOT parts of the problem specification.  Often the first solution we think of only explains part of the pattern of defects seen in the problem specification.  Spending a little more time thinking about potential causes, or doing a little more research can be a good investment of time particularly if it is difficult or time-consuming to try out different candidate solutions.

Quite often, the reason for unexpected behavior is our lack of knowledge about how things ought to be setup and prepared for the Operating System.  Doing research in the technology space around the problem area is critical to do alongside the actual problem solving.  We need a strong understanding of the requirements specification for the subsystem being exercised during our problem.  This allows us to discover good questions, and allows us to develop a hypothesis.  There is normally a positive feedback loop here between asking questions, learning about our system, and then discovering new relevant questions.

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
    - The problem could have been the USB peripherals but wasn't.
    - The problem could have been electrical faults in the printer, desk lamp, lights or air conditioning but wasn't.
    - The problem could have been the laptop computer in the desk drawer but wasn't.  

In this example, we have many items in the IS NOT column.  Immediately it feels like we can think about good hypotheses as a consequence.  Contrast this with the WHAT IS NOT section in the earlier example where we had to do a lot more research before suggesting a hypothesis.

We notice that only the iMac has a problem, not the printer.  If we swap the location of the printer and the iMac, since they are both sensitive electronic products, we could get a good contrast between IS and IS NOT.

Electronic equipment can only operate within certain specified environmental conditions.  Correct voltage, current, temperature, humidity, limited electromagnetic interference, etc. are needed.  If we do a site survey with such a requirements specification in mind, we can discover what may be the reason for this location specific issue.  We could also try with and without surge protectors since it is known that power spikes can damage electronic equipment.

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
- EXTENT IS NOT
  -  How many things could have the problem but don't?
    - It could be all installs, or no installs that have a problem, but we see 25%.  
  -  What could be the extent of the problem but isn't?
    - We never see the frame rate drop and then improve.
    - We never see good installs ever hitting the crash problem or dropped frame problem.  
  -  How many defects could be present but aren't?
    - We never see the main thread crash.
    - Of the 6 types of rendering thread, one is special because it has never been seen in a crash or dropped frame rate.  
  -  What could the trend be but isn't?
    - The trend could be the crashes become more commonplace (going above 25%) but we don't.
    - The trend could be the crashes only occur on certain days, but that is not the case.  

This example is harder to understand.  We need an understanding of the architecture of the app to ask good questions.  Some clues appear.  There are 6 types of rendering thread, one of whom is fine.  Also the main thread is fine.  We need to explore the relevant differences between them.

When we have a problem that does not always happen, one strategy is to think about what could make the problem worse, and thus happen more frequently.  Then when we have a candidate solution we can set a confidence threshold for the fix given that we are able to induce the otherwise rare or less frequent problem.

Another clue is that 25% of installs have the problem.  If the problem was due to the population of different hardware and thus varying hardware capability, we could see that about 25% of users are on iPad versus iPhone.  However, being strictly a 25% problem without it varying is a marker to tell us maybe something else in the environment is affecting the behaviour of the app.  Perhaps during installation, a server is picked in round-robin fashion amongst 4 servers that host the back-end for the game.  Furthermore, during development, perhaps the server used is a special development server different from production servers used by our customers.  Again, the IS NOT section provides the most revealing clues as to where to look for a potential solution.

If we did not do Analytic Troubleshooting, in this example the first instinct would be to check for memory leaks, memory pressure, hardware limitations, etc.  That kind of analysis can easily consume a week of engineering effort.  Whilst it is possible for such issues to result in dropped frames they are only a portion of the problem scenario we are in; they would not explain why exactly 25% of users hit the problem.
