package com.careerassist.util;
import java.sql.DatabaseMetaData;
import java.util.ArrayList;
import java.util.List;

import com.careerassist.model.JobDomain;
import com.careerassist.model.JobFeedItem;

/**
 * Strict job filtering: minimum match, skill overlap, and domain rules.
 */
public final class JobRelevanceEngine {

    public static final double MIN_MATCH_PCT = 40.0;
    public static final double CROSS_DOMAIN_MIN_PCT = 70.0;
    public static final double HIGH_MATCH_PCT = 60.0;

    private JobRelevanceEngine() {}

    public static boolean passesFilter(List<String> userSkills, List<String> jobSkills,
                                       String title, String description, JobDomain userDomain) {
        return passesFilter(userSkills, jobSkills, title, description, userDomain, MIN_MATCH_PCT);
    }

    /** Role-context feed: filter by selected career domain and match threshold.
     *  Domain filtering is ALWAYS enforced — GENERAL domain falls back to skill-detected domain. */
    public static boolean passesFilterForRoleContext(List<String> userSkills, List<String> jobSkills,
                                                     String title, String description,
                                                     JobDomain selectedRoleDomain, double minMatchPct) {
        if (userSkills == null || userSkills.isEmpty()) return false;
        List<String> req = jobSkills != null && !jobSkills.isEmpty()
                ? jobSkills
                : AppUtil.extractSkills(((title == null ? "" : title) + " " + (description == null ? "" : description)).trim());
        if (req.isEmpty()) return false;

        double match = AppUtil.matchPercent(userSkills, req);
        if (match < minMatchPct) return false;
        if (!AppUtil.hasSkillOverlap(userSkills, req)) return false;

        // Resolve effective user domain: prefer session role context, fall back to skill detection
        JobDomain effectiveDomain = (selectedRoleDomain != null && selectedRoleDomain != JobDomain.GENERAL)
                ? selectedRoleDomain
                : AppUtil.detectUserDomain(userSkills);

        JobDomain jobDomain = AppUtil.classifyJobDomain(title, description, req);
        return AppUtil.allowJobForUser(effectiveDomain, jobDomain, match);
    }

    public static boolean passesFilter(List<String> userSkills, List<String> jobSkills,
                                       String title, String description, JobDomain userDomain,
                                       double minMatchPct) {
        if (userSkills == null || userSkills.isEmpty()) {
            return false;
        }
        List<String> req = jobSkills != null && !jobSkills.isEmpty()
                ? jobSkills
                : AppUtil.extractSkills(((title == null ? "" : title) + " " + (description == null ? "" : description)).trim());
        if (req.isEmpty()) {
            return false;
        }
        double match = AppUtil.matchPercent(userSkills, req);
        if (match < minMatchPct) {
            return false;
        }
        if (!AppUtil.hasSkillOverlap(userSkills, req)) {
            return false;
        }
        JobDomain jobDomain = AppUtil.classifyJobDomain(title, description, req);
        return AppUtil.allowJobForUser(userDomain, jobDomain, match);
    }

    public static JobFeedItem enrichFeedItem(JobFeedItem item, List<String> userSkills) {
        List<String> req = AppUtil.parseList(item.getSkills());
        if (req.isEmpty() && item.getDescription() != null) {
            req = AppUtil.extractSkills(item.getTitle() + " " + item.getDescription());
            item.setSkills(String.join(", ", req));
        }
        double match = AppUtil.matchPercent(userSkills, req);
        item.setMatchPct(match);
        item.setHighMatch(match >= HIGH_MATCH_PCT);
        item.setMatchedSkills(String.join(", ", AppUtil.matched(userSkills, req)));
        item.setMissingSkills(String.join(", ", AppUtil.missing(userSkills, req)));
        JobDomain jd = AppUtil.classifyJobDomain(item.getTitle(), item.getDescription(), req);
        item.setDomainLabel(formatDomain(jd));
        if (item.getUrl() != null && !item.getUrl().isBlank()) {
            item.setApplyUrl(item.getUrl());
        }
        return item;
    }

    public static String formatDomain(JobDomain d) {
        if (d == null || d == JobDomain.GENERAL) return "General";
        return d.name().replace('_', ' ');
    }

    public record ScoredJob(String feedType, int refId, String title, List<String> jobSkills,
                            double matchPct, JobDomain jobDomain) {}

    /** Best matching job across internal + external sources for auto skill-gap. */
    public static ScoredJob findBestMatch(List<String> userSkills, JobDomain userDomain,
                                          List<ScoredJob> candidates) {
        ScoredJob best = null;
        for (ScoredJob c : candidates) {
            if (!passesFilter(userSkills, c.jobSkills(), c.title(), null, userDomain)) {
                continue;
            }
            if (best == null || c.matchPct() > best.matchPct()) {
                best = c;
            }
        }
        return best;
    }

    public static List<String> jobSkillsOrExtract(String skillsCsv, String title, String description) {
        List<String> req = AppUtil.parseList(skillsCsv);
        if (!req.isEmpty()) return req;
        return AppUtil.extractSkills(((title == null ? "" : title) + " " + (description == null ? "" : description)).trim());
    }
}
