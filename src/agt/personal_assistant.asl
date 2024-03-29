// personal assistant agent

/* Initial beliefs */
natural_light(0).
artificial_light(1).

best_option(Number) :- Number = 0.

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: true (the plan is always applicable)
 * Body: greets the user
*/
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

@upcomingEvent_now_awake_plan
+upcomingEvent("now") : owner_state("awake") <-
    .print("Enjoy your event").

@upcomingEvent_now_asleep_plan
+upcomingEvent("now") : owner_state("asleep") <-
    .print("Starting wake-up routine. Starting Call for Proposals.");
    .broadcast(tell, cfp("increase_illuminance"));
    .wait(2000);
    !check_cfp_proposes.

@cfp_propose_plan
+propose(Goal)[source(Sender)] : not Sender = self <-
    .print("Received a proposal from ", Sender, " to ", Goal);
    +propose(Goal).

@cfp_propose_natural_light_plan
+propose(Goal) : Goal = "raise_blinds" & natural_light(Number) & best_option(Number) <-
    -+natural_light(1);
    -+artificial_light(0);
    .print("Delegating the task to raise the blinds to the blinds_controller.");
    .send("blinds_controller", achieve, raise_blinds).

@cfp_proposeartificial_light_plan
+propose(Goal) : Goal = "turn_on_lights" & artificial_light(Number) & best_option(Number) <-
    -+natural_light(0);
    -+artificial_light(1);
    .print("Delegating the task to turn on lights to the lights_controller.");
    .send("lights_controller", achieve, turn_on_lights).

@cfp_propose_fail_plan
+propose(Goal) : true <-
    .print(Goal, " is not the best option specified by the user.").

@cfp_refuse_plan
+refuse(Action)[source(Sender)] : true <-
    .print("Received a refusal from ", Sender, " to ", Action).

+!check_cfp_proposes : true <-
    .print("Checking proposals");
    !sendDweet("!wakeMeUp").


/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }