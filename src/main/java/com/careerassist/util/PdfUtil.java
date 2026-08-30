package com.careerassist.util;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;

/**
 * Extracts text from resume files.
 * Supports .txt natively. For .pdf add pdfbox JARs to WEB-INF/lib (see SETUP.md).
 */
public final class PdfUtil {
    private PdfUtil() {}

    public static String extractText(File file) throws IOException {
        String name = file.getName().toLowerCase();
        if (name.endsWith(".txt")) {
            return Files.readString(file.toPath(), StandardCharsets.UTF_8).trim();
        }
        if (name.endsWith(".pdf")) {
            return extractPdfWithPdfBox(file);
        }
        throw new IOException("Unsupported file type. Upload .txt or .pdf resume.");
    }

    private static String extractPdfWithPdfBox(File file) throws IOException {
        try {
            Class<?> loaderClass = Class.forName("org.apache.pdfbox.Loader");
            Class<?> docClass = Class.forName("org.apache.pdfbox.pdmodel.PDDocument");
            Class<?> stripperClass = Class.forName("org.apache.pdfbox.text.PDFTextStripper");

            Object doc = loaderClass.getMethod("loadPDF", File.class).invoke(null, file);
            try {
                Object stripper = stripperClass.getDeclaredConstructor().newInstance();
                String text = (String) stripperClass.getMethod("getText", docClass).invoke(stripper, doc);
                return text != null ? text.trim() : "";
            } finally {
                docClass.getMethod("close").invoke(doc);
            }
        } catch (ClassNotFoundException e) {
            throw new IOException(
                "PDF support requires JARs in WEB-INF/lib: pdfbox-3.0.3.jar, pdfbox-io-3.0.3.jar, fontbox-3.0.3.jar. " +
                "Run download-jars.ps1 or upload a .txt resume instead.", e);
        } catch (ReflectiveOperationException e) {
            throw new IOException("Failed to read PDF: " + e.getMessage(), e);
        }
    }
}
