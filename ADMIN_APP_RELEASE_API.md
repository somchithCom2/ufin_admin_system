# Admin App Release & Maintenance API Documentation

This document describes the admin endpoints for managing app releases and maintenance mode.

---

## 🔐 Authentication & Authorization

All admin endpoints require:
- **Authentication**: Valid JWT token (Bearer token)
- **Authorization**: User must have `ADMIN` role

All requests must include:
```
Authorization: Bearer <JWT_TOKEN>
```

---

## 📦 Base URL
```
/api/v1/admin/app
```

---

## 📋 Release Management Endpoints

### 1. Create New Release
**Endpoint**: `POST /releases`

**Request Body**:
```json
{
  "version_name": "1.2.0",
  "version_code": 120,
  "platform": "android",
  "title": "Critical Security Update",
  "changelog": "- Fixed authentication vulnerability\n- Improved performance",
  "is_mandatory": true,
  "download_url": "https://play.google.com/store/apps/details?id=com.ufin.pos",
  "released_at": "2026-08-10T10:00:00"
}
```

**Response**: `201 Created`
```json
{
  "id": 1,
  "version_name": "1.2.0",
  "version_code": 120,
  "platform": "android",
  "title": "Critical Security Update",
  "changelog": "- Fixed authentication vulnerability\n- Improved performance",
  "is_mandatory": true,
  "is_published": false,
  "download_url": "https://play.google.com/store/apps/details?id=com.ufin.pos",
  "released_at": "2026-08-10T10:00:00",
  "created_at": "2026-08-10T10:05:00",
  "updated_at": "2026-08-10T10:05:00"
}
```

**Notes**:
- `is_published` defaults to `false`
- If `released_at` is not provided, current time is used
- `is_mandatory` defaults to `false`

---

### 2. Get All Releases
**Endpoint**: `GET /releases`

**Response**: `200 OK`
```json
[
  {
    "id": 1,
    "version_name": "1.2.0",
    "version_code": 120,
    "platform": "android",
    "title": "Critical Security Update",
    "changelog": "- Fixed authentication vulnerability",
    "is_mandatory": true,
    "is_published": true,
    "download_url": "https://play.google.com/store/apps/details?id=com.ufin.pos",
    "released_at": "2026-08-10T10:00:00",
    "created_at": "2026-08-10T10:05:00",
    "updated_at": "2026-08-10T10:05:00"
  }
]
```

---

### 3. Get Release By ID
**Endpoint**: `GET /releases/{id}`

**Path Parameters**:
- `id` (Long): Release ID

**Response**: `200 OK`
```json
{
  "id": 1,
  "version_name": "1.2.0",
  "version_code": 120,
  "platform": "android",
  "title": "Critical Security Update",
  "changelog": "- Fixed authentication vulnerability",
  "is_mandatory": true,
  "is_published": true,
  "download_url": "https://play.google.com/store/apps/details?id=com.ufin.pos",
  "released_at": "2026-08-10T10:00:00",
  "created_at": "2026-08-10T10:05:00",
  "updated_at": "2026-08-10T10:05:00"
}
```

---

### 4. Get Releases By Platform
**Endpoint**: `GET /releases/platform/{platform}`

**Path Parameters**:
- `platform` (String): Platform identifier (`android`, `ios`, `web`)

**Response**: `200 OK` - Returns list of releases for that platform

---

### 5. Get Published Releases
**Endpoint**: `GET /releases/published`

**Response**: `200 OK` - Returns only published releases

---

### 6. Update Release
**Endpoint**: `PUT /releases/{id}`

**Path Parameters**:
- `id` (Long): Release ID

**Request Body** (all fields optional):
```json
{
  "title": "Updated Title",
  "changelog": "Updated changelog",
  "is_mandatory": false,
  "download_url": "https://new-url.com"
}
```

**Response**: `200 OK` - Returns updated release

**Notes**:
- Only provided fields are updated
- `version_name`, `version_code`, and `platform` cannot be changed

---

### 7. Publish Release
**Endpoint**: `PATCH /releases/{id}/publish`

**Path Parameters**:
- `id` (Long): Release ID

**Request Body**: None

**Response**: `200 OK`
```json
{
  "id": 1,
  "version_name": "1.2.0",
  "is_published": true,
  ...
}
```

**Notes**:
- Marks the release as published
- Published releases are served to clients

---

### 8. Unpublish Release
**Endpoint**: `PATCH /releases/{id}/unpublish`

**Path Parameters**:
- `id` (Long): Release ID

**Request Body**: None

**Response**: `200 OK`
```json
{
  "id": 1,
  "version_name": "1.2.0",
  "is_published": false,
  ...
}
```

**Notes**:
- Marks the release as unpublished
- Clients will no longer see this release as available

---

### 9. Delete Release
**Endpoint**: `DELETE /releases/{id}`

**Path Parameters**:
- `id` (Long): Release ID

**Response**: `204 No Content`

**Notes**:
- Completely removes the release from the database
- Cannot be undone

---

## 🔧 Maintenance Mode Endpoints

### 10. Get System Configuration
**Endpoint**: `GET /system-config`

