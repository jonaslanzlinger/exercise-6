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

@upcoming_event_now_asleep_plan
+upcoming_event("now") : owner_state("asleep") <-
    !start_wake_up_routine.

@upcoming_event_now_awake_plan
+upcoming_event("now") : owner_state("awake") <-
    .print("Enjoy your event").

@owner_state_awake_upcoming_event_now_plan
+owner_state("awake") : upcoming_event("now") <-
    .print("Enjoy your event").

@owner_state_asleep_upcoming_event_now_plan
+owner_state("asleep") : upcoming_event("now") <-
    !start_wake_up_routine.

// fipa contract net protocol.
// Bidding phase.
@start_wake_up_routine_plan
+!start_wake_up_routine : true <-
    .print("Starting wake-up routine");
    // clear all proposals and refusals
    .abolish(propose(_));
    .abolish(refuse(_));
    // only accept biddings for 1 second after broadcasting the CFP
    -+bidding_status(true);
    .broadcast(achieve, cfp(increase_illuminance));
    .wait(1000);
    -+bidding_status(false);
    .print("Bidding phase over");
    !check_cfp_proposals.

// fipa contract net protocol.
// Logging the proposals.
@cfp_propose_plan
+propose(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a proposal from ", Sender, " to ", Action).

// fipa contract net protocol.
// Logging the refusals.
@cfp_refuse_plan
+refuse(Action)[source(Sender)] : bidding_status(true) <-
    .print("Received a refusal from ", Sender, " to ", Action).

// fipa contract net protocol.
// Checking the proposals.
// If no proposals are received, send the goal of waking the user up to friends via Dweet.io.
// If proposals are received, check which one is the best option,
// and send an acceptProposal or rejectProposal to the sender.
// IMPORTANT: Only perform one action, clear the owner_state belief (because we don't know if waking up worked),
// and wait for the next owner_state update by the wristband_manager.
// If then the owner_state is still asleep, start the wake up routine again.
@check_cfp_proposals_plan
+!check_cfp_proposals : true <-
    .count(propose(Action)[source(Sender)], X);
    if (X > 0) {
        .findall([Action, Sender], propose(Action)[source(Sender)], ListOfProposals);
        .print("Proposals received: ", ListOfProposals);
        .length(ListOfProposals, L);
        -+counter(0);
        -+action_performed(false);
        while (counter(Counter) & Counter < L) {
            .nth(Counter, ListOfProposals, [Action, Sender]);
            if (action_performed(Performed) & Performed = false & Action = turn_on_lights & artificial_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(0);
                -+artificial_light(1);
                .send(Sender, tell, acceptProposal(Action));
                -+action_performed(true);
                .abolish(owner_state(_));
            } elif (action_performed(Performed) & Performed = false & Action = raise_blinds & natural_light(Number) & best_option(Number)) {
                .print(Action, " is the best option");
                -+natural_light(1);
                -+artificial_light(0);
                .send(Sender, tell, acceptProposal(Action));
                -+action_performed(true);
                .abolish(owner_state(_));
            } else {
                .print(Action, " is NOT the best option");
                .send(Sender, tell, rejectProposal(Action));
            }
            -+counter(Counter + 1);
        }
    } else {
        .print("No proposals received. Sending goal to friends via Dweet.io...");
        sendDweet("!help_me_to_wake_up");
    }.

// fipa contract net protocol.
// Logging the informDone beliefs.
@inform_done_plan
+informDone(Action) : true <-
    .print("Received confirmation that Action ", Action, " has been completed");
    .abolish(informDone(Action)).

{ include("$jacamoJar/templates/common-cartago.asl") }