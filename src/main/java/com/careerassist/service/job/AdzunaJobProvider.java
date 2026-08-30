package com.careerassist.service.job;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
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
 * Fetches jobs from the official Adzuna API (requires app_id and app_key).
 * @see https://developer.adzuna.com/
 */
public class AdzunaJobProvider {

    private final String appId;
    private final String appKey;
    private final String country;
    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(12)).build();

    public AdzunaJobProvider(String appId, String appKey, String country) {
        this.appId = appId;
        this.appKey = appKey;
        this.country = country != null && !country.isBlank() ? country : "in";
    }

    public boolean isConfigured() {
        return appId != null && !appId.isBlank() && appKey != null && !appKey.isBlank();
    }

    public List<ExtJob> fetch(String keywords) throws Exception {
        if (!isConfigured()) return List.of();

        String q = keywords == null || keywords.isBlank() ? "software developer" : keywords;
        String url = String.format(
                "https://api.adzuna.com/v1/api/jobs/%s/search/1?app_id=%s&app_key=%s&results_per_page=15&what=%s",
                country,
                enc(appId),
                enc(appKey),
                enc(q));

        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .timeout(Duration.ofSeconds(15))
                .header("Accept", "application/json")
                .GET()
                .build();

        HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200) {
            throw new IllegalStateException("Adzuna API returned " + resp.statusCode());
        }

        List<ExtJob> jobs = new ArrayList<>();
        JsonObject root = JsonParser.parseString(resp.body()).getAsJsonObject();
        JsonArray results = root.has("results") ? root.getAsJsonArray("results") : new JsonArray();

        for (JsonElement el : results) {
            JsonObject o = el.getAsJsonObject();
            ExtJob j = new ExtJob();
            j.setSource("ADZUNA");
            j.setExternalId(o.has("id") ? o.get("id").getAsString() : null);
            j.setTitle(text(o, "title"));
            j.setCompany(o.has("company") && o.get("company").isJsonObject()
                    ? text(o.getAsJsonObject("company"), "display_name") : "");
            j.setLocation(o.has("location") && o.get("location").isJsonObject()
                    ? text(o.getAsJsonObject("location"), "display_name") : "");
            j.setDescription(text(o, "description"));
            j.setUrl(text(o, "redirect_url"));
            List<String> skills = AppUtil.extractSkills(j.getTitle() + " " + j.getDescription());
            j.setSkills(String.join(", ", skills));
            if (j.getTitle() != null && !j.getTitle().isBlank()
                    && j.getUrl() != null && !j.getUrl().isBlank()) {
                jobs.add(j);
            }
        }
        return jobs;
    }

    private static String text(JsonObject o, String key) {
        return o.has(key) && !o.get(key).isJsonNull() ? o.get(key).getAsString() : "";
    }

    private static String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
