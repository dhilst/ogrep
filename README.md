Ocaml simple grep implementation for fun

# Build

Make sure to setup opam first. Also you need [dune](https://dune.readthedocs.io/en/stable/) to build/install this


```
dune build
dune install
```

# Usage

```
ogrep pattern
```

It will search for pattern recurisvelly from the current folder

# Ignoring

The `.ogrepignore` can be used to ignore file patterns
