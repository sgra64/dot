# colorize prompt from arguments
function CLR() {
    for k in "$@"; do
        local col=${COLORS["$k"]}
        [ $col ] && printf "\e["${col}"m" || printf "%s" "$k"
    done
}

# return (echo) branch name "[main]" or clock "[20:08]" with coloring
function branch_or_clock_colored() {
    # fetch branch name, stackoverflow: "Show just the current branch in Git"
    local brn=$(git symbolic-ref --short HEAD 2>/dev/null)
    # color prompt
    [ "$PN" ] && CLR blue $(echo $PN) white "~" low-white "[" purple $brn low-white "]" \
            || CLR low-white "($(date '+%H:%M'))"
}

# return (echo) PS1 prompt with coloring
function prompt_colored() {
    CLR low-green "\# " low-green "\u@$SYS_NAME " "\$(branch_or_clock_colored) " low-yellow "$(echo \$P1)" low-white
}
