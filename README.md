# LixLox

An interpreter for the [Lox](https://craftinginterpreters.com/the-lox-language.html)
programming language, written in Elixir.

## Installation

You need the BEAM runtime and mix toolchain installed locally to run the LixLox interpreter.
If you are on macOS this is installed easily with Homebrew.

```
brew install elixir
```

## REPL

Start a LixLox repl with `mix repl`.

## Journey

I recently watched an amazing (and eye opening) talk by Saša Jurić called
[Parsing from first principles](https://youtu.be/xNzoerDljjo?si=_6cGS0hWjO0QA822)
where he explains a method of parsing known as parser combinators. I had not seen this method before, and
simultaneously I had been slowly progressing through another amazing resource
[Crafting Interpreters by Robert Nystrom](https://craftinginterpreters.com) but wanting to write the initial
tree walking interpreter in a language other than Java. LixLox is my attempt at learning how to build such an
interpreter using parser combinators.

## Status

I have just finished building the parsers required for the arithmetic expressions supported by Lox.

Currently my parser combinator implementation has almost no error handling, so learning how to approach this
is a strong priority.
