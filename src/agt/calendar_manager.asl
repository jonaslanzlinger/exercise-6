td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", "https://raw.githubusercontent.com/Interactions-HSG/example-tds/was/tds/calendar-service.ttl").

upcoming_event(_).

!start.

@start_plan
+!start : td("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#CalendarService", Url) <-
    .print("Hello world");
    makeArtifact("calendarService", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Url], ArtId);
    !read_upcoming_event.

@read_upcoming_event_plan
+!read_upcoming_event : true <-
    readProperty("https://was-course.interactions.ics.unisg.ch/wake-up-ontology#ReadUpcomingEvent",  UpcomingEventList);
    .nth(0, UpcomingEventList, UpcomingEvent);
    -+upcoming_event(UpcomingEvent);
    .wait(5000);
    !read_upcoming_event.

@upcoming_event_plan
+upcoming_event(UpcomingEvent) : true <-
    .print("Upcoming event: ", UpcomingEvent);
    .send(personal_assistant, tell, upcoming_event(UpcomingEvent)).

// This plan reacts to the call for proposal to increase the illuminance.
// It sends a refuse message to the sender because
// the calendar manager cannot increase the illuminance.
@cfp_increase_illuminance_plan
+!cfp(increase_illuminance)[source(Sender)] : true <-
    .send(Sender, tell, refuse(increase_illuminance)).

{ include("$jacamoJar/templates/common-cartago.asl") }
