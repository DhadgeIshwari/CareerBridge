REQUIRED JARs (download into this folder, then Refresh project in Eclipse):

1. mysql-connector-j-8.3.0.jar
   https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.3.0/mysql-connector-j-8.3.0.jar

2. gson-2.11.0.jar
   https://repo1.maven.org/maven2/com/google/code/gson/gson/2.11.0/gson-2.11.0.jar

3. jsoup-1.18.1.jar
   https://repo1.maven.org/maven2/org/jsoup/jsoup/1.18.1/jsoup-1.18.1.jar

OPTIONAL (for PDF resume upload only):
4. pdfbox-3.0.3.jar
5. pdfbox-io-3.0.3.jar
6. fontbox-3.0.3.jar

Or run from project root:  powershell -ExecutionPolicy Bypass -File download-jars.ps1

After adding JARs: Right-click CareerAssistClean -> Refresh (F5)
                  Project -> Clean -> Clean all projects

TXT resumes work WITHOUT PDFBox JARs.
