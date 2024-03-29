// lights controller agent

/* Initial beliefs */
// requires_brightening :- true.
// requires_darkening :- target_illuminance(Target) & current_illuminance(Current) & Target+100 <= Current.


// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights (was:Lights)
td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/lights.ttl").

// The agent initially believes that the lights are "off"
lights("off").

/* Initial goals */ 

// The agent has the goal to start
!start.

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agents believes that a WoT TD of a was:Lights is located at Url
 * Body: greets the user
*/
@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Lights", Url) <-
    .print("Hello world");
    makeArtifact("lights", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

@turn_on_lights_plan
+!turn_on_lights : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["on"]);
    -+lights("on");
    .print("Lights turned on");
    .send(personal_assistant, tell, lights("on")).

@turn_off_lights_plan
+!turn_off_lights : true <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["off"]);
    -+lights("off");
    .print("Lights turned off");
    .send(personal_assistant, tell, lights("off")).

@cfp_increase_illuminance_lights_off_plan
+cfp("increase_illuminance")[source(Sender)] : lights("off") <-
    .print("Proposing to turn on lights.");
    .send(Sender, tell, propose("turn_on_lights")).

@cfp_increase_illuminance_lights_on_plan
+cfp("increase_illuminance")[source(Sender)] : lights("on") <-
    .print("Lights are already turned on.");
    .send(Sender, tell, refuse("increase_illuminance")).

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }