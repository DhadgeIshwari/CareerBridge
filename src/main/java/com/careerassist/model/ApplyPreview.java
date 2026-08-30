package com.careerassist.model;

import java.util.List;

/** Data shown on the internal apply review page before tracking an application. */
public class ApplyPreview {
    private String feedType;
    private int refId;
    private String title;
    private String company;
    private String location;
    private String source;
    private String description;
    private String externalUrl;
    private double matchPct;
    private List<String> userSkills;
    private List<String> matchedSkills;
    private List<String> missingSkills;
    private String resumeSummary;
    private String whyRecommended;
    private boolean alreadyApplied;

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
    public String getSource() { return source; }
    public void setSource(String source) { this.source = source; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getExternalUrl() { return externalUrl; }
    public void setExternalUrl(String externalUrl) { this.externalUrl = externalUrl; }
    public double getMatchPct() { return matchPct; }
    public void setMatchPct(double matchPct) { this.matchPct = matchPct; }
    public List<String> getUserSkills() { return userSkills; }
    public void setUserSkills(List<String> userSkills) { this.userSkills = userSkills; }
    public List<String> getMatchedSkills() { return matchedSkills; }
    public void setMatchedSkills(List<String> matchedSkills) { this.matchedSkills = matchedSkills; }
    public List<String> getMissingSkills() { return missingSkills; }
    public void setMissingSkills(List<String> missingSkills) { this.missingSkills = missingSkills; }
    public String getResumeSummary() { return resumeSummary; }
    public void setResumeSummary(String resumeSummary) { this.resumeSummary = resumeSummary; }
    public String getWhyRecommended() { return whyRecommended; }
    public void setWhyRecommended(String whyRecommended) { this.whyRecommended = whyRecommended; }
    public boolean isAlreadyApplied() { return alreadyApplied; }
    public void setAlreadyApplied(boolean alreadyApplied) { this.alreadyApplied = alreadyApplied; }
}
