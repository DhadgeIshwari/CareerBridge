package com.careerassist.model;

import java.util.ArrayList;
import java.util.List;

/** Structured AI career advisor response returned to the chat UI and stored as plain text in chat_history. */
public class ChatResponse {
    private String type;
    private String title;
    private String summary;
    private List<String> highlights = new ArrayList<>();
    private List<ChatSection> sections = new ArrayList<>();
    private String reply;

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSummary() { return summary; }
    public void setSummary(String summary) { this.summary = summary; }
    public List<String> getHighlights() { return highlights; }
    public void setHighlights(List<String> highlights) { this.highlights = highlights; }
    public List<ChatSection> getSections() { return sections; }
    public void setSections(List<ChatSection> sections) { this.sections = sections; }
    public String getReply() { return reply; }
    public void setReply(String reply) { this.reply = reply; }
}
