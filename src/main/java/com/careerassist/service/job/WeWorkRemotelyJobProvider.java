package com.careerassist.service.job;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.careerassist.model.ExtJob;
import com.careerassist.util.AppUtil;

/**
 * We Work Remotely RSS feed (official public RSS).
 */
public class WeWorkRemotelyJobProvider {

    private static final String RSS_URL = "https://weworkremotely.com/remote-jobs.rss";
    private static final Pattern ITEM = Pattern.compile("<item>(.*?)</item>", Pattern.DOTALL);
    private static final Pattern TITLE = Pattern.compile("<title><!\\[CDATA\\[(.*?)\\]\\]></title>|<title>([^<]+)</title>");
    private static final Pattern LINK = Pattern.compile("<link>([^<]+)</link>");
    private static final Pattern DESC = Pattern.compile("<description><!\\[CDATA\\[(.*?)\\]\\]></description>", Pattern.DOTALL);

    private final HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(12)).build();

    public List<ExtJob> fetch() throws Exception {
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(RSS_URL))
                .timeout(Duration.ofSeconds(20))
                .header("User-Agent", "CareerAssist/1.0")
                .GET()
                .build();

        HttpResponse<String> resp = client.send(req, HttpResponse.BodyHandlers.ofString());
        if (resp.statusCode() != 200) {
            throw new IllegalStateException("WeWorkRemotely RSS returned " + resp.statusCode());
        }

        List<ExtJob> jobs = new ArrayList<>();
        Matcher m = ITEM.matcher(resp.body());
        while (m.find() && jobs.size() < 20) {
            String block = m.group(1);
            String title = firstGroup(TITLE.matcher(block));
            String link = firstGroup(LINK.matcher(block));
            if (title == null || link == null || link.isBlank()) continue;

            Matcher dm = DESC.matcher(block);
            String desc = dm.find() ? dm.group(1).replaceAll("<[^>]+>", " ").trim() : "";

            ExtJob j = new ExtJob();
            j.setSource("WEWORKREMOTELY");
            j.setExternalId(link);
            j.setTitle(parseJobTitle(title));
            j.setCompany(parseCompany(title));
            j.setLocation("Remote");
            j.setDescription(desc.length() > 500 ? desc.substring(0, 500) : desc);
            j.setUrl(link);
            List<String> skills = AppUtil.extractSkills(title + " " + desc);
            j.setSkills(String.join(", ", skills));
            jobs.add(j);
        }
        return jobs;
    }

    private static String parseJobTitle(String rssTitle) {
        int idx = rssTitle.indexOf(':');
        if (idx > 0 && idx < rssTitle.length() - 1) {
            return rssTitle.substring(idx + 1).trim();
        }
        return rssTitle.trim();
    }

    private static String parseCompany(String rssTitle) {
        int idx = rssTitle.indexOf(':');
        if (idx > 0) return rssTitle.substring(0, idx).trim();
        return "Remote Company";
    }

    private static String firstGroup(Matcher m) {
        if (!m.find()) return null;
        return m.group(1) != null ? m.group(1).trim() : (m.groupCount() > 1 ? m.group(2).trim() : null);
    }
}
