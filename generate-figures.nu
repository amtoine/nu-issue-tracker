#!/usr/bin/env nu

def main [] {
    for path in (ls **/history.nuon | get name) {
        let repo = ($path | path parse | get parent)

        print -n $"(ansi erase_line)generating figure of ($repo)\r"

        python plot.py $repo (
            $path | open
            | upsert when {|it|
                $it.date - (date now)
                | into duration --convert day
                | str replace " day" ""
                | into decimal
                | math round
            }
            | to json
        ) (
            date now | date format "%Y-%m-%d"
        ) ({
            parent: $repo
            stem: "history"
            extension: "png"
        } | path join)
    }
}

