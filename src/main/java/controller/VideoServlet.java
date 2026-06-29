package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import model.Video;

public class VideoServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/youtube_planner";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Ag#22222007";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    PrintWriter out = response.getWriter();
    List<Video> videos = new ArrayList<>();

    // Fixed the column selections to match your SQL schema exactly
    try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
         Statement stmt = conn.createStatement();
         ResultSet rs = stmt.executeQuery("SELECT video_id, title, description, status FROM video_projects")) {

        while (rs.next()) {
            Video video = new Video();
            video.setId(rs.getInt("video_id")); // FIX: Changed from "id" to "video_id"
            video.setTitle(rs.getString("title"));
            video.setDescription(rs.getString("description"));
            video.setStatus(rs.getString("status"));
            videos.add(video);
        }

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < videos.size(); i++) {
            Video v = videos.get(i);
            
            String safeTitle = v.getTitle().replace("\"", "\\\"").replace("\n", "\\n");
            String safeDesc = v.getDescription().replace("\"", "\\\"").replace("\n", "\\n");
            String safeStatus = v.getStatus().replace("\"", "\\\"").replace("\n", "\\n");

            json.append(String.format("{\"id\":%d, \"title\":\"%s\", \"description\":\"%s\", \"status\":\"%s\"}",
                    v.getId(), safeTitle, safeDesc, safeStatus));
            if (i < videos.size() - 1) json.append(",");
        }
        json.append("]");
        out.print(json.toString());

    } catch (Exception e) {
        e.printStackTrace(); // This will now print the exact error to your terminal if anything drops
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.print("{\"error\":\"Database connection failed\"}");
    }
}

@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    String action = request.getParameter("action");
    if (action == null) {
        action = "create";
    }

    try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
        
        if (action.equalsIgnoreCase("create")) {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String status = request.getParameter("status");
            
            // Normalize "Idea" coming from frontend to match your DB state "Idea Pool" if necessary
            if ("Idea".equals(status)) status = "Idea"; 

            try (PreparedStatement ps = conn.prepareStatement("INSERT INTO video_projects (title, description, status) VALUES (?, ?, ?)")) {
                ps.setString(1, title);
                ps.setString(2, description);
                ps.setString(3, status);
                ps.executeUpdate();
                response.setStatus(HttpServletResponse.SC_CREATED);
            }
            
        } else if (action.equalsIgnoreCase("update")) {
            String idParam = request.getParameter("id");
            String statusParam = request.getParameter("status");

            // FIX: Target "video_id" instead of "id"
            try (PreparedStatement ps = conn.prepareStatement("UPDATE video_projects SET status=? WHERE video_id=?")) {
                ps.setString(1, statusParam);
                ps.setInt(2, Integer.parseInt(idParam));
                ps.executeUpdate();
                response.setStatus(HttpServletResponse.SC_OK);
            }
            
        } else if (action.equalsIgnoreCase("delete")) {
            String idParam = request.getParameter("id");

            // FIX: Target "video_id" instead of "id"
            try (PreparedStatement ps = conn.prepareStatement("DELETE FROM video_projects WHERE video_id=?")) {
                ps.setInt(1, Integer.parseInt(idParam));
                ps.executeUpdate();
                response.setStatus(HttpServletResponse.SC_OK);
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }
}
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = getQueryParam(request, "id");
        String statusParam = getQueryParam(request, "status");

        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = conn.prepareStatement("UPDATE video_projects SET status=? WHERE video_id=?")) {
            
            ps.setString(1, statusParam);
            ps.setInt(2, Integer.parseInt(idParam));
            ps.executeUpdate();
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = getQueryParam(request, "id");

        if (idParam == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM video_projects WHERE video_id=?")) {
            
            ps.setInt(1, Integer.parseInt(idParam));
            ps.executeUpdate();
            response.setStatus(HttpServletResponse.SC_OK);
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // Helper method to reliably extract query strings from paths
    private String getQueryParam(HttpServletRequest request, String targetKey) throws IOException {
        String queryString = request.getQueryString();
        if (queryString != null) {
            String[] pairs = queryString.split("&");
            for (String pair : pairs) {
                String[] idx = pair.split("=");
                if (idx.length == 2) {
                    String key = URLDecoder.decode(idx[0], "UTF-8");
                    String val = URLDecoder.decode(idx[1], "UTF-8");
                    if (key.equals(targetKey)) return val;
                }
            }
        }
        return request.getParameter(targetKey);
    }
}