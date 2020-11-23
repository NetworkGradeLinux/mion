# Contributing to Network Grade Linux

Welcome to the Network Grade Linux(NGL) community!

Here we cover some of the basics of how you can get involved and contribute,
including links to more in-depth information.

If you're looking for a quick-start guide, it's in the [README](README.md). For
more general documentation and to find out what the project is all about, head
over to our documentation page at <https://docs.mion.io>.

Have Questions? What to get a sense of our growing community? Our Slack channel
is <https://networkgradelinux.slack.com>

## Table of Contents

[Code of Conduct](#code-of-conduct)

[Things to Know First](#things-to-know-first)

[How to Contribute](#how-to-contribute)

[Getting in Touch](#getting-in-touch)

## Code of Conduct

All contributors are expected to read and agree to our [Code of Conduct](CODE_OF_CONDUCT.md)
and our [interpretation](https://docs.mion.io/Coc-interpretation.html). By
contributing to the project, you acknowledge that you agree to follow it. For
questions regarding the Code of Conduct, please contact a maintainer or <ben@ageofpeers.com>

## Things to know first

While prerequisites will vary depending on what you plan on contributing,
in general, you should know:

* [The Yocto Project](https://docs.yoctoproject.org/)
  * [Introduction and overview](https://docs.yoctoproject.org/overview-manual/overview-manual-intro.html)
  * [Quick Build](https://docs.yoctoproject.org/brief-yoctoprojectqs/brief-yoctoprojectqs.html)

* [Git Workflow](https://github.com/NetworkGradeLinux/mion-docs/blob/dunfell/_meta/git_commandments.md)
  * [Yocto Project Git Workflow](https://docs.yoctoproject.org/overview-manual/overview-manual-development-environment.html#git-workflows-and-the-yocto-project)
  * [OpenEmbedded Commit Messages and Patches](http://www.openembedded.org/wiki/Commit_Patch_Message_Guidelines)

## How to Contribute

Network Grade Linux(NGL) has a number of elements which make up the project.
At the core of NGL is mion, the network operating system; an Embedded Linux
distribution built by using the Yocto Project/OpenEmbedded.

After identifying what and where you wish to contribute, become familiar with
our workflow. Our workflow is largely the same across all the repositories, and
is largely inline with The Yocto Project and OpenEmbedded. Currently our default
branch is "Dunfell", which is where branches will be merged.

You will also need to have a github account.

### Project Components

Here's an overview of our repositories:

* [mion](https://github.com/NetworkGradeLinux/mion); the main repository, where
  the build script can be found, as well as sub-modules from the Yocto Project.

* [meta-mion](https://github.com/NetworkGradeLinux/meta-mion); the mion Yocto
  Project distro layer. Distro configuration for mion can be found here.
  
* [meta-mion-bsp](https://github.com/NetworkGradeLinux/meta-mion-bsp); board
  Support Layers, This is where you can find support for switch hardware, taking
  the form of `meta-mion-<VENDOR>`.

* [mion-docs](https://github.com/NetworkGradeLinux/mion-docs); our main
  documentation source, where the pages on <https://docs.mion.io/> come from.
  The style guide, and other information on contributing, can be found under
  the `_meta` directory. Documentation is a great place to get started and gain
  practice with our workflow. Additionally, [mion-docs/README.md](https://github.com/NetworkGradeLinux/mion-docs/blob/dunfell/README.md)
  goes into more detail for anyone new to using git to contribute to Open Source
  projects.
  
### Bugs Reports & Feature Requests

An overview of current issues and development tasks, from bugs to enhancements
can be viewed at: <https://github.com/orgs/NetworkGradeLinux/projects/1>. If
you're interested in being assigned one of the existing issues, feel free to
comment on the issue or get in touch with one of the maintainers.

For creating a new issue, you will need to be added to one of
the project teams for NGL.

### Git workflow

We provide a **brief overview** on our workflow and key aspects below.

To start, make sure that git is configured with your name and the email
associated with your git account. Additionally, make sure that your github
account is set up to use 2FA.

After cloning the repository you plan on contributing to, create a branch named
`username/short-discription`. For example, if your username on github is
"pygmyshew" and you're updating information in a README:

```shell
git checkout -b pygmyshew/update-README
```

#### Commits

After making the changes and you're ready to commit, you will want to include a
signoff to help verify that it is you who is contributing. You can do so
automatically by using the git  `--signoff` option. It's also good practice to
set up a GPG key on github for signing your commit. After it's set up, you can
use the `-S` option for git.

```shell
git commit -S --signoff
```

This will open a editor where you type your commit message. Please read the
information on git workflow under [Things to Know First](#things-to-know-first)
for more in-depth guidelines for commit messages. In short, use the imperative
in the first line to mention what your commit addresses. For example: "Update
mion README for 0.9.1 changes". After a blank newline, you can add more details
on what you changed, but you should leave out the "how". After another newline,
tag the issue number that the commit addresses or applies to.

Push your branch:

```shell
git push -u origin pygmyshew/update-README
```

If you've made multiple commits before being ready to open a pull request, you
must use git rebase to squash/fixup all the commits into one. It's also good
practice to `git pull` first to make sure your development branch is up to date
and that there're no conflicts.

### Pull Requests

After pushing your commit to the branch, you can put in a pull request. Make
sure to tag and assign a maintainer for review of the pull request. After a pull
request is approved and merged into the default branch, delete your development
branch. Maintainers may request that you resubmit your pull request if it does
not follow the guidelines.

## Getting in Touch

The best way to get in touch is by using our Slack channel: [Slack channel](https://networkgradelinux.slack.com).
Due to differences in time zones and work loads, we may not be able to respond
immediately, but will get back to you as soon as possible. Even if you don't
have a question, feel free to join and chat!
