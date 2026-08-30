package com.careerassist.model;

public class SkillGap {
    private int gapId, userId;
    private Integer jobId;
    private String targetTitle, requiredSkills, acquiredSkills, missingSkills;
    private double gapPercentage;
    private String status;

    public int getGapId() { return gapId; }
    public void setGapId(int gapId) { this.gapId = gapId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Integer getJobId() { return jobId; }
    public void setJobId(Integer jobId) { this.jobId = jobId; }
    public String getTargetTitle() { return targetTitle; }
    public void setTargetTitle(String targetTitle) { this.targetTitle = targetTitle; }
    public String getRequiredSkills() { return requiredSkills; }
    public void setRequiredSkills(String requiredSkills) { this.requiredSkills = requiredSkills; }
    public String getAcquiredSkills() { return acquiredSkills; }
    public void setAcquiredSkills(String acquiredSkills) { this.acquiredSkills = acquiredSkills; }
    public String getMissingSkills() { return missingSkills; }
    public void setMissingSkills(String missingSkills) { this.missingSkills = missingSkills; }
    public double getGapPercentage() { return gapPercentage; }
    public void setGapPercentage(double gapPercentage) { this.gapPercentage = gapPercentage; }
    
    public String getStatus() {
        if (status != null) return status;
        if (gapPercentage <= 0 || missingSkills == null || missingSkills.trim().isEmpty()) {
            return "JOB_READY";
        }
        return "NEEDS_UPSKILLING";
    }
    public void setStatus(String status) { this.status = status; }
}
