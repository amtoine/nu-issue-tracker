def get-page [
    repo: string
    page_size: int
    page: int
    state: string
] {
    http get ({
        scheme: https
        host: api.github.com
        path: $"/repos/($repo)/issues"
        params: {
            per_page: $page_size
            page: $page
            state: $state
        }
    } | url join)
}

export def "get issues" [
    repo: string
    --page-size: int = 100
    --state: string = "all"
    --from: int = 1
    --to: int = 9223372036854775807
] {
    mkdir $repo

    mut page_id = $from
    mut pulled = false
    while not $pulled and ($page_id <= $to) {
        let filename = ({
            parent: $repo
            stem: $page_id
            extension: "nuon"
        } | path join)

        print -n $"(ansi erase_line)pulling page ($page_id) from ($repo) to ($filename)\r"

        let page = (get-page $repo $page_size $page_id $state)
        $page | save --force $filename

        $page_id = ($page_id + 1)
        $pulled = (($page | length) < $page_size)
    }
    print $"(ansi erase_line)pulling done"
}

export def "gather issues" [
    repo: path
] {
    mut issues = []

    for file in (ls ({
        parent: $repo
        stem: '*'
        extension: "nuon"
    } | path join) | get name) {
        print -n $"(ansi erase_line)reading ($file)\r"
        $issues = ($file | open | append $issues)
    }

    $issues
}

export def "build history" [] {
    let data = $in

    let issues = (
        $data
        | default ((date now) + 1day | date format "%Y-%m-%d") closed_at
        | into datetime created_at closed_at
    )

    let dates = (
        seq date
            -b ($issues | sort-by created_at | get 0.created_at | date format "%Y-%m-%d")
            -e (date now | date format "%Y-%m-%d")
        | into datetime
    )

    let count = (
        $dates | each {|date|
            print -n $"(ansi erase_line)computing issues at ($date)\r"
            {
                date: $date
                issues: ($issues | where {|it|
                    ($it.created_at <= $date) and ($it.closed_at >= $date)
                } | length)
            }
        }
    )

    $count
}

export def "update issue tracker" [
    org: string
    repo: string
] {
    let path = ({
        parent: ([$org $repo] | path join)
        stem: "history"
        extension: "nuon"
    } | path join)

    {
        date: (date now | date format "%Y-%m-%d")
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
            | get open_issues_count
        )
    }
}
