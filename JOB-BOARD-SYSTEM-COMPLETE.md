# Job Board System - Complete Implementation Guide

## 🎉 System Overview

A comprehensive job board system with:
- ✅ Company-submitted job listings with approval workflow
- ✅ Applicant profiles with resume management
- ✅ Internal application tracking system
- ✅ External application support (URL/email)
- ✅ Company portal to view applicants
- ✅ Auto-newsletter subscription
- ✅ Full admin management via Filament

---

## 📊 Database Structure

### Tables Created

#### 1. **companies**
Stores company information for job listings.

**Fields:**
- `id` - Primary key
- `name` - Company name
- `slug` - URL-friendly slug (auto-generated)
- `description` - Company description
- `website`, `email`, `phone` - Contact info
- `address`, `city`, `state`, `zip` - Location
- `logo_url` - Company logo
- `is_active` - Active status
- `timestamps`

**Relationships:**
- `hasMany(JobListing)`

---

#### 2. **job_listings** (Enhanced)
Job postings with approval workflow.

**New Fields Added:**
- `status` - Enum: draft, pending, approved, rejected, expired
- `company_id` - Foreign key to companies (nullable)
- `submitted_by_user_id` - User who submitted (nullable)
- `submitted_at` - Submission timestamp
- `approved_at` - Approval timestamp
- `approved_by_user_id` - Admin who approved
- `rejection_reason` - Text reason if rejected
- `application_method` - Enum: internal, external
- `company_can_view_applicants` - Boolean

**Relationships:**
- `belongsTo(Company)`
- `belongsTo(User, 'submitted_by_user_id')`
- `belongsTo(User, 'approved_by_user_id')`
- `hasMany(JobApplication)`

---

#### 3. **applicants**
Job seeker profiles.

**Fields:**
- `id` - Primary key
- `user_id` - Foreign key to users (nullable)
- Personal: `first_name`, `last_name`, `email`, `phone`, `address`, `city`, `state`, `zip`
- Professional: `current_title`, `bio`, `skills` (JSON), `linkedin_url`, `portfolio_url`
- Resume: `resume_path`, `resume_filename`, `resume_uploaded_at`
- Preferences: `preferred_job_types` (JSON), `preferred_categories` (JSON), `desired_salary_range`, `willing_to_relocate`
- Status: `is_active`, `is_searchable`, `last_active_at`
- `subscribed_to_newsletter` - Boolean
- `timestamps`

**Relationships:**
- `belongsTo(User)`
- `hasMany(JobApplication)`

---

#### 4. **job_applications**
Tracks applications from applicants to jobs.

**Fields:**
- `id` - Primary key
- `job_listing_id` - Foreign key to job_listings
- `applicant_id` - Foreign key to applicants
- `cover_letter` - Text
- `resume_path` - Optional override resume
- `answers` - JSON for additional questions
- `status` - Enum: submitted, reviewed, shortlisted, interviewing, offered, rejected, withdrawn
- `reviewed_at` - Timestamp
- `status_changed_at` - Auto-updated on status change
- `company_notes` - Private notes for company
- `viewed_by_company` - Boolean
- `viewed_at` - Timestamp
- `view_count` - Integer
- `timestamps`

**Unique Constraint:** One application per job per applicant

**Relationships:**
- `belongsTo(JobListing)`
- `belongsTo(Applicant)`

---

## 🎯 Backend Admin Features (Filament)

### Navigation Structure

```
Jobs ▼
  ├── Job Listings (sort: 1)
  ├── Companies (sort: 2)
  ├── Applicants (sort: 3)
  └── Applications (sort: 4)
```

### 1. Job Listings Resource

**Features:**
- Status workflow management (draft → pending → approved/rejected)
- Approve/Reject actions with reasons
- Mark as expired
- Toggle featured status
- View applications (relation manager)
- Filter by status, type, category, application method
- Badge colors for status visualization

**Approval Workflow:**
1. Company submits job → Status: "pending"
2. Admin reviews in Filament
3. Admin clicks "Approve" → Status: "approved", posted_at set
4. OR Admin clicks "Reject" → Status: "rejected", requires reason
5. Rejected jobs show rejection_reason to company

