Ocaml simple grep implementation for fun

# Installing

If you're using Linux just download the binary and give it execution permission

```
wget https://github.com/dhilst/ogrep/releases/latest/download/ogrep
chmod +x ogrep
```

# Build

Make sure to setup opam first. Also you need [dune](https://dune.readthedocs.io/en/stable/) to build/install this


```
dune build
dune install
```

# Usage

```
ogrep <PATTERN> [<START>]

START -> FILE | DIRECTORY (assumes '.' if ommited)
```

It will search for pattern recurisvelly from `DIRECTORY`. If is a file it will
filter lines at that file

# Including & Ignoring

The `.ogrepinclude` can be used to include file patterns
The `.ogrepignore` can be used to ignore file patterns

`ogpre` will only search on files that match patterns from `.ogrepinclude` and
that not match `.ogrepignore`. You can use include pattern to narrow by
extensions and ingore patterns to ignore paths

# Using with vim-fzf

Put this at your `.vimrc` and source it. Use it with the `Og` command as you
would use `Ag`.

```vim
command! -bang -nargs=* Og
  \ call fzf#vim#grep(
  \   'ogrepcomplex '.shellescape(<q-args>), 0,
  \   {}, <bang>0)
```

# This is a study case!!!

So there are multiple implementation of the same program, changing little things. Some
are pure serial, other use pure coperative concurrency. Other use coperative and preemtive
concurrency and so on! If you have questions create an issue :)
