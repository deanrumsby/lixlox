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
[Crafting Interpreters](https://craftinginterpreters.com) by Robert Nystrom, but found myself wanting to write the
initial tree walking interpreter in a language other than Java. LixLox is my attempt at writing the interpreter with a
functional programming language, and using parser combinators to build the parsing engine, instead of the object
oriented strategies used in the book.

## Status

Currently I am able to parse and interpret all arithmetic expressions and basic logical operators with the basic types.
I have an environment implementation now in place so you are able to assign variables and use them within
expressions.