---

### 2. Companies Resource

**Features:**
- Full CRUD for company profiles
- Link job listings to companies
- View all job listings per company (relation manager)
- Track total job listings count
- Filter by active status and jobs posted
- Auto-generate slug from company name

---

### 3. Applicants Resource

**Features:**
- Full applicant profile management
- Resume download/view
- View all applications per applicant (relation manager)
- Filter by active, searchable, has resume, has applications
- Track application count
- Newsletter subscription status

---

### 4. Job Applications Resource

**Features:**
- View all applications across all jobs
- Status management with color-coded badges
- Mark as reviewed (bulk action available)
- Filter by status, viewed status, date range
- Company notes for internal tracking
- View count tracking

---

## 🔌 API Endpoints

### Public Endpoints (Frontend Integration)

#### Job Submission (Companies)

```http
POST /api/jobs/submit
Content-Type: application/json

{
  "company_name": "string (required)",
  "company_email": "email (required)",
  "company_phone": "string (optional)",
  "company_website": "url (optional)",
  "title": "string (required)",
  "location": "string (required)",
  "type": "full-time|part-time|contract|temporary|internship (required)",
  "category": "hospitality|retail|healthcare|professional|trades|other (optional)",
  "salary_range": "string (optional)",
  "description": "string (required)",
  "application_method": "internal|external (required)",
  "application_url": "url (required if external)",
  "application_email": "email (optional)",
  "company_can_view_applicants": "boolean (optional, default: true)",
  "subscribe_to_newsletter": "boolean (optional)"
}
```

**Rate Limit:** 3 submissions per day per IP

**Response:**
```json
{
  "success": true,
  "message": "Job listing submitted successfully! It will be reviewed and published soon.",
  "data": {
    "id": 1,
    "title": "Senior Developer",
    "status": "pending"
  }
}
```

---

#### Applicant Registration

```http
POST /api/applicants/register
Content-Type: multipart/form-data

{
  "first_name": "string (required)",
  "last_name": "string (required)",
  "email": "email (required, unique)",
  "phone": "string (optional)",
  "address": "string (optional)",
  "city": "string (optional)",
  "state": "string (optional)",
  "zip": "string (optional)",
  "current_title": "string (optional)",
  "bio": "string (optional)",
  "skills": ["array of strings (optional)"],
  "linkedin_url": "url (optional)",
  "portfolio_url": "url (optional)",
  "resume": "file (pdf,doc,docx, max 5MB, optional)",
  "preferred_job_types": ["array (optional)"],
  "preferred_categories": ["array (optional)"],
  "desired_salary_range": "string (optional)",
  "willing_to_relocate": "boolean (optional)",
  "subscribe_to_newsletter": "boolean (optional, default: true)"
}
```

**Rate Limit:** 5 registrations per hour per IP

**Response:**
```json
{
  "success": true,
  "message": "Profile created successfully! You can now apply for jobs.",
  "data": {
    "id": 1,
    "full_name": "John Doe",
    "email": "john@example.com"
  }
}
```

---

#### Apply for Job

```http
POST /api/jobs/{jobListingId}/apply
Content-Type: multipart/form-data

{
  "applicant_id": "integer (required)",
  "cover_letter": "string (optional)",
  "resume": "file (pdf,doc,docx, max 5MB, optional - overrides default)"
}
```

**Rate Limit:** 10 applications per hour per IP

**Validations:**
- Job must be approved and active
- Job must accept internal applications
- Applicant cannot apply twice to same job

**Response:**
```json
{
  "success": true,
  "message": "Application submitted successfully!",
  "data": {
    "id": 1,
    "job_title": "Senior Developer",
    "company": "Tech Corp",
    "status": "submitted"
  }
}
```

---

#### Get Applicant's Applications

```http
GET /api/applicants/{applicantId}/applications
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "job_title": "Senior Developer",
      "company": "Tech Corp",
      "location": "New York, NY",
      "status": "reviewed",
      "applied_at": "Jan 15, 2025",
      "viewed_by_company": true
    }
  ]
}
```

---

#### Helper Endpoints

```http
GET /api/jobs/categories
GET /api/jobs/types
```

Returns available options for dropdowns.

---

## 🎨 Frontend Implementation (TODO)

### 1. Job Submission Form (`/post-job`)

**Required Form Fields:**
- Company Information
  - Company Name *
  - Company Email *
  - Company Phone
  - Company Website
- Job Details
  - Job Title *
  - Location *
  - Job Type * (dropdown from `/api/jobs/types`)
  - Category (dropdown from `/api/jobs/categories`)
  - Salary Range
  - Description * (rich text editor)
- Application Method *
  - Internal (track applications)
  - External (apply via URL/email)
- If External:
  - Application URL *
  - Application Email
- Newsletter Opt-in (checkbox, default: true)

**Implementation:**
```typescript
// Example Next.js form submission
const handleSubmit = async (formData) => {
  const response = await fetch('https://admin.hudsonlifedispatch.com/api/jobs/submit', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
  });
  
  const data = await response.json();
  
  if (data.success) {
    // Show success message
    // Redirect to confirmation page
  }
};
```

---

### 2. Applicant Registration Form (`/job-seeker-register`)

**Required Form Fields:**
- Personal Information
  - First Name *, Last Name *
  - Email *, Phone
  - Address, City, State, ZIP
- Professional Information
  - Current Job Title
  - Professional Summary (bio)
  - Skills (tags input)
  - LinkedIn URL, Portfolio URL
- Resume Upload (PDF/DOC/DOCX, max 5MB)
- Job Preferences
  - Preferred Job Types (checkboxes)
  - Preferred Categories (checkboxes)
  - Desired Salary Range
  - Willing to Relocate (checkbox)
- Newsletter Opt-in (checkbox, default: true)

**Implementation:**
```typescript
const handleRegister = async (formData) => {
  const form = new FormData();
  // Append all fields including resume file
  Object.keys(formData).forEach(key => {
    form.append(key, formData[key]);
  });
  
  const response = await fetch('https://admin.hudsonlifedispatch.com/api/applicants/register', {
    method: 'POST',
    body: form
  });
  
  const data = await response.json();
  
  if (data.success) {
    // Store applicant_id in localStorage or session
    localStorage.setItem('applicantId', data.data.id);
    // Redirect to dashboard or job listings
  }
};
```

---

### 3. Job Application Form (on job detail page)

**Required:**
- Applicant ID (from registration or login)
- Cover Letter (textarea, optional)
- Resume (file upload, optional - overrides profile resume)

