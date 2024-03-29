td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Wristband", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/wristband-simu.ttl").

owner_state(_).

!start.

@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Wristband", Url) <-
    .print("Hello world");
    makeArtifact("wristband", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_owner_state.

@read_owner_state_plan
+!read_owner_state : true <-
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadOwnerState",  OwnerStateLst);
    .nth(0,OwnerStateLst,OwnerState);
    -+owner_state(OwnerState);
    .wait(5000);
    !read_owner_state.

@owner_state_plan
+owner_state(State) : true <-
    .print("The owner is ", State);
    .send(personal_assistant, tell, owner_state(State)).

@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    .send(Sender, tell, refuse(increase_illuminance)).

{ include("$jacamoJar/templates/common-cartago.asl") }