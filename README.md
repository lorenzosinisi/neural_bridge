# NeuralBridge

**A way to mimic human knowledge and decision making - An expert system built in Elixir** 

## Installation

```elixir
def deps do
  [
    {:neural_bridge, git: "https://github.com/lorenzosinisi/neural_bridge"}
  ]
end
```


## Examples and usage

### Generic inferred knowledge

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
    engine = Engine.add_facts(engine, Wme.new("Person", "name", "bob"))
    rule = List.first(engine.rule_engine.agenda)
    engine = Engine.apply_rule(engine, rule)

    Enum.each(engine.rule_engine.agenda, fn pnode ->
        Engine.apply_rule(engine, pnode)
        end)
    end # will log %{"$name" => "bob"}
  end

```

### Medical diagnosis

```elixir
    engine = Engine.new("doctor_AI")

    rules = [
      Rule.new(
        id: 1,
        given: """
        Patient's fever is greater 38.5
        Patient's name is equal $name
        Patient's generic_weakness is equal "Yes"
        """,
        then: """
        Patient's diagnosis is "flu"
        """
      ),
      Rule.new(
        id: 2,
        given: """
        Patient's fevel is lesser 38.5
        Patient's name is equal $name
        Patient's generic_weakness is equal "No"
        """,
        then: """
        Patient's diagnosis is "all good"
        """
      )
    ]

    engine = Engine.add_rules(engine, rules)
    has_fever = Wme.new("Patient", "fever", 39)
    has_name = Wme.new("Patient", "name", "Aylon")
    has_weaknes = Wme.new("Patient", "generic_weakness", "Yes")

    engine = Engine.add_facts(engine, has_fever)
    engine = Engine.add_facts(engine, has_name)
    engine = Engine.add_facts(engine, has_weaknes)
    ## contains Patient's diagnnosis
    [
      %_{
        action: [
          %Retex.Wme{
            identifier: "Patient",
            attribute: "diagnosis",
            value: "flu"
          }
        ],
        bindings: %{"$name" => "Aylon"}
      }
    ] = engine.rule_engine.agenda

```


This library is just glue for two projects [Retex](https://github.com/lorenzosinisi/retex)
and the DSL [Sanskrit](https://github.com/lorenzosinisi/sanskrit). Retex and Sanskrit can
be put together to form an expert system in Elixir as shown in the examples above.


If you have any comment or question feel free to open an issue here

