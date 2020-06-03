# NeuralBridge

**A way to mimic human decision making, incredibily fast - An expert system built in Elixir** 

"Soon after the dawn of modern computers in the late 1940s – early 1950s, researchers started realizing the immense potential these machines had for modern society. One of the first challenges was to make such machine capable of “thinking” like humans. In particular, making these machines capable of making important decisions the way humans do. The medical / healthcare field presented the tantalizing challenge to enable these machines to make medical diagnostic decisions.

Thus, in the late 1950s, right after the information age had fully arrived, researchers started experimenting with the prospect of using computer technology to emulate human decision-making. For example, biomedical researchers started creating computer-aided systems for diagnostic applications in medicine and biology. These early diagnostic systems used patients’ symptoms and laboratory test results as inputs to generate a diagnostic outcome. These systems were often described as the early forms of expert systems." - [Wikipedia](https://en.wikipedia.org/wiki/Expert_system)

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
    alias NeuralBridge.{Engine, Rule}
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
    engine = Engine.add_facts(engine, "Person's name is \"bob\"")
    rule = List.first(engine.rule_engine.agenda)
    engine = Engine.apply_rule(engine, rule)

    Enum.each(engine.rule_engine.agenda, fn pnode ->
        Engine.apply_rule(engine, pnode)
        end)
    end # will log %{"$name" => "bob"}

```

### Medical diagnosis

```elixir
    alias NeuralBridge.{Engine, Rule}
    engine = Engine.new("doctor_AI")

    engine =
      Engine.add_rules(engine, [
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
          Patient's fever is lesser 38.5
          Patient's name is equal $name
          Patient's generic_weakness is equal "No"
          """,
          then: """
          Patient's diagnosis is "all good"
          """
        )
      ])

    engine =
      Engine.add_facts(engine, """
      Patient's fever is 39
      Patient's name is "Aylon"
      Patient's generic_weakness is "Yes"
      """)

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



#### References: 
- [Rete algorithm](https://en.wikipedia.org/wiki/Rete_algorithm)
- [Expert system](https://en.wikipedia.org/wiki/Expert_system#:~:text=In%20artificial%20intelligence%2C%20an%20expert,than%20through%20conventional%20procedural%20code.)
- [Forgy's paper](http://www.csl.sri.com/users/mwfong/Technical/RETE%20Match%20Algorithm%20-%20Forgy%20OCR.pdf)
