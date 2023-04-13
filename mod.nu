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
