defmodule LixLox.Parser do
  @moduledoc """
  Lox parser
  """

  def parse(input) do
    parser = expression()
    parser.(input)
  end

  # combinator for parsing expressions
  defp expression(), do: equality()

  # combinator for parsing equality comparisons
  defp equality() do
    sequence([
      comparison(),
      many(sequence([choice([chars([?!, ?=]), chars([?=, ?=])]), comparison()]))
    ])
    |> map(fn
      [comparison, []] ->
        comparison

      [comparison_a, others] ->
        Enum.reduce(others, comparison_a, fn
          [[?!, ?=], comparison_b], prev -> {:not_equal, prev, comparison_b}
          [[?=, ?=], comparison_b], prev -> {:equal, prev, comparison_b}
        end)
    end)
  end

  # combinator for parsing comparisons
  defp comparison() do
    sequence([
      term(),
      many(sequence([choice([chars([?>, ?=]), chars([?<, ?=]), char(?>), char(?<)]), term()]))
    ])
    |> map(fn
      [term, []] ->
        term

      [term_a, others] ->
        Enum.reduce(others, term_a, fn
          [?>, term_b], prev -> {:greater, prev, term_b}
          [?<, term_b], prev -> {:less, prev, term_b}
          [[?>, ?=], term_b], prev -> {:greater_equal, prev, term_b}
          [[?<, ?=], term_b], prev -> {:less_equal, prev, term_b}
        end)
    end)
  end

  # combinator for parsing a term expression
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

  # combinator for parsing a factor expression
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

  # combinator for parsing a unary expression
  defp unary() do
    choice([sequence([choice([char(?!), char(?-)]), lazy(fn -> unary() end)]), primary()])
    |> map(fn
      [?!, unary] -> {:not, unary}
      [?-, unary] -> {:minus, unary}
      primary -> primary
    end)
  end

  # combinator for parsing primaries
  defp primary(),
    do:
      choice([
        number(),
        string(),
        boolean(),
        null(),
        sequence([char(?(), lazy(fn -> expression() end), char(?))])
      ])
      |> map(fn
        [?(, expression, ?)] -> expression
        literal -> literal
      end)

  defp token(parser) do
    sequence([ws(), parser, ws()])
    |> map(fn [_, term, _] -> term end)
  end

  # combinator for parsing a string
  defp string() do
    token(sequence([char(?"), many(satisfy(char(), &(&1 != ?"))), char(?")]))
    |> map(fn [_, chars, _] -> to_string(chars) end)
  end

  # combinator that allows us to evaluate other combinators lazily
  defp lazy(combinator) do
    fn input ->
      parser = combinator.()
      parser.(input)
    end
  end

  # combinator for parsing a number
  defp number() do
    token(sequence([some(digit()), optional(sequence([char(?.), some(digit())]))]))
    |> map(fn
      [integer, nil] -> to_string(integer) |> String.to_integer()
      [integer, fractional] -> [integer | fractional] |> to_string() |> String.to_float()
    end)
  end

  defp null(), do: token(chars([?n, ?i, ?l])) |> map(&List.to_atom/1)

  # combinator for parsing booleans
  defp boolean() do
    token(choice([chars([?t, ?r, ?u, ?e]), chars([?f, ?a, ?l, ?s, ?e])]))
    |> map(&List.to_atom/1)
  end

  # combinator for parsing at least one term of a specified type
  defp some(parser), do: sequence([parser, many(parser)])

  # combinator for parsing whitespace 
  defp ws(), do: many(choice([char(?\s), char(?\n), char(?\t), char(?\r)]))

  # combinator for parsing a single digit
  defp digit(), do: satisfy(char(), &(&1 in ?0..?9))

  # combinator for parsing multiple chars in sequence
  defp chars(expected), do: sequence(Enum.map(expected, &char(&1)))

  # combinator for parsing a single specified character
  defp char(expected), do: satisfy(char(), &(&1 == expected))

  # combinator for parsing an optional term
  defp optional(parser), do: &parse_optional(&1, parser)

  # combinator for mapping a parsed term via a lambda
  defp map(parser, mapper), do: &parse_map(&1, parser, mapper)

  # combinator for parsing a sequence of specified terms
  defp sequence(parsers), do: &parse_sequence(&1, parsers)

  # combinator for parsing terms via one of several provided parsers  
  defp choice(parsers), do: &parse_choice(&1, parsers)

  # combinator for parsing many (zero or more) of a specified term
  defp many(parser), do: &parse_many(&1, parser)

  # combinator for parsing terms that pass a provided test
  defp satisfy(parser, acceptor), do: &parse_satisfy(&1, parser, acceptor)

  # combinator for parsing a single character
  defp char(), do: &parse_char(&1)

  # parses an optional term
  defp parse_optional(input, parser) do
    case parser.(input) do
      {:ok, term, rest} -> {:ok, term, rest}
      _error -> {:ok, nil, input}
    end
  end

  # parses a term and then maps it via a provided mapper function
  defp parse_map(input, parser, mapper) do
    with {:ok, term, rest} <- parser.(input) do
      {:ok, mapper.(term), rest}
    end
  end

  # parses a sequence of terms 
  defp parse_sequence(input, parsers)
  defp parse_sequence(input, []), do: {:ok, [], input}

  defp parse_sequence(input, [first_parser | other_parsers]) do
    with {:ok, first_term, rest} <- first_parser.(input),
         {:ok, other_terms, rest} <- parse_sequence(rest, other_parsers) do
      {:ok, [first_term | other_terms], rest}
    end
  end

  # parses one of a choice of terms
  defp parse_choice(input, parsers)
  defp parse_choice(_input, []), do: {:error, "no parser succeeded"}

  defp parse_choice(input, [first_parser | other_parsers]) do
    with {:error, _reason} <- first_parser.(input) do
      parse_choice(input, other_parsers)
    end
  end

  # parses many of a term
  defp parse_many(input, parser) do
    case parser.(input) do
      {:error, _reason} ->
        {:ok, [], input}

      {:ok, first_term, rest} ->
        {:ok, other_terms, rest} = parse_many(rest, parser)
        {:ok, [first_term | other_terms], rest}
    end
  end

  # parses a term satisfying a given condition
  defp parse_satisfy(input, parser, acceptor) do
    with {:ok, term, rest} <- parser.(input) do
      if acceptor.(term) do
        {:ok, term, rest}
      else
        {:error, "term rejected"}
      end
    end
  end

  # parses any single character
  defp parse_char(input)
  defp parse_char(""), do: {:error, "unexpected eof"}
  defp parse_char(<<char::utf8, rest::binary>>), do: {:ok, char, rest}
end
