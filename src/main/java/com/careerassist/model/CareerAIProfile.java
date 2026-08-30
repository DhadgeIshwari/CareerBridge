package com.careerassist.model;

import java.util.ArrayList;
import java.util.List;

/** Live data snapshot for dynamic AI career mentoring. */
public class CareerAIProfile {
    private List<String> resumeSkills = new ArrayList<>();
    private SkillGap skillGap;
    private CareerContext careerContext;
    private List<JobFeedItem> matchedJobs = new ArrayList<>();
    private List<String> missingSkills = new ArrayList<>();
    private List<String> learningSkills = new ArrayList<>();
    private double readinessPct;
    private String targetRoleTitle;
    private String roleDomainLabel;

    public List<String> getResumeSkills() { return resumeSkills; }
    public void setResumeSkills(List<String> resumeSkills) { this.resumeSkills = resumeSkills; }
    public SkillGap getSkillGap() { return skillGap; }
    public void setSkillGap(SkillGap skillGap) { this.skillGap = skillGap; }
    public CareerContext getCareerContext() { return careerContext; }
    public void setCareerContext(CareerContext careerContext) { this.careerContext = careerContext; }
    public List<JobFeedItem> getMatchedJobs() { return matchedJobs; }
    public void setMatchedJobs(List<JobFeedItem> matchedJobs) { this.matchedJobs = matchedJobs; }
    public List<String> getMissingSkills() { return missingSkills; }
    public void setMissingSkills(List<String> missingSkills) { this.missingSkills = missingSkills; }
    public List<String> getLearningSkills() { return learningSkills; }
    public void setLearningSkills(List<String> learningSkills) { this.learningSkills = learningSkills; }
    public double getReadinessPct() { return readinessPct; }
    public void setReadinessPct(double readinessPct) { this.readinessPct = readinessPct; }
    public String getTargetRoleTitle() { return targetRoleTitle; }
    public void setTargetRoleTitle(String targetRoleTitle) { this.targetRoleTitle = targetRoleTitle; }
    public String getRoleDomainLabel() { return roleDomainLabel; }
    public void setRoleDomainLabel(String roleDomainLabel) { this.roleDomainLabel = roleDomainLabel; }

    public boolean hasResume() { return resumeSkills != null && !resumeSkills.isEmpty(); }
    public boolean hasGap() { return skillGap != null && skillGap.getTargetTitle() != null; }
}
