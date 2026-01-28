## Getting ready with Git

First, you need to install Git.
If you are not familiar with Git, have a look at the [Pro Git book].
It is available in many languages.
I expect you to read the first three chapters: *Getting Started*, *Git Basics* and *Git Branching*.
Even if you are already familiar with Git, you may be interested in the [Git Cheat Sheet].

## Getting ready with OCaml and opam

Ono is written in OCaml.
We will also use the OCaml package manager: opam.
You should start by [installing OCaml and opam].
Once this is done, read the [opam switch introduction].

We will now create a local opam switch for `ono`.
After you cloned `ono` with Git, run the following:

```shell-session
$ cd ono
$ opam switch create . --deps-only
$ opam install . --with-test --with-dev-setup --with-doc --deps-only
```

It should install all the dependencies required by the project.

## Getting ready with Dune

To work on the project, we will use the most used OCaml build system: Dune.
Please, try all the commands presented here.

You can build the project with:

```shell-session
$ dune build
```

While working on the project, you may find the `--watch` flag quite useful!
It will watch for any change on the project's files and rebuild it if needed :

```shell-session
$ dune build --watch
```

You can run the tool with:

```shell-session
$ dune exec -- ono
```

Don't forget to add the `--` in order to be able to pass CLI arguments to `ono` itself:

```shell-session
$ dune exec -- ono --help
$ dune exec -- ono concrete ./test/cram/concrete/fibonacci.t/fibonnaci.wat -vv
```

You can also install the project in your current switch.
It allows you to run `ono` without going through `dune exec`:

```shell-session
$ dune build
$ dune install
$ ono concrete ./test/cram/concrete/fibonacci.t/fibonnaci.wat -vv
```

Moreover, Dune can run `ocamlformat` for you, and automatically promote formatted files:

```shell-session
$ dune fmt
```

You can build and read the documentation by running:

```shell-session
$ dune build @doc
$ xdg-open _build/default/_doc/_html/index.html
```

One last thing you may find useful, is the use of `dune utop` to automatically launch `utop` with the project loaded:

```shell-session
$ dune utop
```

## Testing

### Cram Tests

Tests are mostly written using [Cram Tests].
You can run them as follow:

```shell-session
$ dune runtest
```

If you made some changes and the output of some tests is changing, the diff will be displayed.
If you want to automatically accept the diff as being the new expected output, you can run:

```shell-session
$ dune promote
```

### Code coverage

You can generate the code coverage report with:

```shell-session
BISECT_FILE=$(pwd)/bisect odune runtest --force --instrument-with bisect_ppx
bisect-ppx-report html -o _coverage
xdg-open _coverage/index.html
```

[Cram Tests]: https://dune.readthedocs.io/en/latest/reference/cram.html
[Git Cheat Sheet]: https://git-scm.com/cheat-sheet
[installing OCaml and opam]: https://ocaml.org/docs/installing-ocaml
[opam switch introduction]: https://ocaml.org/docs/opam-switch-introduction
[Pro Git book]: https://git-scm.com/book
