# nu-issue-tracker
A nushell tool to keep track of the issue tracker over time.

## get the previous history of repositories
if you want to keep track of the issue tracker from the beginning of the
history of a project, but do not have all the issue counts over time, you
can follow the procedure below:
```nushell
use mod.nu *

# pull the main `nushell` repos
[
    "nushell/nushell"
    "nushell/nu-ansi-term"
    "nushell/nu_scripts"
    "nushell/nushell.github.io"
    "nushell/reedline"
] | each {|repo| get issues $repo --from 1}

# `nushell/nushell` has so many pages, we can only pull the first 59 at once :eyes:
get issues "nushell/nushell" --from 60  # some time later

# gather the issues together in a single NUON file per repository
ls nushell/ | get name | each {|repo|
    gather issues $repo | select number created_at closed_at | save ({
        parent: $repo
        stem: "issues"
        extension: "nuon"
    } | path join)
}
```
