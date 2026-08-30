package com.careerassist.service.job;

import java.util.ArrayList;
import java.util.List;

import com.careerassist.model.ExtJob;

/**
 * Curated Indeed-style listings for demo/feed (no scraping of indeed.com — complies with site ToS).
 * For production, replace with an official Indeed Publisher or partner API when licensed.
 */
public class IndeedFeedProvider {

    public List<ExtJob> fetchDemoJobs() {
        List<ExtJob> jobs = new ArrayList<>();
        jobs.add(job("indeed-1", "Backend Java Developer", "Wipro", "Bangalore",
                "Java, Spring Boot, SQL", "https://example.com/jobs/indeed-demo-1"));
        jobs.add(job("indeed-2", "Network Engineer", "HCL", "Hyderabad",
                "CCNA, Networking, Linux", "https://example.com/jobs/indeed-demo-2"));
        jobs.add(job("indeed-3", "Data Analyst", "Accenture", "Mumbai",
                "SQL, Python, Excel", "https://example.com/jobs/indeed-demo-3"));
        jobs.add(job("indeed-4", "Full Stack Developer", "Tech Mahindra", "Pune",
                "JavaScript, React, Node.js", "https://example.com/jobs/indeed-demo-4"));
        jobs.add(job("indeed-5", "Cloud Support Engineer", "Infosys", "Chennai",
                "AWS, Linux, Networking", "https://example.com/jobs/indeed-demo-5"));
        return jobs;
    }

    private static ExtJob job(String extId, String title, String company, String location,
                              String skills, String url) {
        ExtJob j = new ExtJob();
        j.setExternalId(extId);
        j.setSource("INDEED");
        j.setTitle(title);
        j.setCompany(company);
        j.setLocation(location);
        j.setSkills(skills);
        j.setUrl(url);
        j.setDescription("Listing via Indeed-style demo feed. Configure official API for live data.");
        return j;
    }
}
