
# triage

Tools to Aid in Debugging Issues Across R Sessions

## Description

(More SODD but this is useful IRL, too.)

Sometimes things work in one R session and not another. Eventually, this
will be a package with a set of functions that help make easier to
identify the reasons behind such things.

For now, it has one utility, an R script and/or function that can be run
to — as non-invasively as possible — dump all salient info to a JSON or
RDS file so they can be compared to each other.

Eventually, it will provide methods to perform comparisons across triage
files.

It (on purpose) has minimal dependencies (`methods`, `utils` and
`jsonlite`).

## Contributions

Ideas, feedback, issues, questions, features, PRs, etc are all welcome.
Use GH issues for comms and ensure you document yourself in
`DESCRIPTION` in PRs and identify how you’d like to be named in the
`DESCRIPTION` if you file bug reports.

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.

## What’s Inside The Tin

You can either:

    source(system.file("scripts", "triage.R", package="triage"))

for automatic usage that creates and executes an anonymous function and
doesn’t require any components of the package to be loaded, or use this
function like so:

    triage::triage()

and have the flexibility of supplying parameters at the expense of a
tiny bit of environment pollution.

The following bits are colected and — where possible — tidied:

  - environment variables
  - options settings
  - R version & platform information
  - Base packages
  - Other packages
  - Loaded pacakges
  - Object names, sizes and classes in the global environement,
    including hidden ones

NOTE: This is a *dangerous* function since the output may contain
**sensitive data**, including, but not limited to, API keys or other
credentials. Do not share carelessly.

Either the script or the function will shunt the collected info out to a
file and return the filename via a `message()` so you know where to find
it if you did not specify a filename on your own.

The following functions are implemented:

  - `triage`: Collect and export triage
    info

## Installation

``` r
devtools::install_github("hrbrmstr/triage")
```

klokjmkllo

## Usage

``` r
triage::triage()
```

    ## Warning in triage::triage(): NOTE: The triage file may contain sensitive data in R data structures, including API keys.
    ## Review contents carefully before sharing.

    ## Triage data: [/var/folders/9g/ptzggj090rv89mwc7nrhhfhh0000gn/T//RtmpgM8CjY/triage_8ecb36c0c57a.json]

Use @timelyportfolio’s
[`listviewer`](https://github.com/timelyportfolio/listviewer), RStudio’s
new data viewer (use `jsonlite::fromJSON()` first) ,
[`jq`](https://stedolan.github.io/jq/) or a text editor to review the
JSON files (you can load the RDS files easily into R as well) until
comparison functions are provided.
