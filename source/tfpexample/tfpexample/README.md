This program was adapted from http://os-tres.net/blog/2010/02/17/mac-os-x-and-task-for-pid-mach-call/

It has been modernised, and it has been changed to repeatedly perform task for pid, as well as
to trivially change the thread state.  This means that when it attaches to a process which crashes,
the crash dump will show this telltale fingerprint.

The xcode project will build a version of this program which does not have the needed privileges.
It is a convenience only while code-level development is done.

The operative binary is built by running build.sh in this directory.
The binary needs a certificate for code signing.  See the screenshots in the directory
createSelfSignedCertificate for how to do this using the Keychain app.
