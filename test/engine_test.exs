defmodule NeuralBridge.EngineTest do
  use ExUnit.Case
  alias Retex.Wme
  import ExUnit.CaptureLog
  alias NeuralBridge.{Engine}
  alias NeuralBridge.Rule

  test "can be started" do
    assert Engine.new("test")
  end

  test "can abstract medical knowledge" do
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
          Patient's fevel is lesser 38.5
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
  end

  test "rules can be added, and their conclusion can be a function call" do
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

  test "rules can be added" do
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
      )
    ]

    engine = Engine.add_rules(engine, rules)
    assert Enum.empty?(engine.rule_engine.agenda)

    engine = Engine.add_facts(engine, Wme.new("Person", "name", "bob"))

    rule = List.first(engine.rule_engine.agenda)

    assert Enum.empty?(engine.rules_fired)

    assert %Retex.Node.PNode{
             action: [
               %Retex.Wme{
                 attribute: "age",
                 id: _,
                 identifier: "Person",
                 timestamp: nil,
                 value: 23
               }
             ]
           } = rule

    assert engine = Engine.apply_rule(engine, rule)
  end
end
