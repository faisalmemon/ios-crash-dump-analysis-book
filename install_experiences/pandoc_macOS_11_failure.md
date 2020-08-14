# Setup for a new Mac

These setup instructions are to setup an Intel Mac running Big Sur 11.0 Beta (20A5323l).

## Install Xcode

Use Xcode 12 beta 4 from https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_12_beta_4/Xcode_12_beta_4.xip

### Clone project source code

Set up your Apple ID in Xcode, and add an application access token from github.  Then setup a public/private key pair with `ssh-keygen -t rsa` pressing Return when asked for a passphrase.  Copy the `.ssh/id_rsa.pub` to github.

Then from Xcode I do a clone of:
`git@github.com:faisalmemon/private-cda-0.git`

## Install Package Manager

Brew package manager requires Xcode tools from the earlier step since it needs to compile source code packages.

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

### Install required packages

#### Build failure on pandoc

`brew install pandoc pandoc-citeproc`

pandoc won't install on macOS 11

```
==> Installing pandoc dependency: cabal-install
==> Patching
==> Applying b6f7ec5f3598f69288bddbdba352e246e337fb90.patch
patching file bootstrap.sh
==> sh bootstrap.sh --sandbox
Last 15 lines from /Users/testsecure/Library/Logs/Homebrew/cabal-install/01.sh:
#warning You are configuring this package without cabal-doctest installed. \
 ^
1 warning generated.
[1 of 1] Compiling Main             ( Setup.hs, Setup.o )
Linking Setup ...
clang: warning: -Wl,-headerpad_max_install_names: 'linker' input unused [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-L/usr/local/lib' [-Wunused-command-line-argument]
clang: warning: argument unused during compilation: '-L/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.0.sdk/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries' [-Wunused-command-line-argument]
Configuring lukko-0.1.1...
Setup: Encountered missing or private dependencies:
base >=4.5 && <4.14


Error during cabal-install bootstrap:
Configuring the lukko package failed.

Do not report this issue to Homebrew/brew or Homebrew/core!

These open issues may also help:
Cabal v1 install deprecation https://github.com/Homebrew/homebrew-core/issues/55253

Error: You are using macOS 11.0.
We do not provide support for this pre-release version.
You will encounter build failures with some formulae.
Please create pull requests instead of asking for help on Homebrew's GitHub,
Discourse, Twitter or IRC. You are responsible for resolving any issues you
experience while you are running this pre-release version.
```

### Yet to do a mactex install

`brew cask install mactex`

## Install class dump tool

Use link http://stevenygard.com/download/class-dump-3.5.dmg

## Atom editor

Not available on Big Sur since it crashes.

## Bibdesk citation tool

Installs ok

