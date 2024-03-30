package room;

import cartago.Artifact;
import cartago.OPERATION;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

   public void init() {
   }

   @OPERATION
   public void sendDweet(String action, String receiver, String performative, String content) {
      try {
         URI uri = new URI("https://dweet.io/dweet/for/jonas-exercise6");

         String payload = "{ \"action\": \"" + action + "\", \"receiver\": \"" + receiver + "\", \"performative\": \""
               + performative + "\", \"content\": \"" + content + "\" }";

         HttpRequest request = HttpRequest.newBuilder()
               .uri(uri)
               .header("Content-Type", "application/json")
               .POST(HttpRequest.BodyPublishers.ofString(payload))
               .build();

         HttpClient client = HttpClient.newHttpClient();

         HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

         if (response.statusCode() != 200) {
            throw new RuntimeException("HTTP error code : " + response.statusCode());
         }
      } catch (URISyntaxException e) {
         e.printStackTrace();
      } catch (IOException e) {
         e.printStackTrace();
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
   }
}
