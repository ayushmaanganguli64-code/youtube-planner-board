<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Creator Suite Workspace</title>
    <style>
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background-color: #0f1115;
            color: #e2e8f0;
            margin: 0;
            padding: 40px;
        }
        .header-section {
            border-bottom: 1px solid #1e293b;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        h1 { margin: 0; color: #f43f5e; font-size: 2.2rem; }
        
        .form-panel {
            background: #1e222b;
            border: 1px solid #2d3139;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 40px;
            max-width: 600px;
        }
        .form-panel h3 { margin-top: 0; margin-bottom: 15px; color: #f8fafc; }
        .form-group { display: flex; flex-direction: column; margin-bottom: 15px; }
        .form-group label { margin-bottom: 6px; font-size: 0.85rem; color: #94a3b8; }
        .form-group input, .form-group textarea, .form-group select {
            background: #111318;
            border: 1px solid #2d3139;
            border-radius: 6px;
            padding: 10px;
            color: #fff;
            font-family: inherit;
        }
        .form-group textarea { resize: vertical; height: 70px; }
        .submit-btn {
            background: #f43f5e;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
        }
        .submit-btn:hover { background: #e11d48; }

        #video-container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
        }
        .video-card {
            background: #161a22;
            border: 1px solid #252a34;
            border-radius: 10px;
            padding: 20px;
            position: relative;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.3);
        }
        .video-card h3 { margin-top: 0; margin-bottom: 10px; padding-right: 40px; font-size: 1.25rem; color: #fff; }
        .video-card p { color: #94a3b8; font-size: 0.95rem; line-height: 1.5; margin-bottom: 20px; }
        
        .card-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .stage-selector {
            background: #111318;
            border: 1px solid #2d3139;
            color: #fff;
            padding: 5px 10px;
            border-radius: 6px;
            font-size: 0.85rem;
        }
        .delete-btn {
            background: #2d1f24;
            border: 1px solid #4c1d24;
            color: #f43f5e;
            padding: 4px 8px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
            position: absolute;
            top: 20px;
            right: 20px;
            font-weight: bold;
        }
        .delete-btn:hover { background: #e11d48; color: white; }
    </style>
</head>
<body>

    <div class="header-section">
        <h1>Creator Suite Command Center</h1>
        <p style="color: #64748b; margin: 5px 0 0 0;">Complete dynamic control over your production pipeline engine.</p>
    </div>

    <div class="form-panel">
        <h3>Queue New Idea</h3>
        <form id="idea-form" onsubmit="addVideo(event)">
            <div class="form-group">
                <label>Video Title</label>
                <input type="text" id="form-title" required placeholder="e.g., Fixing Legacy Java Architectures">
            </div>
            <div class="form-group">
                <label>Description Brief</label>
                <textarea id="form-desc" required placeholder="Core themes, outline notes, hooks, structure..."></textarea>
            </div>
            <div class="form-group">
                <label>Initial Lifecycle Stage</label>
                <select id="form-status">
    <option value="Idea">Idea</option>
    <option value="Scripting">Scripting</option>
    <option value="Editing">Editing</option>
    <option value="Published">Published</option>
</select>
            </div>
            <button type="submit" class="submit-btn">Deploy to Board</button>
        </form>
    </div>

    <h2>Production Kanban Board</h2>
    <div id="video-container">Querying lifecycle modules...</div>

    <script>
        // Change this from 'api/videos' to an absolute path relative to your context root
var API_URL = '/dashboard-backend/api/videos';

        async function fetchVideos() {
            try {
                var response = await fetch(API_URL);
                var videos = await response.json();
                
                var container = document.getElementById('video-container');
                container.innerHTML = '';
                
                if (videos.length === 0) {
                    container.innerHTML = '<p style="color:#64748b;">Pipeline empty. Deploy an idea module to begin tracking.</p>';
                    return;
                }

                for (var i = 0; i < videos.length; i++) {
                    var video = videos[i];
                    
// Make sure the matching checks and the option values are EXACTLY what MySQL expects:
var isIdea = (video.status === 'Idea') ? 'selected' : '';
var isScripting = (video.status === 'Scripting') ? 'selected' : '';
var isEditing = (video.status === 'Editing') ? 'selected' : '';
var isPublished = (video.status === 'Published') ? 'selected' : '';

var cardHtml = '<div class="video-card">' +
    '<button class="delete-btn" onclick="deleteVideo(' + video.id + ')">DELETE</button>' +
    '<h3>' + video.title + '</h3>' +
    '<p>' + video.description + '</p>' +
    '<div class="card-actions">' +
        '<select class="stage-selector" onchange="updateStage(' + video.id + ', this.value)">' +
            '<option value="Idea" ' + isIdea + '>Idea</option>' +
            '<option value="Scripting" ' + isScripting + '>Scripting</option>' +
            '<option value="Editing" ' + isEditing + '>Editing</option>' +
            '<option value="Published" ' + isPublished + '>Published</option>' +
        '</select>' +
    '</div>' +
'</div>';                   
                    
                    container.innerHTML += cardHtml;
                }
            } catch (error) {
                document.getElementById('video-container').innerHTML = '<p style="color:#ef4444;">Connection breakdown.</p>';
            }
        }

        async function addVideo(event) {
            event.preventDefault();
            var title = document.getElementById('form-title').value;
            var description = document.getElementById('form-desc').value;
            var status = document.getElementById('form-status').value;

            var formData = new URLSearchParams();
            formData.append('title', title);
            formData.append('description', description);
            formData.append('status', status);

            await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: formData
            });

            document.getElementById('idea-form').reset();
            fetchVideos();
        }

        async function updateStage(id, newStatus) {
            var targetUrl = API_URL + '?id=' + id + '&status=' + encodeURIComponent(newStatus);
            await fetch(targetUrl, {
                method: 'PUT'
            });
            fetchVideos();
        }

        async function deleteVideo(id) {
            if (confirm("Permanently drop this project file from database logs?")) {
                var targetUrl = API_URL + '?id=' + id;
                await fetch(targetUrl, {
                    method: 'DELETE'
                });
                fetchVideos();
            }
        }

        window.addEventListener('DOMContentLoaded', fetchVideos);
    </script>
</body>
</html>