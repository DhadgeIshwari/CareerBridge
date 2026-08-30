package com.careerassist.test;

import com.careerassist.model.JobDomain;
import com.careerassist.util.AppUtil;
import java.util.List;

public class DynamicPipelineTest {
    public static void main(String[] args) {
        System.out.println("=== Starting Dynamic Resume Analysis Pipeline Test ===");

        // Test 1: Sales Resume
        testResume(
            "Sales Resume",
            "I have 5 years of experience in Sales, Corporate Lead Generation, and handling enterprise CRM solutions such as Salesforce. I specialize in contract negotiation and B2B client relationship management.",
            List.of("Sales", "Lead Generation", "CRM", "Negotiation", "Customer Relationship Management"),
            JobDomain.SALES
        );

        // Test 2: Marketing Resume
        testResume(
            "Marketing Resume",
            "Expert in Digital Marketing and brand promotions. Handled search engine optimization (SEO), content creation, copywriting, and social media campaigns across multiple platforms.",
            List.of("Marketing", "SEO", "Social Media", "Content Creation"),
            JobDomain.MARKETING
        );

        // Test 3: Faculty Resume
        testResume(
            "Faculty Resume",
            "University Professor with 10+ years of teaching experience. Conducted academic research on Machine Learning algorithms, deep learning, and advanced statistical data analysis.",
            List.of("Teaching", "Research", "Machine Learning", "Data Analysis"),
            JobDomain.FACULTY
        );

        // Test 4: Networking Resume
        testResume(
            "Networking Resume",
            "Network administrator certified in CCNA routing and switching. Highly skilled in TCP/IP configurations and Cisco LAN/WAN networks.",
            List.of("CCNA", "Networking", "Routing", "Switching"),
            JobDomain.NETWORKING
        );

        System.out.println("\n=== Dynamic Resume Analysis Pipeline Test Complete ===");
    }

    private static void testResume(String testName, String resumeText, List<String> expectedSkills, JobDomain expectedDomain) {
        System.out.println("\n--- Testing: " + testName + " ---");
        List<String> extractedSkills = AppUtil.extractSkills(resumeText);
        JobDomain detectedDomain = AppUtil.detectUserDomain(extractedSkills);

        System.out.println("Extracted Skills: " + extractedSkills);
        System.out.println("Detected Domain:  " + detectedDomain);

        // Simple validation check
        boolean skillsOk = extractedSkills.containsAll(expectedSkills);
        boolean domainOk = detectedDomain == expectedDomain;

        if (skillsOk && domainOk) {
            System.out.println("RESULT: SUCCESS");
        } else {
            System.out.println("RESULT: FAILED");
            if (!skillsOk) {
                System.out.println("  Missing expected skills: " + expectedSkills);
            }
            if (!domainOk) {
                System.out.println("  Expected domain: " + expectedDomain + " but got: " + detectedDomain);
            }
        }
    }
}
