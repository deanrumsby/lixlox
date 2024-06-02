defmodule LixLox.Parser do
  @moduledoc """
  Lox parser
  """

  @type literal :: number() | String.t() | boolean() | nil

  @type ast ::
          {:literal, literal()}
          | {:identifier, atom()}
          | {:define, atom(), ast()}
          | {:assign, atom(), ast()}
          | {:if, ast(), ast(), ast()}
          | {:print, ast()}
          | {:not_equal, ast(), ast()}
          | {:equal, ast(), ast()}
          | {:greater, ast(), ast()}
          | {:less, ast(), ast()}
          | {:greater_equal, ast(), ast()}
          | {:less_equal, ast(), ast()}
          | {:subtract, ast(), ast()}
          | {:add, ast(), ast()}
          | {:divide, ast(), ast()}
          | {:multiply, ast(), ast()}
          | {:not, ast()}
          | {:minus, ast()}

  @doc """
  Takes text as input and transforms it into a list of parsed statements / declarations.

  ## Example
    iex> LixLox.Parser.parse("var a = 3; print a + 2;")
    [{:define :a 3}, {:print {:add :a 2}}]
  """
  @spec parse(String.t()) :: {:ok, list(ast()), String.t()} | {:error, String.t()}
  def parse(input) do
    parser = program()

    case parser.(input) do
      {:ok, _declarations, rest} when rest != "" -> {:error, "something went wrong"}
      result -> result
    end
  end

  # program -> declaration*
  defp program(), do: many(declaration())

  # declaration -> varDecl | statement
  defp declaration(), do: choice([variable_declaration(), statement()])

  # varDecl -> "var" IDENTIFIER ( "=" expression )? ";"
  defp variable_declaration() do
    token(
      sequence([
        chars(~c"var"),
        identifier(),
        optional(sequence([char(?=), expression()])),
        char(?;)
      ])
    )
    |> map(fn
      [_, identifier, nil, _] -> {:define, identifier, nil}
      [_, identifier, [_, expression], _] -> {:define, identifier, expression}
    end)
  end

  # statement -> exprStmt | ifStmt | printStmt | block
  #
  # we have to check for print statements first to ensure correct matching
  # because a print statement can contain an expression but not the other way around
  defp statement(),
    do:
      choice([print_statement(), lazy(fn -> if_statement() end), expression_statement(), block()])

  defp if_statement() do
    sequence([
      chars(~c"if"),
      char(?(),
      expression(),
      char(?)),
      statement(),
      optional(sequence([chars(~c"else"), statement()]))
    ])
    |> map(fn
      [_, _, expression, _, statement, nil] ->
        {:if, expression, statement, nil}

      [_, _, expression, _, statement, [_, else_statement]] ->
        {:if, expression, statement, else_statement}
    end)
  end

  # block -> "{" declaration* "}"
  defp block() do
    token(sequence([char(?{), lazy(fn -> many(declaration()) end), char(?})]))
    |> map(fn [_, declarations, _] -> {:block, declarations} end)
  end

  # exprStmt -> expression ";"
  defp expression_statement() do
    token(sequence([expression(), char(?;)]))
    |> map(fn [expression, _] -> expression end)
  end

  # printStmt -> "print" expression ";"
  defp print_statement() do
    token(sequence([chars(~c"print"), expression(), char(?;)]))
    |> map(fn [_, expression, _] -> {:print, expression} end)
  end

  # expression -> assignment
  defp expression(), do: assignment()

  # assignment -> IDENTIFIER "=" assignment 
  #               | equality
  defp assignment() do
    choice([sequence([identifier(), char(?=), lazy(fn -> assignment() end)]), equality()])
    |> map(fn
      [identifier, ?=, expression] -> {:assign, identifier, expression}
      equality -> equality
    end)
  end

  # equality -> comparison ( ( "!=" | "==" ) comparison )*
  defp equality() do
    sequence([
      comparison(),
      many(sequence([choice([chars(~c"!="), chars(~c"==")]), comparison()]))
    ])
    |> map(fn
      [comparison, []] ->
        comparison

      [comparison_a, others] ->
        Enum.reduce(others, comparison_a, fn
          [~c"!=", comparison_b], prev -> {:not_equal, prev, comparison_b}
          [~c"==", comparison_b], prev -> {:equal, prev, comparison_b}
        end)
    end)
  end

  # comparison -> term ( ( ">" | ">=" | "<" | "<=" ) term )*
  #
  # we have to check the longer lexemes first to avoid incorrect matches
  defp comparison() do
    sequence([
      term(),
      many(sequence([choice([chars(~c">="), chars(~c"<="), char(?>), char(?<)]), term()]))
    ])
    |> map(fn
      [term, []] ->
        term

      [term_a, others] ->
        Enum.reduce(others, term_a, fn
          [?>, term_b], prev -> {:greater, prev, term_b}
          [?<, term_b], prev -> {:less, prev, term_b}
          [~c">=", term_b], prev -> {:greater_equal, prev, term_b}
          [~c"<=", term_b], prev -> {:less_equal, prev, term_b}
        end)
    end)
  end

  # term -> factor ( ( "-" | "+" ) factor )*
  defp term() do
    sequence([factor(), many(sequence([choice([char(?-), char(?+)]), factor()]))])
    |> map(fn
      [factor, []] ->
        factor

      [factor_a, others] ->
        Enum.reduce(others, factor_a, fn
          [?-, factor_b], prev -> {:subtract, prev, factor_b}
          [?+, factor_b], prev -> {:add, prev, factor_b}
        end)
    end)
  end

  # factor -> unary ( ( "/" | "*" ) unary )*
  defp factor() do
    sequence([unary(), many(sequence([choice([char(?/), char(?*)]), unary()]))])
    |> map(fn
      [unary, []] ->
        unary

      [unary_a, others] ->
        Enum.reduce(others, unary_a, fn
          [?/, unary_b], prev -> {:divide, prev, unary_b}
          [?*, unary_b], prev -> {:multiply, prev, unary_b}
        end)
    end)
  end

  # unary -> ( "!" | "-" ) unary
  #          | primary
  defp unary() do
    token(choice([sequence([choice([char(?!), char(?-)]), lazy(fn -> unary() end)]), primary()]))
    |> map(fn
      [?!, unary] -> {:not, unary}
      [?-, unary] -> {:minus, unary}
      primary -> primary
    end)
  end

  # primary -> NUMBER | STRING | "true" | "false" | "nil"
  #            | "(" expression ")"
  #            | IDENTIFIER
  defp primary(),
    do:
      choice([
        number(),
        string(),
        boolean(),
        null(),
        token(sequence([char(?(), lazy(fn -> expression() end), char(?))])),
        identifier()
      ])
      |> map(fn
        [?(, expression, ?)] -> expression
        literal -> literal
      end)

  # trims whitespace from either side of match
  defp token(parser) do
    sequence([ws(), parser, ws()])
    |> map(fn [_, term, _] -> term end)
  end

  defp string() do
    token(sequence([char(?"), many(satisfy(char(), &(&1 != ?"))), char(?")]))
    |> map(fn [_, chars, _] -> to_string(chars) end)
    |> map(fn string -> {:literal, string} end)
  end

  defp identifier() do
    token(sequence([alpha(), many(alpha_numeric())]))
    |> map(fn [first, others] -> List.to_atom([first | others]) end)
    |> map(fn identifier -> {:identifier, identifier} end)
  end

  # allows lazy evaluation of a combinator by deferring evaluation until call time
  defp lazy(combinator) do
    fn input ->
      parser = combinator.()
      parser.(input)
    end
  end

  defp number() do
    token(sequence([some(digit()), optional(sequence([char(?.), some(digit())]))]))
    |> map(fn
      [integer, nil] -> to_string(integer) |> String.to_integer()
      [integer, fractional] -> [integer | fractional] |> to_string() |> String.to_float()
    end)
    |> map(fn number -> {:literal, number} end)
  end

  defp null() do
    chars(~c"nil")
    |> map(fn _ -> {:literal, nil} end)
  end

  defp boolean() do
    choice([chars(~c"true"), chars(~c"false")])
    |> map(&List.to_atom/1)
    |> map(fn bool -> {:literal, bool} end)
  end

  # matches one or more
  defp some(parser), do: sequence([parser, many(parser)])

  # matches multiple whitespace characters
  defp ws(), do: many(choice([char(?\s), char(?\n), char(?\t), char(?\r)]))

  # matches [a-zA-Z0-9_]
  defp alpha_numeric(), do: choice([alpha(), digit()])

  # matches [a-zA-Z_]
  defp alpha(), do: satisfy(char(), &(&1 in ?a..?z or &1 in ?A..?Z or &1 == ?_))

  # matches [0-9]
  defp digit(), do: satisfy(char(), &(&1 in ?0..?9))

  # takes a charlist eg. chars(~c"hello") to match against
  defp chars(expected), do: token(sequence(Enum.map(expected, &char(&1))))

  # matches a single expected character
  defp char(expected) do
    satisfy(char(), &(&1 == expected))
    |> error(fn _reason -> "expected character `#{<<expected::utf8>>}`" end)
  end

  # matches zero or one declared term
  defp optional(parser), do: &parse_optional(&1, parser)

  # using mapper to transform parsed term
  defp map(parser, mapper), do: &parse_map(&1, parser, mapper)

  # allows matching a sequence of terms
  defp sequence(parsers), do: &parse_sequence(&1, parsers)

  # matches against a choice of one or more terms
  defp choice(parsers), do: &parse_choice(&1, parsers)

  # matches zero or more declared terms
  defp many(parser), do: &parse_many(&1, parser)

  # only matches if term passes acceptor test
  defp satisfy(parser, acceptor), do: &parse_satisfy(&1, parser, acceptor)

  defp char(), do: &parse_char(&1)

  # catches/ transforms the error message used 
  defp error(parser, reporter), do: &parse_error(&1, parser, reporter)

  defp parse_error(input, parser, reporter) do
    with {:error, reason} <- parser.(input) do
      {:error, reporter.(reason)}
    end
  end

  defp parse_optional(input, parser) do
    case parser.(input) do
      {:ok, term, rest} -> {:ok, term, rest}
      _error -> {:ok, nil, input}
    end
  end

  defp parse_map(input, parser, mapper) do
    with {:ok, term, rest} <- parser.(input) do
      {:ok, mapper.(term), rest}
    end
  end

  defp parse_sequence(input, parsers)
  defp parse_sequence(input, []), do: {:ok, [], input}

  defp parse_sequence(input, [first_parser | other_parsers]) do
    with {:ok, first_term, rest} <- first_parser.(input),
         {:ok, other_terms, rest} <- parse_sequence(rest, other_parsers) do
      {:ok, [first_term | other_terms], rest}
    end
  end

  defp parse_choice(input, parsers)
  defp parse_choice(_input, []), do: {:error, "no parser succeeded"}

  defp parse_choice(input, [first_parser | other_parsers]) do
    with {:error, _reason} <- first_parser.(input) do
      parse_choice(input, other_parsers)
    end
  end

  defp parse_many(input, parser) do
    case parser.(input) do
      {:error, _reason} ->
        {:ok, [], input}

      {:ok, first_term, rest} ->
        {:ok, other_terms, rest} = parse_many(rest, parser)
        {:ok, [first_term | other_terms], rest}
    end
  end

  defp parse_satisfy(input, parser, acceptor) do
    with {:ok, term, rest} <- parser.(input) do
      if acceptor.(term) do
        {:ok, term, rest}
      else
        {:error, "term rejected"}
      end
    end
  end

  defp parse_char(input)
  defp parse_char(""), do: {:error, "unexpected eof"}
  defp parse_char(<<char::utf8, rest::binary>>), do: {:ok, char, rest}
end
