#!/bin/sh

COMPILATIONDB="$1"
FORMAT="$2"
PATTERN=""
WORKDIR="$GITHUB_WORKSPACE/$COMPILATIONDB"

case "$FORMAT" in
    clang)
        PATTERN="/note: #includes\/fwd-decls are correct/d"
        ;;
    iwyu)
        PATTERN="/ has correct #includes\/fwd-decl/d;1d"
        ;;
    *)
        echo Unknown output format!
        echo Expected \"iwyu\" or \"clang\", got \""$FORMAT"\"
        exit 1
        ;;
esac

if [ ! -d "$WORKDIR" ]; then
    echo Directory containing compilation database not found!
    echo Github workspace: "$GITHUB_WORKSPACE"
    echo Compilation database path: "$COMPILATIONDB"
    echo Full path: "$WORKDIR"
    exit 1
fi

if [ ! -f "$WORKDIR/compile_commands.json" ]; then
    echo No compilation database found!
    echo Expected \""$WORKDIR"\" to contain \"compile_commands.json\"
    echo Github workspace: "$GITHUB_WORKSPACE"
    echo Compilation database path: "$COMPILATIONDB"
    echo Working directory contents:
    ls -lah "$WORKDIR"
    exit 1
fi

iwyu_tool.py -o "$FORMAT" -p "$COMPILATIONDB" | sed "$FORMAT" | cat -s | tee /tmp/iwyu-output.txt
