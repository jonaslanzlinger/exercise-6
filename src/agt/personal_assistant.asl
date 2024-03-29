natural_light(0).
artificial_light(1).

best_option(Number) :- Number = 0.

!start.

@start_plan
+!start : true <-
    .print("Hello world");
    !create_DweetArtifact.

@create_DweetArtifact_plan
+!create_DweetArtifact : true <-
    makeArtifact("dweet", "room.DweetArtifact", [], Dweet);
    .print("Dweet artifact created").

@sendDweet_plan
+!sendDweet(Message) : true <-
    sendDweet(Message).

@upcoming_event_now_awake_plan
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event").

@awake_upcoming_event_now_plan
+owner_state("awake") : upcoming_event("now") <-
    .print("Enjoy your event").

@upcoming_event_now_asleep_plan
+upcoming_event("now") : owner_state("asleep") <-
    .abolish(upcoming_event(_));
    .abolish(owner_state(_));
    .print("Starting wake-up routine");
    !beginFIPAContractNetProtocol.

@asleep_upcoming_event_now_plan
+owner_state("asleep") : upcoming_event("now") <-
    .abolish(upcoming_event(_));
    .abolish(owner_state(_));
    .print("Starting wake-up routine");
    !beginFIPAContractNetProtocol.

@begin_fipa_contract_net_protocol_plan
+!beginFIPAContractNetProtocol : true <-
    .abolish(propose(_));
    .abolish(refuse(_));
    -+bidding_status(true);
    .broadcast(achieve, cfp(increase_illuminance));
    // deadline of 1 second
    .wait(1000);
    -+bidding_status(false);
    .print("Deadline reached");
    !check_cfp_proposals.

@cfp_propose_plan
+propose(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a proposal from ", Sender, " to ", Action).

@cfp_refuse_plan
+refuse(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a refusal from ", Sender, " to ", Action).

@check_cfp_proposals_plan
+!check_cfp_proposals : true <-
    .count(propose(Action)[source(Sender)], X);
    if (X > 0) {
        .findall([Action, Sender], propose(Action)[source(Sender)], ListOfProposals);
        .print("Proposals received: ", ListOfProposals);
        .length(ListOfProposals, L);
        -+counter(0);
        -+no_action_performed(true);
        while (counter(Counter) & Counter < L) {
            .nth(Counter, ListOfProposals, [Action, Sender]);
            .print("Action: ", Action, " Sender: ", Sender);
            if (no_action_performed(true) & Action = turn_on_lights & artificial_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(0);
                -+artificial_light(1);
                .send(Sender, tell, acceptProposal(Action));
                -+no_action_performed(false);
            } elif (no_action_performed(true) & Action = raise_blinds & natural_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(1);
                -+artificial_light(0);
                .send(Sender, tell, acceptProposal(Action));
                -+no_action_performed(false);
            } else {
                .print(Action, " is NOT the best option");
                .send(Sender, tell, rejectProposal(Action));
            }
            -+counter(Counter + 1);
        }
    } else {
        .print("No proposals received. Sending goal to friends via Dweet.io...");
        sendDweet("!wakeMeUp");
    }.

@inform_done_plan
+informDone(Action) : true <-
    .print("Received confirmation that Action ", Action, " has been completed").

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }