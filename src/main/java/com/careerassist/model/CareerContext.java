package com.careerassist.model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import com.careerassist.util.AppUtil;
import com.careerassist.model.JobDomain;

/**
 * Session-scoped target job role driving skill gap, learning path, and job feed.
 */
public class CareerContext implements Serializable {
    private static final long serialVersionUID = 1L;

    private Integer jobId;
    private String feedType;
    private Integer refId;
    private String targetTitle;
    private String roleDomain;
    private String requiredSkillsCsv;
    private double readinessPct;

    public static CareerContext fromJob(Job job, List<String> userSkills) {
        List<String> req = job.getSkills().isEmpty()
                ? AppUtil.parseList(job.getRequirements()) : job.getSkills();
        CareerContext ctx = new CareerContext();
        ctx.jobId = job.getJobId();
        ctx.feedType = "INTERNAL";
        ctx.refId = job.getJobId();
        ctx.targetTitle = job.getTitle();
        ctx.roleDomain = AppUtil.classifyJobDomain(job.getTitle(), job.getDescription(), req).name();
        ctx.requiredSkillsCsv = String.join(", ", req);
        ctx.readinessPct = AppUtil.matchPercent(userSkills, req);
        return ctx;
    }

    public static CareerContext fromDomain(JobDomain domain, String displayTitle,
                                           List<String> required, List<String> userSkills) {
        CareerContext ctx = new CareerContext();
        ctx.targetTitle = displayTitle;
        ctx.roleDomain = domain.name();
        ctx.requiredSkillsCsv = String.join(", ", required);
        ctx.readinessPct = AppUtil.matchPercent(userSkills, required);
        return ctx;
    }

    public List<String> getRequiredSkills() {
        return AppUtil.parseList(requiredSkillsCsv);
    }

    public JobDomain getRoleDomainEnum() {
        if (roleDomain == null || roleDomain.isBlank()) {
            return JobDomain.GENERAL;
        }
        try {
            return JobDomain.valueOf(roleDomain);
        } catch (IllegalArgumentException e) {
            return JobDomain.GENERAL;
        }
    }

    public Integer getJobId() { return jobId; }
    public void setJobId(Integer jobId) { this.jobId = jobId; }
    public String getFeedType() { return feedType; }
    public void setFeedType(String feedType) { this.feedType = feedType; }
    public Integer getRefId() { return refId; }
    public void setRefId(Integer refId) { this.refId = refId; }
    public String getTargetTitle() { return targetTitle; }
    public void setTargetTitle(String targetTitle) { this.targetTitle = targetTitle; }
    public String getRoleDomain() { return roleDomain; }
    public void setRoleDomain(String roleDomain) { this.roleDomain = roleDomain; }
    public String getRequiredSkillsCsv() { return requiredSkillsCsv; }
    public void setRequiredSkillsCsv(String requiredSkillsCsv) { this.requiredSkillsCsv = requiredSkillsCsv; }
    public double getReadinessPct() { return readinessPct; }
    public void setReadinessPct(double readinessPct) { this.readinessPct = readinessPct; }
}
