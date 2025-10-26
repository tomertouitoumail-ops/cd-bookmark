# CD-BookmarK Bash Directory Bookmarks 

A powerful Bash directory bookmark system that lets you save, manage, and quickly navigate frequently used directories. Supports **normal** bookmarks (temporary or frequent use) and **bound** bookmarks (persistent, long-term). Each bookmark can optionally have a **name**.

Written by **Tomer Touitou** 
Licensed under the MIT License.

---

## Features

- Add bookmarks with optional names.
- Normal bookmarks are inserted before bound bookmarks.
- Bound bookmarks always appear last.
- Go to bookmarks by **name** or **index**.
- Remove bookmarks by **name** or **index**.
- List bookmarks in **absolute** or **relative** paths.
- Clear all normal bookmarks while keeping bound bookmarks.
- Highlight the current directory in the bookmark list.
- Auto-completion for bookmark names.

---
## Commands

```bash
addcd [dir]                       : Add a normal bookmark (defaults to current directory if no directory is specified)
addcd -n <name>                   : Add current directory as a normal bookmark with a name
addcd -b [dir]                    : Add a bound bookmark (defaults to current directory)
addcd -b -n <name>                : Add current directory as a bound bookmark with a name
                                    (-bn or -nb also work)

lscd                              : List normal bookmarks only (absolute paths by default)
lscd -b                           : List all bookmarks (normal + bound)
lscd -r                           : List bookmarks in relative paths (works with -b as -rb or -br)
lscd -a                           : List bookmarks in absolute paths (works with -b as -ba or -ab)

gocd <name|index>                 : Change directory to a bookmark by name or index

rmcd <name|index>                 : Remove a normal bookmark by name or index
rmcd -b <name|index>              : Remove a bound bookmark (must use -b)

namecd -n <name|index> <new_name> : Assign or rename a bookmark's name
namecd -un <name|index>           : Remove the name from a bookmark

clearcd                           : Remove all normal bookmarks (bound bookmarks remain)

# Aliases
lcd                                : Alias for lscd
rcd                                : Alias for rmcd
 ```
---


<video src="https://github.com/user-attachments/assets/93083f13-7fe7-4ba0-ae4a-eca5835e0d83" width="500" controls></video>



## Installation

1. Copy the script to a directory  
   Place `cd-bookmark.sh` anywhere you like, for example `~/scripts/`.
   ```bash
   cp cd-bookmark.sh ~/scripts/
   ```
2. Make the script executable
   ```bash
   chmod +x ~/scripts/cd-bookmark.sh
   ```
3. (Optional) Change the bookmarks storage location
   By default, bookmarks are saved in `$HOME/.dir_bookmarks`.  
   To change this, open `cd-bookmark.sh` and set the absolute path in the `CONF1` variable:
   ```bash
   # Inside cd-bookmark.sh eddit and change
   CONF1="/absolute/path/to/your/dir/where/you/want/to/save/the/file"
   ```
   If `CONF1` is left empty, the default location `$HOME/.dir_bookmarks` will be used.
4. Source the script in your shell 
   Add the following line to your `.bashrc` or `.zshrc` to load it automatically in every shell session:
   ```bash
   source ~/scripts/cd-bookmark.sh
   ```
5. Reload your shell configuration
   ```bash
   source ~/.bashrc
   # or
   source ~/.zshrc
   ```
After this, all commands like `addcd`, `lscd`, `gocd`, `rmcd`, `namecd`, and `clearcd` will be available in your shell.
## Usage Examples

### Adding Bookmarks

```bash
# Add current directory as a normal bookmark
addcd

# Add a normal bookmark with a name
addcd -n myproject

# Add a bound bookmark (persistent) of a specific directory
addcd -b /path/to/dir

# Add a bound bookmark of current directory with a name
addcd -b -n importantdir
# or
addcd -bn importantdir
```

### Listing Bookmarks

```bash
# List normal bookmarks (default absolute paths)
lscd

# List all bookmarks including bound ones
lscd -b

# List bookmarks in relative paths
lscd -r
lscd -rb   # relative + bound
lscd -br   # alternative flag order

# List bookmarks in absolute paths
lscd -a
lscd -ba   # absolute + bound
```

### Navigating to a Bookmark

```bash
# Go to bookmark by name
gocd myproject

# Go to bookmark by index
gocd 2
```

### Removing Bookmarks

```bash
# Remove a normal bookmark by name or index
rmcd myproject
rmcd 1
rcd 2   # alias works

# Remove a bound bookmark (must use -b)
rmcd -b importantdir
rmcd -b 3
rcd -b myname  # alias works
```

### Assigning or Removing Names

```bash
# Assign a name to a bookmark
namecd -n 2 newname
namecd -n oldname newname

# Remove the name from a bookmark
namecd -un 2
namecd -un myname
```

### Clearing Normal Bookmarks

```bash
# Remove all normal bookmarks, but keep bound bookmarks
clearcd
```

## Feedback

If you try this script, I’d love to hear from you!  
- Open an **issue** for bugs or suggestions  
- Star ⭐ the repo if you find it useful  
- Fork 🍴 to customize for your workflow




 
