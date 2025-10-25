#!/bin/bash
#
# cd-bookmarks.sh
# A powerful Bash directory bookmark system with normal and bound bookmarks
# Written by Tomer Touitou 
#MIT License
#Copyright (c) 2025 Tomer Touitou 
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.





# =====================================
# Directory Bookmark Script
# =====================================
# This script lets you save, manage, and quickly navigate frequently used directories.
# You can create normal bookmarks for temporary or frequent use, and bound bookmarks
# for long-term or persistent directories. Each bookmark can optionally have a name.
# The script provides commands to list, go to, rename, and remove bookmarks.
# It supports absolute or relative paths, highlights your current directory,
# and ensures bound bookmarks are always displayed last.
#
# Flags and Aliases:
#   - lscd and lcd are interchangeable; both list bookmarks
#   - rmcd and rcd are interchangeable; both remove bookmarks
#
# Features:
# 
#   addcd [dir]                      : Add a normal bookmark (defaults to current directory if no dir select)
#   addcd -n <name>                  : Add current directory as a normal bookmark with a name
#   addcd -b [dir]                   : Add a bound bookmark (defaults to current directory)
#   addcd -b -n <name>               : Add current directory as a bound bookmark with a name
#                                      (-bn or -nb also work)
#   lscd / lcd                       : List normal bookmarks only (absolute paths by default)
#   lscd -b                          : List all bookmarks (normal + bound)
#   lscd -r                          : List bookmarks in relative paths (works with -b: -rb or -br)
#   lscd -a / lcd -a                 : List bookmarks in absolute paths (works with -b: -ba or -ab)
#   gocd <name|index>                : Change directory to a bookmark by name or index
#   rmcd <name|index>                : Remove a normal bookmark by name or index
#   rmcd -b <name|index>             : Remove a bound bookmark (must use -b)
#   namecd -n <name|index><new_name> : Assign or rename a bookmark's name
#   namecd -un <name|index>          : Remove the name from a bookmark
#   clearcd                          : Remove all normal bookmarks (bound bookmarks remain)
#
# =====================================







# =====================================
# Configuration for Installing the Script
# =====================================
# One argument can be set to configure the script
# CONF1 - The location of the file where the bookmark list will be saved.
#         If empty, the script will use the default value.
CONF1=""











# =====================================================================================
# Bookmark Script
# =====================================================================================
# Default bookmark file
DEFAULT_BOOKMARK_FILE="$HOME/.dir_bookmarks"

# Use CONF1 if set, otherwise use default
BOOKMARK_FILE="${CONF1:-$DEFAULT_BOOKMARK_FILE}"
mkdir -p "$(dirname "$BOOKMARK_FILE")"
touch "$BOOKMARK_FILE"

# Colors
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

# -------------------------------------
# Add directory with optional bound and name
# -------------------------------------
addcd() {
    local type=0   # 0 = normal, 1 = bound
    local name=""
    local dir=""

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -b)
                type=1
                shift
                ;;
            -n)
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    name="$2"
                    shift 2
                else
                    dir="."  # current dir if no argument after -n
                    shift
                fi
                ;;
            -bn|-nb)
                type=1
                if [[ -n "$2" && ! "$2" =~ ^- ]]; then
                    name="$2"
                    shift 2
                else
                    dir="."
                    shift
                fi
                ;;
            *)
                dir="$1"
                shift
                ;;
        esac
    done

    # Default dir if empty
    [[ -z "$dir" ]] && dir="."

    if [[ ! -d "$dir" ]]; then
        echo "Directory does not exist: $dir"
        return 1
    fi

    # Absolute path
    local absdir
    absdir=$(readlink -f "$dir")

    # Check if name exists
    if [[ -n "$name" && $(grep -c "|${name}|" "$BOOKMARK_FILE") -gt 0 ]]; then
        echo "Error: name '$name' already exists."
        return 1
    fi

    # Construct line: type|name|path
    local line
    line="${type}|${name}|${absdir}"

    if [[ $type -eq 0 ]]; then
        # Insert normal before first bound
        local bound_index
        bound_index=$(grep -n "^1|" "$BOOKMARK_FILE" | head -n1 | cut -d: -f1)
        if [[ -n "$bound_index" ]]; then
            sed -i "${bound_index}i${line}" "$BOOKMARK_FILE"
        else
            echo "$line" >> "$BOOKMARK_FILE"
        fi
        echo "Added normal bookmark: $absdir${name:+ (name: $name)}"
    else
        # Append bound
        echo "$line" >> "$BOOKMARK_FILE"
        echo "Added bound bookmark: $absdir${name:+ (name: $name)}"
    fi
}

