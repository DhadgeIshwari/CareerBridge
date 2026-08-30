package com.careerassist.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Per-skill bundle for the Learning Path + Skill Practice Hub UI:
 * Learn, Read, and Practice sections.
 */
public class SkillLearningHub {
    private String skillName;
    private String practicePlatforms;
    private List<LearningItem> learnItems = new ArrayList<>();
    private List<LearningItem> readItems = new ArrayList<>();
    private List<PracticeLink> practiceLinks = new ArrayList<>();

    public String getSkillName() { return skillName; }
    public void setSkillName(String skillName) { this.skillName = skillName; }
    public String getPracticePlatforms() { return practicePlatforms; }
    public void setPracticePlatforms(String practicePlatforms) { this.practicePlatforms = practicePlatforms; }
    public List<LearningItem> getLearnItems() { return learnItems; }
    public void setLearnItems(List<LearningItem> learnItems) { this.learnItems = learnItems; }
    public List<LearningItem> getReadItems() { return readItems; }
    public void setReadItems(List<LearningItem> readItems) { this.readItems = readItems; }
    public List<PracticeLink> getPracticeLinks() { return practiceLinks; }
    public void setPracticeLinks(List<PracticeLink> practiceLinks) { this.practiceLinks = practiceLinks; }
}
