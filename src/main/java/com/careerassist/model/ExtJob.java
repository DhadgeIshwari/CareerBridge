package com.careerassist.model;

public class ExtJob {
    private int id;
    private String externalId;
    private String title, company, location, skills, url, source, description, postedLabel;
    private double matchPct;
    private boolean highMatch;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getExternalId() { return externalId; }
    public void setExternalId(String externalId) { this.externalId = externalId; }
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
    public String getPostedLabel() { return postedLabel; }
    public void setPostedLabel(String postedLabel) { this.postedLabel = postedLabel; }
    public double getMatchPct() { return matchPct; }
    public void setMatchPct(double matchPct) { this.matchPct = matchPct; }
    public boolean isHighMatch() { return highMatch; }
    public void setHighMatch(boolean highMatch) { this.highMatch = highMatch; }
}
