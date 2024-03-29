package room;

import cartago.Artifact;
import cartago.OPERATION;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

// import com.google.gson.Gson;
// import com.google.gson.JsonArray;
// import com.google.gson.JsonObject;

/**
 * A CArtAgO artifact that provides an operation for sending messages to agents
 * with KQML performatives using the dweet.io API
 */
public class DweetArtifact extends Artifact {

   int count = 0;

   public void init() {
   }

   @OPERATION
   public void sendDweet(String message) {
      try {
         URI uri = new URI("https://dweet.io/dweet/for/brablbrubl");
         // String authString = USERNAME + ":" + PASSWORD;
         // byte[] authBytes = authString.getBytes(StandardCharsets.UTF_8);
         // String encodedAuth = Base64.getEncoder().encodeToString(authBytes);
         String payload = "{\"goal\":\"" + message + "\"}";

         HttpRequest request = HttpRequest.newBuilder()
               .uri(uri)
               // .header("Authorization", "Basic " + encodedAuth)
               .header("Content-Type", "application/json")
               .header("Accept", "application/json")
               .POST(HttpRequest.BodyPublishers.ofString(payload))
               .build();

         HttpClient client = HttpClient.newHttpClient();

         System.out.println("sending message");
         HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
         System.out.println("message sent");
         if (response.statusCode() != 200) {
            throw new RuntimeException("HTTP error code : " + response.statusCode());
         }
         // String responseBody = response.body();
         // JsonObject jsonObject = new Gson().fromJson(responseBody, JsonObject.class);
         // JsonArray bindingsArray =
         // jsonObject.getAsJsonObject("results").getAsJsonArray("bindings");

      } catch (URISyntaxException e) {
         e.printStackTrace();
      } catch (IOException e) {
         e.printStackTrace();
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
   }
}
