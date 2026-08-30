package com.careerassist.model;

public class ResumeScore {
    private int userId;
    private int score;
    private String analyzedAt;
    private int matchedPoints;
    private int missingPoints;
    private int jobRelevancePoints;
    private int matchedSkillCount;
    private int missingSkillCount;

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public int getScore() { return score; }
    public void setScore(int score) { this.score = score; }
    public String getAnalyzedAt() { return analyzedAt; }
    public void setAnalyzedAt(String analyzedAt) { this.analyzedAt = analyzedAt; }
    public int getMatchedPoints() { return matchedPoints; }
    public void setMatchedPoints(int matchedPoints) { this.matchedPoints = matchedPoints; }
    public int getMissingPoints() { return missingPoints; }
    public void setMissingPoints(int missingPoints) { this.missingPoints = missingPoints; }
    public int getJobRelevancePoints() { return jobRelevancePoints; }
    public void setJobRelevancePoints(int jobRelevancePoints) { this.jobRelevancePoints = jobRelevancePoints; }
    public int getMatchedSkillCount() { return matchedSkillCount; }
    public void setMatchedSkillCount(int matchedSkillCount) { this.matchedSkillCount = matchedSkillCount; }
    public int getMissingSkillCount() { return missingSkillCount; }
    public void setMissingSkillCount(int missingSkillCount) { this.missingSkillCount = missingSkillCount; }
}
