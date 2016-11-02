#!/bin/bash
shopt -s extglob
set -o errexit
set -o nounset
unset CDPATH

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_dir=${here#$HOME/}

files_mapping=(
    ./$config_dir/bash_alias   $HOME/.bash_alias
    ./$config_dir/bashrc       $HOME/.bashrc
    ./$config_dir/bash_profile $HOME/.bash_profile
    ./$config_dir/gitconfig    $HOME/.gitconfig
    ./$config_dir/gitignore    $HOME/.gitignore
    ./$config_dir/inputrc      $HOME/.inputrc
    ./$config_dir/profile      $HOME/.profile
    ./$config_dir/tmux.conf    $HOME/.tmux.conf
)

if [[ $(uname -s) == Darwin ]]; then
    files_mapping=("${files_mapping[@]}"
                   ./$config_dir/tmux-osx.conf $HOME/.tmux-osx.conf)
fi

keys_volume=/Volumes/Keys
mounted_evidence=KEYS_VOLUME_IS_MOUNTED

keys_mapping=(
    .keys/AWS                         .aws
    .keys/Docker/dockercfg            .dockercfg
    .keys/GitHub/github_token_bstiles .github_token_bstiles
    .keys/GnuPG                       .gnupg
    .keys/Jenkins                     .jenkins
    .keys/mitmproxy                   .mitmproxy
    .keys/netrc                       .netrc
    .keys/Papertrail/papertrail.yml   .papertrail.yml
    .keys/SSH                         .ssh
)

if [[ $(uname -s) = Darwin ]]; then
    export READLINK=readlink
else
    export READLINK='readlink -f'
fi

abort() {
    [[ $# > 0 ]] && echo "$*"
    exit 1
}

display_help() {
    cat <<EOF
usage: $(basename "$0") [opts] --with-keys|--without-keys

-n|--dry-run         Show what would be done without actuall doing it.
   --ignore-existing Ignore files or directories that already exist.
                     Act as if they don't exist.
   --skip-existing   Skip files or directories that already exist.
                     Takes precedence over --ignore-existing.
   --with-keys       Set up links to key files from the Keys volume.
   --without-keys    Do not set up links to key files (typical for
                     a secondary machine).

Sets up Bash and tmux initialization files and, optionally, links to
key files on a new machine.
EOF
}

abort_and_display_help() {
    display_help && echo
    echo "-- ABORTED:"
    abort "$@"
}

# src1, dest1, src2, dest2, ...
sanity_check() {
    mapping=("$@")
    missing=()
    existing=()

    # Do all sources exist? Do any destinations exist?
    for (( i = 0; i < ${#mapping[@]}; i += 2 )); do
        src=${mapping[$i]}
        dest=${mapping[$(( i + 1 ))]}
        if [[ ! -e $src ]]; then
            missing+=("$src")
        fi
        if [[ -e $dest ]]; then
            existing+=("$dest")
        fi
    done

    if [[ ${missing-} ]]; then
        echo "Missing source files: ${missing[@]}."
    fi
    if [[ ${existing-} ]]; then
        echo "Files or directories already exist: ${existing[@]}."
    fi
    if [[ ${missing-} ]]; then
        abort "Can't proceed with missing source files."
    fi
    if [[ ${existing-} ]]; then
        if [[ ${skip_existing-} == true ]]; then
            echo "Skipping existing destination files."
        elif [[ ${ignore_existing-} == true ]]; then
            echo "Ignoring existing destination files."
        else
            abort "Won't proceed with existing destination files."
        fi
    fi
}

setup() {
    mapping=("${@:1}")
    for (( i = 0; i < ${#mapping[@]}; i += 2 )); do
        src=${mapping[$i]}
        dest=${mapping[$(( i + 1 ))]}
        echo ".  Operating on $src -> $dest"
        if [[ -L $dest && $($READLINK "$dest") == $src ]]; then
            echo ".  Skipping existing, valid link: $dest."
            continue
        fi
        if [[ -L $dest || -e $dest ]]; then
            if [[ ${dry_run-} != true ]]; then
                echo "!! mv $dest ${dest}-$(date "+%Y-%m-%d-%H-%M-%S")"
                mv "$dest" "${dest}-$(date "+%Y-%m-%d-%H-%M-%S")"
            else
                echo ".  mv $dest ${dest}-$(date "+%Y-%m-%d-%H-%M-%S")"
                echo ".  Dry run. Skipping."
            fi
        fi
        if [[ ${dry_run-} != true ]]; then
            echo "!! ln -s $src $dest"
            ln -s "$src" "$dest"
        else
            echo "-  ln -s $src $dest"
            echo "-  Dry run. Skipping."
        fi
    done
}

main() {
    while [[ $# > 0 ]]; do
        case $1 in
            -n|--dry-run)
                dry_run=true
                ;;
            --ignore-existing)
                ignore_existing=true
                ;;
            --skip-existing)
                skip_existing=true
                ;;
            --with-keys)
                with_keys=true
                ;;
            --without-keys)
                with_keys=false
                ;;
            *)
                abort_and_display_help "Unknown option: $1."
        esac
        shift
    done

    [[ ${with_keys-} ]] || {
        abort_and_display_help "Must specify one of --with-keys or --without-keys."
    }

    cd "$HOME"

    [[ ${with_keys-} != true || -f $keys_volume/$mounted_evidence ]] \
        || abort "$keys_volume is not mounted."

    [[ ${with_keys-} != true \
        || "$("$READLINK" $HOME/.keys)" == $keys_volume ]] \
        || abort "Run 'ln -s $keys_volume $HOME/.keys' first."

    sanity_check "${files_mapping[@]}"
    sanity_check "${keys_mapping[@]}"

    echo "Linking/writing initialization files to $HOME..."
    setup "${files_mapping[@]}"


    if [[ $with_keys == true ]]; then
        echo "Linking/writing key files/dirs to $HOME..."
        setup "${keys_mapping[@]}"
    fi
}

[[ ${1-} = @(--help|-h) ]] && display_help && exit 0
main "$@"
