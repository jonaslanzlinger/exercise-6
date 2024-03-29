td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/blinds.ttl").

blinds("lowered").

!start.

@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#Blinds", Url) <-
    .print("Hello world");
    makeArtifact("blinds", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId).

@raise_blinds_plan
+!raise_blinds : blinds("lowered") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["raised"]);
    -+blinds("raised");
    .print("Blinds raised");
    .send(personal_assistant, tell, blinds("raised")).

@lower_blinds_plan
+!lower_blinds : blinds("raised") <-
    invokeAction("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#SetState", ["lowered"]);
    -+blinds("lowered");
    .print("Blinds lowered");
    .send(personal_assistant, tell, blinds("lowered")).

@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    if (blinds("lowered")) {
        .send(Sender, tell, propose(raise_blinds));
    } else {
        .send(Sender, tell, refuse(increase_illuminance));
    }.

@acceptProposal_raise_blinds_plan
+acceptProposal(raise_blinds)[source(Sender)] : true <-
    !raise_blinds;
    .send(Sender, tell, informDone(raise_blinds)).

@refuseProposal_raise_blinds_plan
+refuseProposal(raise_blinds)[source(Sender)] : true <-
    .print("Proposal to raise the blinds refused by ", Sender).

{ include("$jacamoJar/templates/common-cartago.asl") }