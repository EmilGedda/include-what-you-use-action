#!/bin/sh
set -eou pipefail

COMPILATIONDB="$1"
FORMAT="$2"
NOERROR="$(echo "$3" | tr '[:upper:]' '[:lower:]')"

PATTERN=""
LOGFILE="$(mktemp)"
REPO="$(echo "$GITHUB_REPOSITORY" | cut -d/ -f2)"
ORIGINALDIR="$RUNNER_WORKSPACE/$REPO"

case "$FORMAT" in
    clang)
        PATTERN="/note: #includes\\/fwd-decls are correct/d"
        ;;
    iwyu)
        PATTERN="/ has correct #includes\\/fwd-decl/d;1d"
        ;;
    *)
        echo Unknown output format: \""$FORMAT"\"
        echo Expected \"iwyu\" or \"clang\"
        exit 1
        ;;
esac

if [ "$NOERROR" != "true" ] && [ "$NOERROR" != "false" ]; then
    echo Unknown value given to argument no-error: \""$3"\"
    echo Expected \"true\" or \"false\"
    exit 1
fi

# /home/runner does not exist in the Docker image
mkdir -p "$RUNNER_WORKSPACE"

# Use same path as outside the image since the compilation database
# might contain absolute path's
ln -s "$GITHUB_WORKSPACE" "$ORIGINALDIR"

if [ ! -f "$ORIGINALDIR/$COMPILATIONDB/compile_commands.json" ]; then
    echo No compilation database found!
    echo Expected \""$ORIGINALDIR/$COMPILATIONDB"\" to contain \"compile_commands.json\"
    echo Compilation database path: "$COMPILATIONDB"
    echo Directory contents:
    ls -lah "$ORIGINALDIR/$COMPILATIONDB"
    exit 1
fi

cd "$ORIGINALDIR"
python /usr/local/bin/iwyu_tool.py -o "$FORMAT" -p "$COMPILATIONDB" \
    | sed "$PATTERN"                                                \
    | cat -s                                                        \
    | tee "$LOGFILE"

if [[ "$(sed -E '/^(---)?$/d' "$LOGFILE" | wc -l)" > 1 ]] && [ "$NOERROR" != "true" ]; then
    exit 1;
fi
