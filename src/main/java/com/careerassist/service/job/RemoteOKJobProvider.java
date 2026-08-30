package com.careerassist.service.job;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;

import com.careerassist.model.ExtJob;
import com.careerassist.util.AppUtil;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * RemoteOK public API — https://remoteok.com/api
 */
public class RemoteOKJobProvider {

    private static final String API_URL = "https://remoteok.com/api";
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(12)).build();

    public List<ExtJob> fetch() throws Exception {
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(API_URL))
                .timeout(Duration.ofSeconds(20))
                .header("Accept", "application/json")
                .header("User-Agent", "CareerAssist/1.0")
                .GET()
                .build();

        HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200) {
            throw new IllegalStateException("RemoteOK API returned " + resp.statusCode());
        }

        List<ExtJob> jobs = new ArrayList<>();
        JsonArray arr = JsonParser.parseString(resp.body()).getAsJsonArray();

        for (JsonElement el : arr) {
            if (!el.isJsonObject()) continue;
            JsonObject o = el.getAsJsonObject();
            if (!o.has("position") && !o.has("company")) continue;

            String url = text(o, "url");
            if (url == null || url.isBlank()) continue;

            ExtJob j = new ExtJob();
            j.setSource("REMOTEOK");
            j.setExternalId(o.has("id") ? String.valueOf(o.get("id")) : url);
            j.setTitle(text(o, "position"));
            j.setCompany(text(o, "company"));
            j.setLocation(text(o, "location"));
            if (j.getLocation() == null || j.getLocation().isBlank()) {
                j.setLocation("Remote");
            }
            j.setDescription(text(o, "description"));
            j.setUrl(url.startsWith("http") ? url : "https://remoteok.com" + url);
            String tags = tagsToSkills(o);
            List<String> skills = AppUtil.extractSkills(
                    j.getTitle() + " " + tags + " " + (j.getDescription() == null ? "" : j.getDescription()));
            j.setSkills(skills.isEmpty() ? tags : String.join(", ", skills));
            if (j.getTitle() != null && !j.getTitle().isBlank()) {
                jobs.add(j);
            }
            if (jobs.size() >= 25) break;
        }
        return jobs;
    }

    private static String tagsToSkills(JsonObject o) {
        if (!o.has("tags")) return "";

        StringBuilder sb = new StringBuilder();
        JsonElement tags = o.get("tags");

        if (tags.isJsonArray()) {
            for (JsonElement t : tags.getAsJsonArray()) {
                if (sb.length() > 0) sb.append(", ");
                sb.append(t.getAsString());
            }
        }

        return sb.toString();
    }

    private static String text(JsonObject o, String key) {
        return o.has(key) && !o.get(key).isJsonNull() ? o.get(key).getAsString().trim() : "";
    }
}
