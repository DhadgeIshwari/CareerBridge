package com.careerassist.model;

/** Unified job card for the live feed (internal, Adzuna, Indeed-style, scraped). */
public class JobFeedItem {
    private String feedType;
    private int refId;
    private String title;
    private String company;
    private String location;
    private String skills;
    private String url;
    private String source;
    private String description;
    private double matchPct;
    private String postedLabel;
    private boolean highMatch;
    private boolean alreadyApplied;
    private String matchedSkills;
    private String missingSkills;
    private String domainLabel;
    private String applyUrl;

    public String getFeedType() { return feedType; }
    public void setFeedType(String feedType) { this.feedType = feedType; }
    public int getRefId() { return refId; }
    public void setRefId(int refId) { this.refId = refId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getSkills() { return skills; }
    public void setSkills(String skills) { this.skills = skills; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public double getMatchPct() { return matchPct; }
    public void setMatchPct(double matchPct) { this.matchPct = matchPct; }
    public String getPostedLabel() { return postedLabel; }
    public void setPostedLabel(String postedLabel) { this.postedLabel = postedLabel; }
    public boolean isHighMatch() { return highMatch; }
    public void setHighMatch(boolean highMatch) { this.highMatch = highMatch; }
    public boolean isAlreadyApplied() { return alreadyApplied; }
    public void setAlreadyApplied(boolean alreadyApplied) { this.alreadyApplied = alreadyApplied; }
    public String getMatchedSkills() { return matchedSkills; }
    public void setMatchedSkills(String matchedSkills) { this.matchedSkills = matchedSkills; }
    public String getMissingSkills() { return missingSkills; }
    public void setMissingSkills(String missingSkills) { this.missingSkills = missingSkills; }
    public String getDomainLabel() { return domainLabel; }
    public void setDomainLabel(String domainLabel) { this.domainLabel = domainLabel; }
    public String getApplyUrl() { return applyUrl != null && !applyUrl.isBlank() ? applyUrl : url; }
    public void setApplyUrl(String applyUrl) { this.applyUrl = applyUrl; }

    public int getFreshnessDays() {
        if (postedLabel == null || postedLabel.isBlank()) return 99;
        String pl = postedLabel.toLowerCase();
        if (pl.contains("today") || pl.contains("just now") || pl.contains("hour") || pl.contains("minute")) {
            return 0;
        }
        if (pl.contains("day")) {
            try {
                String num = pl.replaceAll("[^0-9]", "");
                if (!num.isEmpty()) return Integer.parseInt(num);
                return 1;
            } catch (Exception ex) {
                return 1;
            }
        }
        if (pl.contains("week")) {
            try {
                String num = pl.replaceAll("[^0-9]", "");
                if (!num.isEmpty()) return Integer.parseInt(num) * 7;
                return 7;
            } catch (Exception ex) {
                return 7;
            }
        }
        if (pl.contains("month")) {
            try {
                String num = pl.replaceAll("[^0-9]", "");
                if (!num.isEmpty()) return Integer.parseInt(num) * 30;
                return 30;
            } catch (Exception ex) {
                return 30;
            }
        }
        return 60;
    }

    public String getFreshnessBadge() {
        int days = getFreshnessDays();
        if (days <= 2) return "NEW";
        if (days <= 7) return "THIS_WEEK";
        if (days <= 30) return "THIS_MONTH";
        return "OLDER";
    }
}
