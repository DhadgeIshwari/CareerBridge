package com.careerassist.model;

public class ChatMsg {
    private String role, message;

    public ChatMsg() {}
    public ChatMsg(String role, String message) { this.role = role; this.message = message; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}
