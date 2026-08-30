package com.careerassist.model;

/** A hands-on practice platform recommendation for a skill. */
public class PracticeLink {
    private String name;
    private String url;
    private String description;

    public PracticeLink() {}

    public PracticeLink(String name, String url, String description) {
        this.name = name;
        this.url = url;
        this.description = description;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