# -------------------------------------
# Assign / remove name
# -------------------------------------
namecd() {
    local action="$1"
    shift
    case "$action" in
        -n)
            local key="$1"
            local newname="$2"
            if [[ -z "$key" || -z "$newname" ]]; then
                echo "Usage: namecd -n <index|oldname> <newname>"
                return 1
            fi

            # Check if new name already exists
            if grep -q "|${newname}|" "$BOOKMARK_FILE"; then
                echo "Error: name '$newname' already exists."
                return 1
            fi

            # Find index by number or old name
            local index line type path
            if [[ "$key" =~ ^[0-9]+$ ]]; then
                index="$key"
            else
                index=$(grep -n "|${key}|" "$BOOKMARK_FILE" | cut -d: -f1)
            fi

            if [[ -z "$index" ]]; then
                echo "No such bookmark: $key"
                return 1
            fi

            # Update the line
            line=$(sed -n "${index}p" "$BOOKMARK_FILE")
            type=$(echo "$line" | cut -d'|' -f1)
            path=$(echo "$line" | cut -d'|' -f3-)
            sed -i "${index}s~.*~${type}|${newname}|${path}~" "$BOOKMARK_FILE"
            echo "Renamed bookmark '$key' to '$newname'"
            ;;
        -un)
            local key="$1"
            if [[ -z "$key" ]]; then
                echo "Usage: namecd -un <name|index>"
                return 1
            fi

            # Find index
            local index line type path
            if [[ "$key" =~ ^[0-9]+$ ]]; then
                index="$key"
            else
                index=$(grep -n "|${key}|" "$BOOKMARK_FILE" | cut -d: -f1)
            fi

            if [[ -z "$index" ]]; then
                echo "No such bookmark: $key"
                return 1
            fi

            line=$(sed -n "${index}p" "$BOOKMARK_FILE")
            type=$(echo "$line" | cut -d'|' -f1)
            path=$(echo "$line" | cut -d'|' -f3-)
            sed -i "${index}s~.*~${type}||${path}~" "$BOOKMARK_FILE"
            echo "Removed name from bookmark '$key'"
            ;;
        *)
            echo "Usage:"
            echo "  namecd -n <index|oldname> <newname>   # assign or rename"
            echo "  namecd -un <name|index>               # remove name"
            return 1
            ;;
    esac
}
# -------------------------------------
# List bookmarks
# -------------------------------------
lcd() {
    local show_bound=0
    local mode="abs"

    # Parse flags (support any combination order)
    for arg in "$@"; do
        case "$arg" in
            -a) mode="abs" ;;
            -abs) mode="abs" ;;
            -r) mode="rel" ;;
            -rel) mode="rel" ;;
            -b) show_bound=1 ;;
            -ab|-ba) show_bound=1; mode="abs" ;;
            -rb|-br) show_bound=1; mode="rel" ;;
            *) echo "Invalid option: $arg"; return 1 ;;
        esac
    done

    local normal_count bound_count
    normal_count=$(awk -F'|' '$1==0 {print}' "$BOOKMARK_FILE" | wc -l)
    bound_count=$(awk -F'|' '$1==1 {print}' "$BOOKMARK_FILE" | wc -l)

    if [[ $normal_count -eq 0 && $show_bound -eq 0 ]]; then
        if [[ $bound_count -gt 0 ]]; then
            echo "No normal bookmarks, but you have $bound_count bound bookmark(s). Use 'lcd -b' to see them."
            return
        else
            echo "No saved bookmarks."
            return
        fi
    fi

    local i=1
    local current_dir
    current_dir=$(pwd)

    # Print normal bookmarks
    while IFS= read -r line; do
        local type name path mark=""
        type=$(echo "$line" | cut -d'|' -f1)
        name=$(echo "$line" | cut -d'|' -f2)
        path=$(echo "$line" | cut -d'|' -f3-)
        [[ $type -ne 0 ]] && continue
        [[ "$mode" == "rel" ]] && path=$(realpath --relative-to="$PWD" "$path")
        [[ "$current_dir" == "$(readlink -f "$path")" ]] && mark="${GREEN}*${RESET}"
        if [[ -n "$name" ]]; then
            printf "%2d  (%s)   %s %b\n" "$i" "$name" "$path" "$mark"
        else
            printf "%2d  %s %b\n" "$i" "$path" "$mark"
        fi
        ((i++))
    done < "$BOOKMARK_FILE"

    # Print bound bookmarks if requested
    if [[ $show_bound -eq 1 ]]; then
        while IFS= read -r line; do
            local type name path mark=""
            type=$(echo "$line" | cut -d'|' -f1)
            name=$(echo "$line" | cut -d'|' -f2)
            path=$(echo "$line" | cut -d'|' -f3-)
            [[ $type -ne 1 ]] && continue
            [[ "$mode" == "rel" ]] && path=$(realpath --relative-to="$PWD" "$path")
            [[ "$current_dir" == "$(readlink -f "$path")" ]] && mark="${GREEN}*${RESET}"
            if [[ -n "$name" ]]; then
                printf "%2d  (%s)   %s ${YELLOW}(bound)${RESET} %b\n" "$i" "$name" "$path" "$mark"
            else
                printf "%2d  %s ${YELLOW}(bound)${RESET} %b\n" "$i" "$path" "$mark"
            fi
            ((i++))
        done < "$BOOKMARK_FILE"
    fi
}

