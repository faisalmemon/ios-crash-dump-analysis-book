# Startup issues

When you come to a new Xcode project and experience a crash it's hard to know where to begin.
Do you have an environment problem?  Is it a known issue?

All development platforms are known for having glitches: first time setup and first time execution corner cases.

In cases where you don't already have your bearings, diagnosing a crash from first principles is not the best approach.  Instead, it's worthwhile just working your way through a list of known cleanup and preparation steps before making the decision to investigate further.  Note, some of these issues can point to a deeper problem which should be noted and worked on as priorities permit.

Situation | Suggested steps
-- | --
App crashes on startup due to a missing resource issue | Try compiling and running other Xcode project targets.  Sometimes a master target is the one that sets up the environment as part of the build.  If so, make a note to address that later.
App crashes on startup due toa binary compatibility issue | If you've recently updated Xcode, or pulled code updates on top of a compiled project, do a Option-Command-Shift-K clean which cleans the build area of intermediates, and then re-build as normal
App crashes only on simulator | Try Hardware->Reset all content and settings.  Try iPad simulator instead of iPhone simulator and vice-versa. Sample projects are often used to explain a particular technology without regard to productisation or generality.
App crashes when at customer site | Check Wi-Fi settings or try hot-spotting your iPad to iPhone.  Sometimes network issues such as connectivity, or latency are overlooked when developing your app in your office/home environment.  Make a note to fix networking assumptions if that is the problem.
Deploying on customer device gives problems | If you cable up your laptop to the customer's device, you're probably doing a Debug release deployment.  This means push notification tokens will be the development tokens not the production tokens.  It also may mean that resource access grants (to Camera for example) are no longer valid as they may have been approved via a TestFlight or App Store version of the app previously (production version).  Try switching deployment configuration via Command-< select Run in the left panel, Info tab in the right panel, Build Configuration setting Release (not Debug).  Also manually check any resource access grants in the iPad/iPhone settings.
