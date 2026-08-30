package com.careerassist.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Job {
    private int jobId, hrId;
    private String title, company, location, description, requirements, salaryRange, status;
    private String jobType, experienceLevel, applicationDeadline, domain;
    private Timestamp postedAt;
    private List<String> skills = new ArrayList<>();
    private double matchPct;

    public int getJobId() { return jobId; }
    public void setJobId(int jobId) { this.jobId = jobId; }
    public int getHrId() { return hrId; }
    public void setHrId(int hrId) { this.hrId = hrId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCompany() { return company; }
    public void setCompany(String company) { this.company = company; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }
    public String getSalaryRange() { return salaryRange; }
    public void setSalaryRange(String salaryRange) { this.salaryRange = salaryRange; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Timestamp getPostedAt() { return postedAt; }
    public void setPostedAt(Timestamp postedAt) { this.postedAt = postedAt; }
    public List<String> getSkills() { return skills; }
    public void setSkills(List<String> skills) { this.skills = skills; }
    public double getMatchPct() { return matchPct; }
    public void setMatchPct(double matchPct) { this.matchPct = matchPct; }
    public String getJobType() { return jobType; }
    public void setJobType(String jobType) { this.jobType = jobType; }
    public String getExperienceLevel() { return experienceLevel; }
    public void setExperienceLevel(String experienceLevel) { this.experienceLevel = experienceLevel; }
    public String getApplicationDeadline() { return applicationDeadline; }
    public void setApplicationDeadline(String applicationDeadline) { this.applicationDeadline = applicationDeadline; }
    public String getDomain() { return domain; }
    public void setDomain(String domain) { this.domain = domain; }
}
