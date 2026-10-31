package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import service.ProfileService;

@WebServlet(name = "MediaServlet", urlPatterns = {"/uploads/*"})
public class MediaServlet extends HttpServlet {

    private File avatarStorageDir;

    @Override
    public void init() throws ServletException {
        this.avatarStorageDir = ProfileService.resolveDefaultAvatarDir();
        if (!this.avatarStorageDir.exists()) {
            this.avatarStorageDir.mkdirs();
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.trim().isEmpty() || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Expected format: /avatar/{fileName}
        String normalized = pathInfo.replace('\\', '/');
        if (normalized.contains("..")) {
            // Path traversal attempt protection
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File targetFile;
        if (normalized.startsWith("/avatar/")) {
            String fileName = normalized.substring("/avatar/".length());
            targetFile = new File(avatarStorageDir, fileName);
        } else {
            // Fallback for direct file in uploads dir
            String fileName = normalized.startsWith("/") ? normalized.substring(1) : normalized;
            targetFile = new File(avatarStorageDir, fileName);
        }

        if (!targetFile.exists() || !targetFile.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String name = targetFile.getName().toLowerCase();
        String contentType = "application/octet-stream";
        if (name.endsWith(".png")) {
            contentType = "image/png";
        } else if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
            contentType = "image/jpeg";
        } else if (name.endsWith(".webp")) {
            contentType = "image/webp";
        }

        resp.setContentType(contentType);
        resp.setContentLengthLong(targetFile.length());
        resp.setHeader("Cache-Control", "public, max-age=86400"); // Cache 1 day

        try (FileInputStream in = new FileInputStream(targetFile);
             OutputStream out = resp.getOutputStream()) {
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
}