**Response**: `200 OK`
```json
{
  "id": 1,
  "is_maintenance_mode": false,
  "maintenance_title": null,
  "maintenance_message": null,
  "expected_completion_time": null,
  "min_supported_android_version": "5.0",
  "min_supported_ios_version": "12.0",
  "min_supported_web_version": "1.0.0",
  "created_at": "2026-08-01T10:00:00",
  "updated_at": "2026-08-10T10:05:00",
  "updated_by": "admin@ufin.com"
}
```

---

### 11. Update Maintenance Mode
**Endpoint**: `PUT /maintenance-mode`

**Request Body**:
```json
{
  "is_maintenance_mode": true,
  "maintenance_title": "System Maintenance",
  "maintenance_message": "We're updating our system. Expected completion: 3 PM today.",
  "expected_completion_time": "2026-08-10T15:30:00"
}
```

**Response**: `200 OK` - Returns updated system config

**Notes**:
- Only `is_maintenance_mode` is required
- When `is_maintenance_mode` is `true`, all clients receive a maintenance screen
- GET requests are still allowed during maintenance
- All mutations (POST, PUT, DELETE, PATCH) are blocked

---

### 12. Update System Configuration
**Endpoint**: `PUT /system-config`

**Request Body** (all fields optional):
```json
{
  "min_supported_android_version": "6.0",
  "min_supported_ios_version": "13.0",
  "min_supported_web_version": "2.0.0"
}
```

**Response**: `200 OK` - Returns updated system config

**Notes**:
- Sets minimum supported versions for each platform
- Clients with versions below these minimums may be rejected

---

## 📊 Complete Workflow Example

### Scenario: Release a new Android update

**Step 1**: Create the release (draft mode)
```bash
curl -X POST http://localhost:8080/api/v1/admin/app/releases \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "version_name": "1.3.0",
    "version_code": 130,
    "platform": "android",
    "title": "New Features",
    "changelog": "- Added dark mode\n- Improved UI",
    "is_mandatory": false,
    "download_url": "https://play.google.com/store/apps/details?id=com.ufin.pos"
  }'
```

**Step 2**: Verify the release
```bash
curl -X GET http://localhost:8080/api/v1/admin/app/releases/1 \
  -H "Authorization: Bearer <token>"
```

**Step 3**: Publish the release
```bash
curl -X PATCH http://localhost:8080/api/v1/admin/app/releases/1/publish \
  -H "Authorization: Bearer <token>"
```

**Step 4**: Clients automatically receive update notification via `/api/v1/app/check-status`

---

## 🛡️ Maintenance Mode Workflow

### Scenario: Schedule maintenance

**Step 1**: Enable maintenance mode
```bash
curl -X PUT http://localhost:8080/api/v1/admin/app/maintenance-mode \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "is_maintenance_mode": true,
    "maintenance_title": "System Maintenance",
    "maintenance_message": "We are performing database upgrades. Estimated completion: 30 minutes.",
    "expected_completion_time": "2026-08-10T14:30:00"
  }'
```

**Step 2**: Deploy your application changes

**Step 3**: Disable maintenance mode
```bash
curl -X PUT http://localhost:8080/api/v1/admin/app/maintenance-mode \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "is_maintenance_mode": false
  }'
```

---

## 🚨 Error Responses

### 400 Bad Request
```json
{
  "error": "Validation failed",
  "details": "Version code must be positive"
}
```

### 401 Unauthorized
```json
{
  "error": "Missing or invalid authentication token"
}
```

### 403 Forbidden
```json
{
  "error": "Access denied - admin role required"
}
```

### 404 Not Found
```json
{
  "error": "Release not found: 999"
}
```

---

## 📋 Request/Response Headers

**Required Headers**:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Response Headers**:
```
Content-Type: application/json
X-Request-ID: <unique-request-id>
```

---

## ✅ Best Practices

1. **Always draft before publishing**
   - Create release with default `is_published=false`
   - Test the release details
   - Publish when ready

2. **Use meaningful titles and changelogs**
   - Users will see these in their app update dialogs
   - Include security fixes, new features, bug fixes

3. **Test maintenance mode**
   - Enable it in staging first
   - Verify all clients show maintenance screen
   - Test re-enabling after deployment

4. **Keep track of versions**
   - Use semantic versioning (MAJOR.MINOR.PATCH)
   - Increment version codes consistently
   - Android: 100, 101, 102... (simple increment)
   - iOS: Match your marketing version

5. **Monitor deployments**
   - Watch the health check during deployment
   - Keep maintenance window short
   - Have a rollback plan ready

6. **Audit trail**
   - `updated_by` field tracks who made changes
   - `updated_at` tracks when changes were made
   - All release history is preserved

---

## 🔍 Troubleshooting

### Issue: "Access denied - admin role required"
- Ensure user has `ADMIN` role assigned
- Check JWT token includes the admin role
- Verify token is not expired

### Issue: "Release not found"
- Verify the release ID exists
- Check if release was deleted
- Use `/releases` endpoint to list all releases

### Issue: Maintenance mode won't disable
- Check database connection
- Verify user has write permissions
- Check logs for SQL errors

### Issue: Clients still see old release
- Publish the new release
- Unpublish old releases if needed
- Check client's version checking logic

---

## 📞 Support

For issues or questions, check the logs:
```bash
docker logs ufin-api
```

Or query the database directly:
```bash
psql -h localhost -U ufin_user -d ufin_db -c "SELECT * FROM app_releases ORDER BY released_at DESC;"
```
