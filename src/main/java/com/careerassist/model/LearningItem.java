package com.careerassist.model;

public class LearningItem {
    private String skillName, levelStage, title, resourceUrl, platform;
    /** Comma-separated practice platform summary: Name|url;Name|url */
    private String practicePlatforms;

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }
    public String getLevelStage() { return levelStage; }
    public void setLevelStage(String levelStage) { this.levelStage = levelStage; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getResourceUrl() { return resourceUrl; }
    public void setResourceUrl(String resourceUrl) { this.resourceUrl = resourceUrl; }
    public String getPlatform() { return platform; }
    public void setPlatform(String platform) { this.platform = platform; }
    public String getPracticePlatforms() { return practicePlatforms; }
    public void setPracticePlatforms(String practicePlatforms) { this.practicePlatforms = practicePlatforms; }

    public boolean isLearnStage() {
        return "BEGINNER".equals(levelStage) || "INTERMEDIATE".equals(levelStage)
                || "ADVANCED".equals(levelStage) || "PROJECTS".equals(levelStage);
    }

    public boolean isReadStage() {
        return levelStage != null && levelStage.startsWith("READ");
    }

    public boolean isPracticeStage() {
        return "PRACTICE".equals(levelStage);
    }
}
