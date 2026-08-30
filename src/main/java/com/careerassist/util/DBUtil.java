package com.careerassist.util;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;
import java.sql.DatabaseMetaData;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContext;

public final class DBUtil {
    private static String url, user, password;

    private DBUtil() {}

    public static void init(ServletContext ctx) {
        url = ctx.getInitParameter("db.url");
        user = ctx.getInitParameter("db.user");
        password = ctx.getInitParameter("db.password");
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }
        catch (ClassNotFoundException e) { throw new RuntimeException("Add mysql-connector-j.jar to WEB-INF/lib", e); }

        // Proactive self-migration: Ensure resumes has 'is_latest' and 'file_type'
        try (Connection c = getConnection(); Statement s = c.createStatement()) {
            DatabaseMetaData meta = c.getMetaData();
            boolean hasIsLatest = false;
            boolean hasFileType = false;
            try (ResultSet rs = meta.getColumns(null, null, "resumes", null)) {
                while (rs.next()) {
                    String columnName = rs.getString("COLUMN_NAME");
                    if ("is_latest".equalsIgnoreCase(columnName)) {
                        hasIsLatest = true;
                    }
                    if ("file_type".equalsIgnoreCase(columnName)) {
                        hasFileType = true;
                    }
                }
            }
            if (!hasIsLatest) {
                try {
                    s.executeUpdate("ALTER TABLE resumes ADD COLUMN is_latest TINYINT(1) DEFAULT 0");
                    // Seed initial is_latest flag for existing records
                    s.executeUpdate("UPDATE resumes r SET is_latest = 1 WHERE r.resume_id = (SELECT max_id FROM (SELECT MAX(r2.resume_id) as max_id FROM resumes r2 GROUP BY r2.user_id) tmp WHERE max_id = r.resume_id)");
                } catch (Exception ex) {
                    System.err.println("Could not add is_latest: " + ex.getMessage());
                }
            }
            if (!hasFileType) {
                try {
                    s.executeUpdate("ALTER TABLE resumes ADD COLUMN file_type VARCHAR(100)");
                } catch (Exception ex) {
                    System.err.println("Could not add file_type: " + ex.getMessage());
                }
            }

            // Jobs table migrations
            boolean hasJobType = false;
            try (ResultSet rs = meta.getColumns(null, null, "jobs", null)) {
                while (rs.next()) {
                    String columnName = rs.getString("COLUMN_NAME");
                    if ("job_type".equalsIgnoreCase(columnName)) hasJobType = true;
                }
            }
            if (!hasJobType) {
                try {
                    s.executeUpdate("ALTER TABLE jobs ADD COLUMN job_type VARCHAR(100)");
                    s.executeUpdate("ALTER TABLE jobs ADD COLUMN experience_level VARCHAR(100)");
                    s.executeUpdate("ALTER TABLE jobs ADD COLUMN application_deadline VARCHAR(50)");
                    s.executeUpdate("ALTER TABLE jobs ADD COLUMN domain VARCHAR(50)");
                } catch (Exception ex) {
                    System.err.println("Could not add jobs columns: " + ex.getMessage());
                }
            }
        } catch (Exception e) {
            System.err.println("Database migration failed: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        Connection c = DriverManager.getConnection(url, user, password);
        if (c == null) throw new SQLException("No connection");
        return c;
    }
}
