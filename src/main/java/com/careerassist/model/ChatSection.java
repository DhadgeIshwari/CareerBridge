package com.careerassist.model;

import java.util.ArrayList;
import java.util.List;

public class ChatSection {
    private String heading;
    private String body;
    private List<String> items = new ArrayList<>();

    public ChatSection() {}

    public ChatSection(String heading, String body) {
        this.heading = heading;
        this.body = body;
    }

    public ChatSection(String heading, List<String> items) {
        this.heading = heading;
        this.items = items != null ? items : new ArrayList<>();
    }

    public String getHeading() { return heading; }
    public void setHeading(String heading) { this.heading = heading; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public List<String> getItems() { return items; }
    public void setItems(List<String> items) { this.items = items; }
}
