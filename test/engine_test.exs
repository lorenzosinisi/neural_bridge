defmodule NeuralBridge.EngineTest do
  use ExUnit.Case
  alias Retex.{RuleEngine, Wme}
  import ExUnit.CaptureLog
  alias NeuralBridge.{Engine}
  alias NeuralBridge.Rule
  alias RuleEngine, as: Engine

  test "can be started" do
    assert Engine.new("test")
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
