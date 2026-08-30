package com.careerassist.service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.careerassist.dao.CareerDAO;
import com.careerassist.model.CareerContext;
import com.careerassist.model.ExtJob;
import com.careerassist.model.Job;
import com.careerassist.model.JobDomain;
import com.careerassist.model.JobFeedItem;
import com.careerassist.service.job.AdzunaJobProvider;
import com.careerassist.service.job.RemoteOKJobProvider;
import com.careerassist.service.job.WeWorkRemotelyJobProvider;
import com.careerassist.util.AppUtil;
import com.careerassist.util.JobRelevanceEngine;
import com.careerassist.util.TimeAgoUtil;

import jakarta.servlet.ServletContext;

public class JobFeedService {

    private final CareerDAO dao = new CareerDAO();

    /** Fetches external jobs filtered to the selected career role domain. */
    public String refreshLiveFeed(ServletContext ctx, List<String> userSkills, JobDomain roleDomain) {
        int added = 0;
        StringBuilder log = new StringBuilder();
        JobDomain domain = roleDomain != null && roleDomain != JobDomain.GENERAL
                ? roleDomain : AppUtil.detectUserDomain(userSkills);
        String keywords = AppUtil.searchKeywordsForDomain(domain);

        if (userSkills == null || userSkills.isEmpty()) {
            return "Upload your resume first — jobs are filtered to your selected role and skills.";
        }

        try {
            String appId = ctx.getInitParameter("adzuna.app_id");
            String appKey = ctx.getInitParameter("adzuna.app_key");
            String country = ctx.getInitParameter("adzuna.country");
            AdzunaJobProvider adzuna = new AdzunaJobProvider(appId, appKey, country);
            if (adzuna.isConfigured()) {
                for (ExtJob j : adzuna.fetch(keywords)) {
                    if (ingestExternalJob(j, userSkills, domain, "API", CareerContextService.ROLE_FEED_MIN_MATCH)) added++;
                }
                log.append("Adzuna filtered. ");
            } else {
                log.append("Adzuna: set adzuna.app_id and adzuna.app_key in web.xml. ");
            }
        } catch (Exception e) {
            log.append("Adzuna: ").append(e.getMessage()).append(". ");
        }

        try {
            for (ExtJob j : new RemoteOKJobProvider().fetch()) {
                if (ingestExternalJob(j, userSkills, domain, "API", CareerContextService.ROLE_FEED_MIN_MATCH)) added++;
            }
            log.append("RemoteOK filtered. ");
        } catch (Exception e) {
            log.append("RemoteOK: ").append(e.getMessage()).append(". ");
        }

        try {
            for (ExtJob j : new WeWorkRemotelyJobProvider().fetch()) {
                if (ingestExternalJob(j, userSkills, domain, "SCRAPED", CareerContextService.ROLE_FEED_MIN_MATCH)) added++;
            }
            log.append("WeWorkRemotely filtered. ");
        } catch (Exception e) {
            log.append("WWR: ").append(e.getMessage()).append(". ");
        }

        return added + " relevant jobs stored. " + log;
    }

    public String refreshLiveFeed(ServletContext ctx, List<String> userSkills) {
        return refreshLiveFeed(ctx, userSkills, AppUtil.detectUserDomain(userSkills));
    }

    private boolean ingestExternalJob(ExtJob j, List<String> userSkills, JobDomain roleDomain,
                                      String storeType, double minMatch) throws Exception {
        if (j.getUrl() == null || j.getUrl().isBlank()) return false;
        List<String> jobSkills = JobRelevanceEngine.jobSkillsOrExtract(j.getSkills(), j.getTitle(), j.getDescription());
        if (!JobRelevanceEngine.passesFilterForRoleContext(userSkills, jobSkills,
                j.getTitle(), j.getDescription(), roleDomain, minMatch)) {
            return false;
        }
        j.setSkills(String.join(", ", jobSkills));
        return "API".equals(storeType) ? dao.upsertApiJob(j) > 0 : dao.upsertScrapedJob(j) > 0;
    }

    public List<JobFeedItem> buildLiveFeed(int userId, List<String> userSkills) throws Exception {
        return buildLiveFeed(userId, userSkills, null);
    }

