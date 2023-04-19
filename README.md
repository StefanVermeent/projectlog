
<!-- README.md is generated from README.Rmd. Please edit that file -->

# OSgit

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/OSgit)](https://CRAN.R-project.org/package=OSgit)  
<!-- badges: end -->

# The purpose of `projectlog`

The two core aims of `projectlog` are:

1.  Help you to easily keep track of important points in your project,
    such as preregistrations, data access, and article submissions and
    revisions.
2.  Create a clear, reproducible, and verifiable history of your
    project—including major milestones—for others (e.g., reviewers or
    readers of your article).

If you are already using git in your workflow to track your changes and
share your code and materials, `projectlog` provides functionality that
automates common steps and helps you get the most out of the information
that Git stores for you. If you are not familiar with Git—or if the mere
mention of it strikes fear into your heart—then `projectlog` is set up
in a way that you rarely have to interact with Git directly.

# Before we start… Setting up Git

One of the main aims of OSgit is that it can be used by people who are
not (intimately) familiar with Git or GitHub. However, you will still
need to to three things to ensure that OSgit works properly:<br> (1)
Create a free account on [GitHub](https://github.com/join)<br> (2)
Install [Git](https://git-scm.com/downloads) on your device<br> (3) Make
sure R knows where to find git on your device<br>

These three steps are described in more detail in the Git vignette
(TBD). Note that in principle, you only have to go through these steps
once for a particular device.

# Installation

You can install the development version of `OSgit` from GitHub as
follows:

``` r
# install.packages('devtools')
devtools::install_github("StefanVermeent/OSgit")
```

# Before we start… Setting up Git

One of the main aims of OSgit is that it can be used by people who are
not (intimately) familiar with Git or GitHub. However, you will still
need to to three things to ensure that OSgit works properly:<br> (1)
Create a free account on [GitHub](https://github.com/join)<br> (2)
Install [Git](https://git-scm.com/downloads) on your device<br> (3) Make
sure R knows where to find git on your device<br>

These three steps are described in more detail in the Git vignette
(TBD).

# Main components

## Initiating an OSgit project

TBD

## Logging project milestones to GitHub

Milestones are any major update to your project that you want to give a
special tag. Examples are timestamping a preregistration, a final
version of analysis code, submission of a manuscript, etc. In other
words, milestones are the events in your project history that you want
to point out to reviewers and/or future interested readers.

Let’s say that you finished your preregistration and want to mark it as
a timestamped version in GitHub. In order to do this, you would use the
`log_milestone` function:

``` r
log_milestone("preregistrations/preregistration.md", commit_message = "Timestamped preregistration for study 1", tag = "preregistration")
#> ✔ Initializing empty, orphan 'gh-pages' branch in GitHub repo 'jane/mypackage'
#> ✔ GitHub Pages is publishing from:
#> • URL: 'https://jane.github.io/mypackage/'
#> • Branch: 'gh-pages'
#> • Path: '/'
#> ✔ Creating '.github/'
#> ✔ Adding '^\\.github$' to '.Rbuildignore'
#> ✔ Adding '*.html' to '.github/.gitignore'
#> ✔ Creating '.github/workflows/'
#> ✔ Saving 'r-lib/actions/examples/pkgdown.yaml@v2' to '.github/workflows/pkgdown.yaml'
#> • Learn more at <https://github.com/r-lib/actions/blob/v2/examples/README.md>.
#> ✔ Recording 'https://jane.github.io/mypackage/' as site's url in '_pkgdown.yml'
#> ✔ Adding 'https://jane.github.io/mypackage/' to URL field in DESCRIPTION
#> ✔ Setting 'https:/jane.github.io/mypackage/' as homepage of GitHub repo 'jane/mypackage'
```

log_milestone(“.”, commit_message = “Timestamped preregistration for
study 1”, tag = “preregistration”)


    `log_milestones` takes three arguments.
    The first argument (...) takes all the files that you want to include in this commit.
    You can use either use "." to include all currently modified files, or you can include specific files only (e.g., only the preregistration files. See `show_changes()` for an overview of all modified files).
    The second argument (commit_message) can be used to give your milestone an informative commit.
    For example, you can use the commit_message to give the reader more information about the scope and type of the preregistration.
    The third argument (tag) is a unique tag that defines this milestone.
    You should use the same tag across all milestones that achieve the same thing.
    For example, if you register three preregistrations over the course of your project, all of them should get identical tags (e.g., 'preregistration').

    OSgit does not come with predefined tags, but instead gives you the freedom to name the tags yourself.
    The only requirement is that the tag does not contain spaces and does not end with a number.
    The latter requirement is necessary because OSgit automatically appends a number to your tab if the same tag was used before.
    For example, if you've used the tag 'preregistration' before to timestamp the preregistration for your first study, and later on use the same tag again to timestamp the preregistration for your second study, OSgit will automatically change the new tag to 'preregistration1'.
    The reason for this is that Git tags need to be unique strings.
    When summarizing your project history later on, the same tags will be grouped together.

    This freedom to define your own tag comes with a trade-off: you will have to be careful that you do not make typos, and that new tags exactly match previous tags (e.g., if you use 'preregistration' at one point and 'prereg' at a later point, these will be seen as two different types of milestones).
    Below, we list some examples of tags that might come in handy for many empirical projects:

        - 'preregistration'
        - 'code'
        - 'submission'
        - 'revision'

    ## Logging regular changes to GitHub

    Aside from logging important milestones, it is good practice to regularly log changes to your repository to GitHub.
    This ensures that you can always go back to previous versions of your project, and that your code is safe if your PC crashes.
    For the most part, these intermediate changes are not important enough to be considered milestones.
    For example, they might be incremental updates to your code, bug fixes, and various intermediate versions of your manuscript.
    To log these changes, you would use the `log_changes()` function:


    ```r
    log_changes(".", commit_message = "add data exclusions to analysis script")

As you can see, `log_changes()` is very similar to `log_milestone()`.
The only difference is that `log_changes()` does not create a tag that
get’s added to the commit.

## Logging data access

One special type of milestone that OSgit allows you to log is the first
time you access certain parts of your data. It is becoming increasingly
common to conduct secondary data analyses on existing data following
open science principles. This is helped, for example, by specific
[preregistration templates for secondary data](https://osf.io/x4gzt/).
In addition, several established openly available datasets—such as the
[ABCD study](https://abcdstudy.org/)—actively encourage using the
Registered Report format. In such cases, you might want to document that
you only accessed the data after writing your preregistration or after
obtaining Stage 1 acceptance of your Registered Report. You might even
want to explore isolated parts of the data without making crucial links
between dependent and independent variables—for example, making sure
that there is enough variation in key variables. OSgit allows you to
automatically log your access to the data.

Explanation TBD

## Creating your project log

TBD
