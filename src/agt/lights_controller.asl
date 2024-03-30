td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

lights("off").

!start.

@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Hello world");
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

@turn_on_lights_plan
+!turn_on_lights : lights("off") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["on"]);
    -+lights("on");
    .print("Lights turned on");
    .send(personal_assistant, tell, lights("on")).

@turn_off_lights_plan
+!turn_off_lights : lights("on") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["off"]);
    -+lights("off");
    .print("Lights turned off");
    .send(personal_assistant, tell, lights("off")).

// This plan reacts to the call for proposal to increase the illuminance.
// If the lights are off, it proposes to turn them on.
// Otherwise, it refuses the proposal.
@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    if (lights("off")) {
        .send(Sender, tell, propose(turn_on_lights));
    } else {
        .send(Sender, tell, refuse(increase_illuminance));
    }.

// If the proposal to turn on the lights is accepted, the lights get turned on.
@acceptProposal_increase_illuminance_plan
+acceptProposal(turn_on_lights)[source(Sender)] : true <-
    !turn_on_lights;
    .send(Sender, tell, informDone(turn_on_lights)).

// If the proposal to turn on the lights is refused, a message is printed.
@refuseProposal_increase_illuminance_plan
+rejectProposal(turn_on_lights)[source(Sender)] : true <-
    .print("Proposal to turn on lights refused by ", Sender).

{ include("$jacamoJar/templates/common-cartago.asl") }