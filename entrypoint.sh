#!/bin/sh
COMPILATIONDB="$1"
FORMAT="$2"
PATTERN=""
LOGFILE="$(mktemp)"
REPO="$(echo "$GITHUB_REPOSITORY" | cut -d/ -f2)"
ORIGINALDIR="$RUNNER_WORKSPACE/$REPO"

case "$FORMAT" in
    clang)
        PATTERN="/note: #includes\\/fwd-decls are correct/d"
        ;;
    iwyu)
        PATTERN="/ has correct #includes\\/fwd-decl/d"
        ;;
    *)
        echo Unknown output format!
        echo Expected \"iwyu\" or \"clang\", got \""$FORMAT"\"
        exit 1
        ;;
esac

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
python /usr/local/bin/iwyu_tool.py -o "$FORMAT" -p "$COMPILATIONDB" | sed "$PATTERN" | cat -s | tee "$LOGFILE"

if [[ "$(sed -E '/^(---)?$/d' "$LOGFILE" | wc -l)" > 1 ]]; then
    exit 1;
fi