**Implementation:**
```typescript
const handleApply = async (jobId, formData) => {
  const form = new FormData();
  form.append('applicant_id', localStorage.getItem('applicantId'));
  form.append('cover_letter', formData.coverLetter);
  if (formData.resume) {
    form.append('resume', formData.resume);
  }
  
  const response = await fetch(`https://admin.hudsonlifedispatch.com/api/jobs/${jobId}/apply`, {
    method: 'POST',
    body: form
  });
  
  const data = await response.json();
  
  if (data.success) {
    // Show success message
    // Update UI to show "Applied"
  }
};
```

---

### 4. Applicant Dashboard (`/my-applications`)

Display all applications for logged-in applicant.

**Implementation:**
```typescript
const fetchApplications = async () => {
  const applicantId = localStorage.getItem('applicantId');
  const response = await fetch(
    `https://admin.hudsonlifedispatch.com/api/applicants/${applicantId}/applications`
  );
  const data = await response.json();
  return data.data;
};
```

---

## 🔒 Security Features

### Rate Limiting
- Job submissions: 3 per day per IP
- Applicant registration: 5 per hour per IP
- Job applications: 10 per hour per IP

### Validations
- Email uniqueness for applicants
- Prevent duplicate applications
- File type and size validation for resumes
- URL validation for external applications
- Required field validation

### Data Protection
- Company notes are private (not exposed via API)
- Resume files stored securely in `storage/app/public`
- Sensitive data not included in public API responses

---

## 📧 Newsletter Integration

### Auto-Subscription

Both job submissions and applicant registrations automatically subscribe users to the newsletter if they opt-in.

**Implementation:**
```php
// In controllers
if ($data['subscribe_to_newsletter'] ?? false) {
    NewsletterSubscriber::firstOrCreate(
        ['email' => $data['email']],
        [
            'email' => $data['email'],
            'is_active' => true,
            'subscribed_at' => now(),
        ]
    );
}
```

---

## 🎯 Company Portal (Future Enhancement)

### Recommended Implementation

1. **Company Login System**
   - Use Clerk authentication
   - Link companies to user accounts
   - Add `company_owner_user_id` to companies table

2. **Company Dashboard** (`/company/dashboard`)
   - View all job listings
   - See application counts
   - Manage posted jobs

3. **Applications Management** (`/company/jobs/{jobId}/applications`)
   - View all applicants for a job
   - Download resumes
   - Update application status
   - Add private notes
   - Filter by status

4. **API Endpoints** (Protected)
```http
GET /api/company/jobs
GET /api/company/jobs/{jobId}/applications
PUT /api/company/applications/{id}/status
POST /api/company/applications/{id}/note
```

---

## 📝 Job Listing Workflow

### Company Journey
1. Visit `/post-job`
2. Fill out job listing form
3. Submit → Status: "pending"
4. Receive confirmation email (optional)
5. Wait for admin approval
6. If approved → Job goes live
7. If rejected → Receive rejection email with reason

### Admin Journey
1. Navigate to Filament → Jobs → Job Listings
2. Filter by status: "pending"
3. Review job details
4. Click "Approve" → Job becomes live
5. OR click "Reject" → Enter reason → Job marked rejected

### Job Seeker Journey
1. Visit `/job-seeker-register`
2. Create profile with resume
3. Browse jobs at `/jobs`
4. Click on job → Click "Apply"
5. Fill application form (cover letter)
6. Submit → Status: "submitted"
7. Track applications in `/my-applications`

---

## 🚀 Testing the System

### Test Job Submission
```bash
curl -X POST https://admin.hudsonlifedispatch.com/api/jobs/submit \
  -H "Content-Type: application/json" \
  -d '{
    "company_name": "Test Corp",
    "company_email": "test@example.com",
    "title": "Test Developer",
    "location": "Remote",
    "type": "full-time",
    "description": "This is a test job posting",
    "application_method": "internal"
  }'
```

### Test Applicant Registration
```bash
curl -X POST https://admin.hudsonlifedispatch.com/api/applicants/register \
  -F "first_name=John" \
  -F "last_name=Doe" \
  -F "email=john@example.com" \
  -F "bio=Experienced developer" \
  -F "resume=@resume.pdf"
```

### Test Job Application
```bash
curl -X POST https://admin.hudsonlifedispatch.com/api/jobs/1/apply \
  -F "applicant_id=1" \
  -F "cover_letter=I am interested in this position"
```

---

## 📊 Admin Workflow Checklist

### Daily Tasks
- [ ] Review pending job submissions
- [ ] Approve/reject jobs
- [ ] Review new applicants
- [ ] Check new applications

### Weekly Tasks
- [ ] Mark expired jobs
- [ ] Review featured jobs
- [ ] Export applicant data
- [ ] Review application metrics

---

## 🎉 System Status

### ✅ Completed
- Database schema and migrations
- All models with relationships
- Filament admin resources for all entities
- Approval workflow for job listings
- API endpoints for frontend
- Newsletter auto-subscription
- Resume upload and storage
- Application tracking system
- Rate limiting and validation

### 🔨 TODO (Frontend)
- Job submission form UI
- Applicant registration form UI
- Job application form UI
- Applicant dashboard UI
- Company portal (future enhancement)

---

## 📞 Support

For questions or issues:
1. Check Filament admin at `admin.hudsonlifedispatch.com`
2. Review logs in Laravel: `storage/logs/laravel.log`
3. Test API endpoints with Postman or curl

---

**System built and ready for frontend integration! 🚀**

