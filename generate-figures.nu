#!/usr/bin/env nu

def main [] {
    for repo in (open projects.nuon) {
        print -n $"(ansi erase_line)generating figure of ($repo)\r"

        python plot.py $repo (
            {
                parent: $repo
                stem: "history"
                extension: "nuon"
            } | path join
            | open
            | upsert when {|it|
                $it.date - (date now)
                | into duration --convert day
                | str replace " day" ""
                | into decimal
                | math round
            }
            | to json
        ) (
            date now | format date "%Y-%m-%dT%H:%M:%S"
        ) ({
            parent: $repo
            stem: "history"
            extension: "png"
        } | path join)
    }
}

