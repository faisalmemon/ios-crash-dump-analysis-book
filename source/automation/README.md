# Build and Test Automation for icdab

This build and test strategy for the icdab projects is unusual because each
program is designed to have a fault.  So what our aim is to run each test
to trigger all the failures.  We never expect to see our tests actually pass.

This approach is obviously the reverse of regular projects where a test failure
would be undesired behavior.
