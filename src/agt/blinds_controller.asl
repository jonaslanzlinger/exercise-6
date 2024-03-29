// blinds controller agent

/* Initial beliefs */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds (was:Blinds)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

// the agent initially believes that the blinds are "lowered"
blinds("lowered").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Blinds is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

@raise_blinds_plan
+!raise_blinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["raised"]);
    -+blinds("raised");
    .print("Blinds raised");
    .send(personal_assistant, tell, blinds("raised")).

@lower_blinds_plan
+!lower_blinds : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["lowered"]);
    -+blinds("lowered");
    .print("Blinds lowered");
    .send(personal_assistant, tell, blinds("lowered")).

@cfp_increase_illuminance_blinds_lowered_plan
+cfp("increase_illuminance")[source(Sender)] : blinds("lowered") <-
    .print("Proposing to raise blinds.");
    .send(Sender, tell, propose("raise_blinds")).

@cfp_increase_illuminance_blinds_raised_plan
+cfp("increase_illuminance")[source(Sender)] : blinds("raised") <-
    .print("Blinds are already raised.");
    .send(Sender, tell, refuse("increase_illuminance")).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }