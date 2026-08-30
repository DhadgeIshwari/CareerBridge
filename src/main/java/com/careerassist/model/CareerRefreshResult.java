package com.careerassist.model;

import java.util.ArrayList;
import java.util.List;

/** Payload after changing selected job role — refreshes all career modules. */
public class CareerRefreshResult {
    private CareerContext context;
    private SkillGap gap;
    private List<JobFeedItem> feed = new ArrayList<>();
    private int learningItemCount;
    private String message;

    public CareerContext getContext() { return context; }
    public void setContext(CareerContext context) { this.context = context; }
    public SkillGap getGap() { return gap; }
    public void setGap(SkillGap gap) { this.gap = gap; }
    public List<JobFeedItem> getFeed() { return feed; }
    public void setFeed(List<JobFeedItem> feed) { this.feed = feed; }
    public int getLearningItemCount() { return learningItemCount; }
    public void setLearningItemCount(int learningItemCount) { this.learningItemCount = learningItemCount; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
