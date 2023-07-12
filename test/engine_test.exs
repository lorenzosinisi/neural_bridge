defmodule NeuralBridge.SessionTest do
  use ExUnit.Case
  alias NeuralBridge.Session
  alias NeuralBridge.Rule

  test "can be started" do
    assert Session.new("test")
  end

  test "can use inferred rules" do
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
          Patient's diagnosis is equal "flu"
          """,
          then: """
          Patient's therapy is "Aspirin"
          """
        ),
        Rule.new(
          id: 3,
          given: """
          Patient's therapy is equal "Aspirin"
          """,
          then: """
          Patient's health_status is "recovered"
          """
        )
      ])

    engine =
      Engine.add_facts(engine, """
      Patient's fever is 39
      Patient's name is "Aylon"
      Patient's generic_weakness is "Yes"
      """)

    engine =
      Enum.reduce(engine.rule_engine.agenda, engine, fn pnode, network ->
        Engine.apply_rule(network, pnode)
      end)

    ## contains Patient's diagnosis
    assert [
             %_{
               action: [
                 %Retex.Wme{
                   identifier: "Patient",
                   attribute: "health_status",
                   value: "recovered"
                 }
               ],
               bindings: %{}
             },
             %_{
               action: [
                 %Retex.Wme{
                   identifier: "Patient",
                   attribute: "therapy",
                   value: "Aspirin"
                 }
               ],
               bindings: %{}
             },
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

    ## contains Patient's diagnosis
    assert [
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

  test "can calculate the net taxaction in the UK" do
    rules = [
      Rule.new(
        id: 1,
        given: """
        Person's salary is equal $salary
        Person's salary is greater 0
        Person's employment_type is equal "Full-time"
        Person's location is equal "UK"
        """,
        then: """
        let $monthly_salary = div($salary, 12)
        Person's monthly_salary is $monthly_salary
        """
      ),
      Rule.new(
        id: 2,
        given: """
        Person's monthly_salary is equal $monthly_salary
        """,
        then: """
        let $payout = mult($monthly_salary, 0.64)
        Salary's net_amount is $payout
        """
      ),
      Rule.new(
        id: 2,
        given: """
        Salary's net_amount is equal $amount
        """,
        then: """
        Salary's net_amount is $amount
        """
      )
    ]

    facts = """
    Person's salary is 60000
    Person's employment_type is "Full-time"
    Person's location is "UK"
    """

    inference =
      NeuralBridge.Session.new("uk")
      |> NeuralBridge.Session.add_rules(rules)
      |> NeuralBridge.Session.add_facts(facts)

    assert [
             %Retex.Wme{
               attribute: "monthly_salary",
               identifier: "Person",
               value: 5000.0,
               id: 3_510_723_950,
               timestamp: nil
             },
             %Retex.Wme{
               attribute: "net_amount",
               identifier: "Salary",
               value: 25_000_000.0,
               id: 1_705_982_201,
               timestamp: nil
             },
             %Retex.Wme{
               attribute: "net_amount",
               identifier: "Salary",
               value: 25_000_000.0,
               id: 1_238_196_029,
               timestamp: nil
             }
           ] = Map.fetch!(inference, :inferred_facts)
  end

  test "can apply all defined functions" do
    rules = [
      Rule.new(
        id: 1,
        given: """
        Person's salary is equal $salary
        """,
        then: """
        let $div = div($salary, 12)
        let $mult = mult($salary, 12)
        let $compare = compare($salary, 12)
        let $equal = equal($salary, 12)
        let $add = add($salary, 12)
        let $div_int = div_int($salary, 12)
        let $div_rem = div_rem($salary, 12)
        let $div_rem = div_rem($salary, 12)
        let $div_rem_neg = div_rem($salary, -12)
        let $is_decimal = is_decimal($salary)
        let $is_decimal = is_decimal(0.5)
        let $min = min(0.5, 0)
        let $round = round(0.5, 10)
        let $round = round(0.5, 0, "half_up")
        let $to_string = to_string(0.5)
        let $abs = abs(-0.5)
        Result's div is $div
        Result's mult is $mult
        Result's div_rem_neg is $div_rem_neg
        Result's compare is $compare
        Result's equal is $equal
        Result's div_int is $div_int
        Result's div_rem is $div_rem
        Result's is_decimal is $is_decimal
        Result's min is $min
        Result's round is $round
        Result's to_string is $to_string
        Result's abs is $abs
        """
      )
    ]

    facts = """
    Person's salary is 60000
    """

    inference =
      NeuralBridge.Session.new("uk")
      |> NeuralBridge.Session.add_rules(rules)
      |> NeuralBridge.Session.add_facts(facts)

    assert [
             %Retex.Wme{
               attribute: "div",
               id: 286_302_541,
               identifier: "Result",
               timestamp: nil,
               value: 5000.0
             },
             %Retex.Wme{
               attribute: "mult",
               id: 1_114_257_588,
               identifier: "Result",
               timestamp: nil,
               value: 3_600_000_000.0
             },
             %Retex.Wme{
               attribute: "div_rem_neg",
               id: 3_615_986_300,
               identifier: "Result",
               timestamp: nil,
               value: -5000.0
             },
             %Retex.Wme{
               attribute: "compare",
               id: 2_708_243_500,
               identifier: "Result",
               timestamp: nil,
               value: :gt
             },
             %Retex.Wme{
               attribute: "equal",
               id: 3_946_451_889,
               identifier: "Result",
               timestamp: nil,
               value: false
             },
             %Retex.Wme{
               attribute: "div_int",
               id: 1_371_952_866,
               identifier: "Result",
               timestamp: nil,
               value: 5000.0
             },
             %Retex.Wme{
               attribute: "div_rem",
               id: 1_404_142_044,
               identifier: "Result",
               timestamp: nil,
               value: 5000.0
             },
             %Retex.Wme{
               attribute: "is_decimal",
               id: 1_305_437_226,
               identifier: "Result",
               timestamp: nil,
               value: false
             },
             %Retex.Wme{
               attribute: "min",
               id: 3_799_248_231,
               identifier: "Result",
               timestamp: nil,
               value: 0
             },
             %Retex.Wme{
               attribute: "round",
               id: 1_729_796_609,
               identifier: "Result",
               timestamp: nil,
               value: 0.5
             },
             %Retex.Wme{
               attribute: "to_string",
               id: 1_899_589_166,
               identifier: "Result",
               timestamp: nil,
               value: "0.5"
             },
             %Retex.Wme{
               attribute: "abs",
               id: 2_853_144_464,
               identifier: "Result",
               timestamp: nil,
               value: 0.5
             }
           ] = Map.fetch!(inference, :inferred_facts)
  end
end