    public List<JobFeedItem> buildLiveFeed(int userId, List<String> userSkills, CareerContext roleCtx)
            throws Exception {
        if (userSkills == null || userSkills.isEmpty()) {
            return List.of();
        }

        // Always resolve domain: prefer session role context if specific, otherwise detect from skills
        JobDomain ctxDomain = roleCtx != null ? roleCtx.getRoleDomainEnum() : null;
        JobDomain roleDomain = (ctxDomain != null && ctxDomain != JobDomain.GENERAL)
                ? ctxDomain
                : AppUtil.detectUserDomain(userSkills);
        double minMatch = CareerContextService.ROLE_FEED_MIN_MATCH;

        Set<String> appliedKeys = dao.listAppliedJobKeys(userId);
        List<JobFeedItem> feed = new ArrayList<>();

        for (Job j : dao.listActiveJobs()) {
            addIfRelevant(feed, buildInternalItem(j, userSkills, roleDomain, appliedKeys, minMatch));
        }
        for (ExtJob e : dao.listApiJobs()) {
            addIfRelevant(feed, buildExternalItem(e, userSkills, roleDomain, appliedKeys, "API", minMatch));
        }
        for (ExtJob e : dao.listScrapedJobs()) {
            addIfRelevant(feed, buildExternalItem(e, userSkills, roleDomain, appliedKeys, "SCRAPED", minMatch));
        }

        feed.sort((a, b) -> {
            int rankA = "NEW".equals(a.getFreshnessBadge()) ? 0 : "THIS_WEEK".equals(a.getFreshnessBadge()) ? 1 : "THIS_MONTH".equals(a.getFreshnessBadge()) ? 2 : 3;
            int rankB = "NEW".equals(b.getFreshnessBadge()) ? 0 : "THIS_WEEK".equals(b.getFreshnessBadge()) ? 1 : "THIS_MONTH".equals(b.getFreshnessBadge()) ? 2 : 3;
            if (rankA != rankB) {
                return Integer.compare(rankA, rankB);
            }
            return Double.compare(b.getMatchPct(), a.getMatchPct());
        });

        return feed;
    }

    private static void addIfRelevant(List<JobFeedItem> feed, JobFeedItem item) {
        if (item != null) feed.add(item);
    }

    private JobFeedItem buildInternalItem(Job j, List<String> userSkills, JobDomain roleDomain,
                                          Set<String> appliedKeys, double minMatch) {
        List<String> req = j.getSkills().isEmpty()
                ? AppUtil.parseList(j.getRequirements()) : j.getSkills();
        if (!JobRelevanceEngine.passesFilterForRoleContext(userSkills, req, j.getTitle(), j.getDescription(),
                roleDomain, minMatch)) {
            return null;
        }
        JobFeedItem item = new JobFeedItem();
        item.setFeedType("INTERNAL");
        item.setRefId(j.getJobId());
        item.setTitle(j.getTitle());
        item.setCompany(j.getCompany());
        item.setLocation(j.getLocation());
        item.setSkills(String.join(", ", req));
        item.setSource("CareerAssist");
        item.setDescription(j.getDescription());
        item.setUrl(null);
        item.setApplyUrl(null);
        item.setPostedLabel(TimeAgoUtil.formatPosted(j.getPostedAt()));
        item.setAlreadyApplied(appliedKeys.contains("INTERNAL:" + j.getJobId()));
        return JobRelevanceEngine.enrichFeedItem(item, userSkills);
    }

    private JobFeedItem buildExternalItem(ExtJob e, List<String> userSkills, JobDomain roleDomain,
                                          Set<String> appliedKeys, String feedType, double minMatch) {
        List<String> req = JobRelevanceEngine.jobSkillsOrExtract(e.getSkills(), e.getTitle(), e.getDescription());
        if (!JobRelevanceEngine.passesFilterForRoleContext(userSkills, req, e.getTitle(), e.getDescription(),
                roleDomain, minMatch)) {
            return null;
        }
        if (e.getUrl() == null || e.getUrl().isBlank()) return null;

        JobFeedItem item = new JobFeedItem();
        item.setFeedType(feedType);
        item.setRefId(e.getId());
        item.setTitle(e.getTitle());
        item.setCompany(e.getCompany());
        item.setLocation(e.getLocation());
        item.setSkills(String.join(", ", req));
        item.setUrl(e.getUrl());
        item.setApplyUrl(e.getUrl());
        item.setSource(e.getSource());
        item.setDescription(e.getDescription());
        item.setPostedLabel(e.getPostedLabel() != null ? e.getPostedLabel() : "Posted recently");
        item.setAlreadyApplied(appliedKeys.contains(feedType + ":" + e.getId()));
        return JobRelevanceEngine.enrichFeedItem(item, userSkills);
    }
}
