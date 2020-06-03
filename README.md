# NeuralBridge

**A way to mimic human knowledge and decision making**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `neural_bridge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:neural_bridge, "~> 0.1.0"}
  ]
end
```


## Examples

```elixir
    engine = Engine.new("test")

    rules = [
      Rule.new(
        id: 1,
        given: """
        Person's name is equal "bob"
        """,
        then: """
        Person's age is 23
        """
      ),
      Rule.new(
        id: 2,
        given: """
        Person's name is equal $name
        Person's age is equal 23
        """,
        then: fn production ->
          require Logger
          bindings = Map.get(production, :bindings)
          Logger.info(inspect(bindings))
        end
      )
    ]

    engine = Engine.add_rules(engine, rules)
    assert Enum.empty?(engine.rule_engine.agenda)

    engine = Engine.add_facts(engine, Wme.new("Person", "name", "bob"))

    rule = List.first(engine.rule_engine.agenda)

    engine = Engine.apply_rule(engine, rule)

    assert capture_log(fn ->
             Enum.each(engine.rule_engine.agenda, fn pnode ->
               Engine.apply_rule(engine, pnode)
             end)
           end) =~ inspect(%{"$name" => "bob"})
  end

```



Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/neural_bridge](https://hexdocs.pm/neural_bridge).

