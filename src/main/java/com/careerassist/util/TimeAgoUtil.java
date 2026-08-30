package com.careerassist.util;

import java.sql.Timestamp;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;

public final class TimeAgoUtil {
    private TimeAgoUtil() {}

    public static String formatPosted(Timestamp ts) {
        if (ts == null) return "Posted recently";
        Instant then = ts.toInstant();
        Duration d = Duration.between(then, Instant.now());
        long minutes = d.toMinutes();
        if (minutes < 1) return "Posted just now";
        if (minutes < 60) return "Posted " + minutes + (minutes == 1 ? " minute" : " minutes") + " ago";
        long hours = d.toHours();
        if (hours < 24) return "Posted " + hours + (hours == 1 ? " hour" : " hours") + " ago";
        long days = d.toDays();
        if (days < 7) return "Posted " + days + (days == 1 ? " day" : " days") + " ago";
        return "Posted " + ts.toLocalDateTime().toLocalDate().toString();
    }

    public static String formatApplied(String appliedAt) {
        if (appliedAt == null || appliedAt.isBlank()) return "";
        try {
            return formatPosted(Timestamp.valueOf(appliedAt.replace('T', ' ').substring(0, 19)));
        } catch (Exception e) {
            return appliedAt;
        }
    }
}