# Alias lscd to lcd
lscd() {
    lcd "$@"
}

# -------------------------------------
# Go to bookmark
# -------------------------------------
gocd() {
    local key="$1"
    [[ -z "$key" ]] && { echo "Usage: gocd <name|index>"; return 1; }

    local target=""
    if [[ "$key" =~ ^[0-9]+$ ]]; then
        target=$(sed -n "${key}p" "$BOOKMARK_FILE" | cut -d'|' -f3-)
    else
        target=$(grep "|${key}|" "$BOOKMARK_FILE" | head -n1 | cut -d'|' -f3-)
    fi

    [[ -z "$target" ]] && { echo "No such bookmark: $key"; return 1; }
    cd "$target" || { echo "Failed to cd to $target"; return 1; }
}

# -------------------------------------
# Remove bookmark
# -------------------------------------
rcd() {
    local flag=""
    if [[ "$1" == "-b" ]]; then
        flag="1"
        shift
    fi

    local key="$1"
    [[ -z "$key" ]] && { echo "Usage: rcd [-b] <name|index>"; return 1; }

    local index="" type=""

    if [[ "$key" =~ ^[0-9]+$ ]]; then
        index="$key"
        type=$(sed -n "${index}p" "$BOOKMARK_FILE" | cut -d'|' -f1)
        if [[ "$type" == "1" && -z "$flag" ]]; then
            echo "Error: Entry #$index is bound. Use -b to remove it."
            return 1
        elif [[ "$type" == "0" && "$flag" == "1" ]]; then
            echo "Error: Entry #$index is normal. Cannot remove with -b."
            return 1
        fi
    else
        if [[ -n "$flag" ]]; then
            index=$(awk -F'|' -v n="$key" '$1==1 && $2==n {print NR}' "$BOOKMARK_FILE")
            if [[ -z "$index" ]]; then
                local normal_index=$(awk -F'|' -v n="$key" '$1==0 && $2==n {print NR}' "$BOOKMARK_FILE")
                if [[ -n "$normal_index" ]]; then
                    echo "Error: Entry '$key' is normal. Cannot remove with -b."
                    return 1
                else
                    echo "No such bound bookmark: $key"
                    return 1
                fi
            fi
        else
            index=$(awk -F'|' -v n="$key" '$1==0 && $2==n {print NR}' "$BOOKMARK_FILE")
            if [[ -z "$index" ]]; then
                local bound_index=$(awk -F'|' -v n="$key" '$1==1 && $2==n {print NR}' "$BOOKMARK_FILE")
                if [[ -n "$bound_index" ]]; then
                    echo "Error: Entry '$key' is bound. Use -b to remove it."
                    return 1
                else
                    echo "No such normal bookmark: $key"
                    return 1
                fi
            fi
        fi
    fi

    sed -i "${index}d" "$BOOKMARK_FILE"
    echo "Removed bookmark #$index"
}

rmcd() { rcd "$@"; }

# -------------------------------------
# Clear normal bookmarks
# -------------------------------------
clearcd() {
    if [[ ! -s "$BOOKMARK_FILE" ]]; then
        echo "No bookmarks to clear."
        return
    fi
    # Keep bound bookmarks
    grep "^1|" "$BOOKMARK_FILE" > /tmp/bound.tmp 2>/dev/null
    mv /tmp/bound.tmp "$BOOKMARK_FILE"
    echo "Cleared all normal bookmarks; bound bookmarks are kept."
}

# -------------------------------------
# Auto compilt bookmarks
# -------------------------------------
_dir_bookmark_completion() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(awk -F'|' '{if($2!="") print $2}' "$BOOKMARK_FILE")
    COMPREPLY=( $(compgen -W "${opts}" -- "$cur") )
}
complete -F _dir_bookmark_completion gocd rmcd rcd namecd

