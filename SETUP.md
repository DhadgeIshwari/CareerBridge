# CareerAssistClean - Setup Guide

## New clean project (use THIS, not CareerAssistSystem)

**Folder:** `CareerAssistClean`  
**Database:** `career_assist_db`  
**URL:** `http://localhost:8080/CareerAssistClean/`

---

## Step 1 - Eclipse

1. Workspace: `C:\Users\HP\Downloads\Project_Final`
2. **File → Import → Existing Projects** → select `CareerAssistClean`
3. **Java 21** + **Dynamic Web 6.0** facets
4. **Tomcat 10.1** only (not Tomcat 9)

## Step 2 - JARs (only 6 files in WEB-INF/lib)

- mysql-connector-j-8.3.0.jar
- gson-2.11.0.jar
- jsoup-1.18.1.jar
- pdfbox-3.0.3.jar
- pdfbox-io-3.0.3.jar
- fontbox-3.0.3.jar

Right-click project → **Refresh (F5)** after import.

## Step 3 - MySQL

1. Open `database/install.sql` in MySQL Workbench
2. **Ctrl+A** → **Execute** (run entire script)
3. Must show **14 tables** in `career_assist_db`

## Step 4 - web.xml password

Edit `src/main/webapp/WEB-INF/web.xml`:

```xml
<param-value>YOUR_MYSQL_PASSWORD</param-value>
```

## Step 5 - Run

Deploy on Tomcat → Start → open:

`http://localhost:8080/CareerAssistClean/`

### Demo login

| Role | Email | Password |
|------|-------|----------|
| Student | student@careerassist.com | student123 |
| HR | hr@careerassist.com | hr123456 |

---

## Why this project has fewer errors

- Only **6 JARs** (no Apache Tika dependency chain)
- **1 DAO** + **1 Service** (simpler structure)
- **3 Servlets** only (auth, student, hr)
- PDF-only resume (stable PDFBox)
- Same database name as before (`career_assist_db`)
