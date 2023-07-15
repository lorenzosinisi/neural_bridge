defmodule NeuralBridge.IntegrationTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  test "returns an error if the given of a rule is invalid" do
    assert capture_log(fn ->
             assert_raise NeuralBridge.Rule.Error,
                          ~r/Invalid statement in the given of the rule id 1 at line 2: Customer's number_of_items_bought is 5/,
                          fn ->
                            [
                              NeuralBridge.Rule.new(
                                id: 1,
                                given: """
                                Customer's number_of_items_bought is equal 5
                                Customer's number_of_items_bought is 5
                                """,
                                then: """
                                Customer's discount_percentage is 0.2
                                """
                              )
                            ]
                          end
           end) =~
             "Allowed facts in a given of a rule are: [Retex.Fact.HasAttribute, Retex.Fact.IsNot, Retex.Fact.Isa, Retex.Fact.NotExistingAttribute]"
  end

  test "invalid statement in a rule" do
    assert_raise NeuralBridge.Rule.Error,
                 ~r/Error at rule 1 - Invalid statement: Customer's number_of _items_ bought is equal 5/,
                 fn ->
                   [
                     NeuralBridge.Rule.new(
                       id: 1,
                       given: """
                       Customer's number_of _items_ bought is equal 5
                       Customer's numbe r_of_item s_bought is ciao 5
                       """,
                       then: """
                       Customer's discount_percentage is 0.2
                       """
                     )
                   ]
                 end
  end

  test "dynamic pricing" do
    rules = [
      NeuralBridge.Rule.new(
        id: 1,
        given: """
        Customer's number_of_items_bought is equal 5
        """,
        then: """
        Customer's discount_percentage is 0.2
        """
      ),
      NeuralBridge.Rule.new(
        id: 1,
        given: """
        Customer's number_of_items_bought is lesser 2
        """,
        then: """
        Customer's discount_percentage is 0.0
        """
      ),
      NeuralBridge.Rule.new(
        id: 1,
        given: """
        Customer's number_of_items_bought is equal 3
        """,
        then: """
        Customer's discount_percentage is 0.1
        """
      )
    ]

    facts = """
    Customer's number_of_items_bought is 5
    """

    assert [
             %Retex.Wme{
               identifier: "Customer",
               attribute: "discount_percentage",
               value: 0.2
             }
           ] =
             NeuralBridge.Session.new("uk")
             |> NeuralBridge.Session.add_rules(rules)
             |> NeuralBridge.Session.add_facts(facts)
             |> Map.fetch!(:inferred_facts)
  end

  test "loan approval" do
    rules = [
      NeuralBridge.Rule.new(
        id: 1,
        given: """
        Applicant's credit_score is greater 700
        """,
        then: """
        Loan's approval_status is "approved"
        """
      ),
      NeuralBridge.Rule.new(
        id: 2,
        given: """
        Applicant's credit_score is lesser 500
        """,
        then: """
        Customer's at_risk is true
        Loan's approval_status is "rejected"
        """
      )
    ]

    facts = """
    Applicant's credit_score is 499
    """

    assert [
             %Retex.Wme{
               identifier: "Customer",
               attribute: "at_risk",
               value: true
             },
             %Retex.Wme{
               identifier: "Loan",
               attribute: "approval_status",
               value: "rejected"
             }
           ] =
             NeuralBridge.Session.new("uk")
             |> NeuralBridge.Session.add_rules(rules)
             |> NeuralBridge.Session.add_facts(facts)
             |> Map.fetch!(:inferred_facts)
  end

  test "workflow automation" do
    rules = [
      NeuralBridge.Rule.new(
        id: 1,
        given: """
        SupportTicket's opening_time_hours greater 24
        SupportTicket's id is equal $ticke_id
        """,
        then: """
        SupportTicket's escalation_level "high"
        SupportTicket's escalated is $ticke_id
        """
      )
    ]

    facts = """
    SupportTicket's opening_time_hours is 25
    SupportTicket's id is "123AB_ID"
    """

    assert [
             %Retex.Wme{
               identifier: "SupportTicket",
               attribute: "escalation_level",
               value: "high"
             },
             %Retex.Wme{
               identifier: "SupportTicket",
               attribute: "escalated",
               value: "123AB_ID"
             }
           ] =
             NeuralBridge.Session.new("uk")
             |> NeuralBridge.Session.add_rules(rules)
             |> NeuralBridge.Session.add_facts(facts)
             |> Map.fetch!(:inferred_facts)
  end
end
