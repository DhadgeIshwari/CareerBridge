package com.careerassist.model;

public class Application {
    private int applicationId, userId;
    private Integer jobId, apiJobId, scrapedJobId;
    private String jobSource, status, studentName, jobTitle, company, appliedAt;

    public int getApplicationId() { return applicationId; }
    public void setApplicationId(int applicationId) { this.applicationId = applicationId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Integer getJobId() { return jobId; }
    public void setJobId(Integer jobId) { this.jobId = jobId; }
    public Integer getApiJobId() { return apiJobId; }
    public void setApiJobId(Integer apiJobId) { this.apiJobId = apiJobId; }
    public Integer getScrapedJobId() { return scrapedJobId; }
    public void setScrapedJobId(Integer scrapedJobId) { this.scrapedJobId = scrapedJobId; }
    public String getJobSource() { return jobSource; }
    public void setJobSource(String jobSource) { this.jobSource = jobSource; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }
    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }
    public String getAppliedAt() { return appliedAt; }
    public void setAppliedAt(String appliedAt) { this.appliedAt = appliedAt; }
}
