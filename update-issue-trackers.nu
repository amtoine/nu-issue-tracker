#!/usr/bin/env nu

def "update issue tracker" [
    org: string
    repo: string
] {
    let path = ({
        parent: ([$org $repo] | path join)
        stem: "history"
        extension: "nuon"
    } | path join)

    $path | open | append ({
        date: (date now)
        issues: (
            http get ({
                scheme: https
                host: api.github.com
                path: $"/orgs/($org)/repos"
                params: {
                    per_page: 100
                    page: 1
                }
            } | url join)
            | where name == $repo
            | get open_issues_count.0
        )
    }) | save --force $path
}

def main [] {
    ls **/history.nuon | get name | each {|path|
        let repo = ($path | path parse | get parent)

        print -n $"(ansi erase_line)updating issue tracker of ($repo)\r"

        let org = ($repo | path dirname)
        let repo = ($repo | path basename)
        update issue tracker $org $repo
    }
}
