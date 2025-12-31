# 🧪 COMPREHENSIVE JOB BOARD TESTING PROMPT

**Task:** Manually test the complete Jobs & Companies system end-to-end and verify all functionality works in production.

---

## 🔐 ADMIN ACCESS

**⚠️ IMPORTANT:** This project uses **Clerk authentication** (OAuth), NOT traditional username/password!

**Admin Email:** `kinvergtmwn.l8yhu@simplelogin.com`  
**Admin Name:** Naya Admin  
**Authentication:** Handled by Clerk (OAuth)  

**To access admin panel:**
1. Navigate to `http://localhost:8000` (or `https://admin.hudsonlifedispatch.com` in production)
2. You'll be redirected to Clerk login
3. Sign in with the Clerk-linked account for the above email
4. Full admin access will be granted

**If you don't have Clerk access:** You'll need to check if there's a session cookie or ask the project owner for Clerk credentials.

---

## 🌐 URLs TO TEST

### Development
- **Frontend:** `http://localhost:3000`
- **Backend Admin:** `http://localhost:8000`
- **Backend API:** `http://localhost:8000/api`

### Production (When Deployed)
- **Frontend:** `https://hudsonlifedispatch.com`
- **Backend Admin:** `https://admin.hudsonlifedispatch.com`
- **Backend API:** `https://admin.hudsonlifedispatch.com/api`

---

## 📋 TESTING CHECKLIST

### Part 1: Backend API Testing (10 minutes)

Test all API endpoints return correct data:

#### Test 1.1: Jobs List API
```bash
curl -s http://localhost:8000/api/jobs | jq '.'
```

**Expected Result:**
- Status: 200 OK
- Returns array of approved jobs with pagination
- Each job has: id, title, company, location, type, description, salary_range, application_email
- Meta object with: current_page, last_page, per_page, total

**✅ Pass Criteria:** Returns 3 jobs (Full Stack Developer, 2x Head Chef)

---

#### Test 1.2: Single Job Detail API
```bash
curl -s http://localhost:8000/api/jobs/4 | jq '.'
```

**Expected Result:**
- Status: 200 OK
- Returns full job object with all details
- Title: "Full Stack Developer"
- Company: "Hudson Tech Solutions"

**✅ Pass Criteria:** Returns complete job details for ID 4

---

#### Test 1.3: Companies List API
```bash
curl -s http://localhost:8000/api/companies | jq '.'
```

**Expected Result:**
- Status: 200 OK
- Returns array of active companies
- Each company has: id, name, description, location, industry
- Meta object with pagination

**✅ Pass Criteria:** Returns at least 2 companies

---

#### Test 1.4: Company with Jobs API
```bash
curl -s "http://localhost:8000/api/companies/2?include_jobs=true" | jq '.'
```

**Expected Result:**
- Status: 200 OK
- Returns company details
- Includes `job_listings` array with related jobs
- Hudson Tech Solutions should have 1 job (Full Stack Developer)

**✅ Pass Criteria:** Company has job_listings array with at least 1 job

---

### Part 2: Frontend Job Browsing (15 minutes)

#### Test 2.1: Jobs List Page
1. Navigate to `http://localhost:3000/jobs`
2. Wait for page to load

**Verify:**
- ✅ Page title: "Jobs in the Hudson Valley | Hudson Life Dispatch"
- ✅ Heading: "Local Jobs in the Hudson Valley"
- ✅ See 3 job cards displayed
- ✅ Each card shows:
  - Job title
  - Company name
  - Location badge
  - Job type badge
  - Description preview
  - "View Details" button
- ✅ "Post a Job Opening" section at bottom
- ✅ Navigation header working
- ✅ Footer displaying

**✅ Pass Criteria:** All 3 jobs visible with complete information

**Screenshot:** Take screenshot named `test-jobs-list.png`

---

#### Test 2.2: Job Detail Page
1. Click on "Full Stack Developer" job card (or "View Details" button)
2. Wait for job detail page to load

**Verify:**
- ✅ URL changes to `/jobs/4`
- ✅ Page title: "Full Stack Developer at Hudson Tech Solutions | Hudson Life Dispatch"
- ✅ "Back to Jobs" link visible
- ✅ Job title: "Full Stack Developer"
- ✅ Company name: "Hudson Tech Solutions"
- ✅ Badges show: "full-time" and "Hudson, NY"
- ✅ Job details card shows:
  - Job Type: full-time
  - Location: Hudson, NY
  - Posted date visible
- ✅ Full job description displayed (React, Node.js, PostgreSQL mention)
- ✅ Application section visible

**✅ Pass Criteria:** All job information displays correctly

**Screenshot:** Take screenshot named `test-job-detail.png`

---

#### Test 2.3: Application Section (Unregistered User)
On the same job detail page, scroll to application section.

**Verify:**
- ✅ Card titled "Ready to Apply?"
- ✅ Message: "Create a job seeker profile to apply for this position"
- ✅ Button: "Create Profile to Apply"
- ✅ Helper text: "Already have a profile? Your profile may not be saved in this browser."

**✅ Pass Criteria:** Application section prompts unregistered users to create profile

---

### Part 3: Job Seeker Registration (20 minutes)

#### Test 3.1: Navigate to Registration
1. From job detail page, click "Create Profile to Apply" button
2. Wait for registration page to load

**Verify:**
- ✅ URL changes to `/job-seeker-register`
- ✅ Page heading: "Create Job Seeker Profile"
- ✅ Description text visible

**✅ Pass Criteria:** Registration form loads

---

#### Test 3.2: Fill Out Registration Form
Fill out the form with test data:

**Personal Information:**
- First Name: `John`
- Last Name: `Doe`
- Email: `john.doe.test@example.com`
- Phone: `555-123-4567`
- Address: `123 Main Street`
- City: `Hudson`
- State: `NY`
- ZIP Code: `12534`

**Professional Information:**
- Current Job Title: `Software Engineer`
- Professional Summary: `Experienced developer with 5 years in web applications`
- Skills: Add `JavaScript`, `React`, `Node.js` (click Add button for each)
- LinkedIn Profile: `https://linkedin.com/in/johndoe`
- Portfolio Website: `https://johndoe.dev`

**Resume/CV:**
- Upload a test PDF file (any PDF under 5MB)

**Job Preferences:**
- Job Types: Check `Full-time` and `Contract`
- Categories: Check `Professional Services`
- Desired Salary Range: `$80,000 - $100,000`
- Willing to relocate: Check

**Newsletter:**
- Check "Subscribe to Hudson Life Dispatch newsletter"

**Verify Form Validation:**
- ✅ Required fields marked with *
- ✅ Email validation working
- ✅ File upload accepts PDF/DOC/DOCX only
- ✅ File size validation (max 5MB)
- ✅ Skills can be added/removed
- ✅ All form fields accepting input

**✅ Pass Criteria:** All form fields accept valid input

**Screenshot:** Take screenshot of filled form named `test-registration-filled.png`

---

#### Test 3.3: Submit Registration
1. Click "Create Profile" button
2. Wait for submission

**Expected Behavior:**
- ✅ Form submits without errors
- ✅ POST request to `/api/applicants/register`
- ✅ Success message or redirect
- ✅ `applicantId` saved to localStorage

**To Verify localStorage:**
Open browser console and run:
```javascript
localStorage.getItem('applicantId')
```

**✅ Pass Criteria:** 
- Registration succeeds
- applicantId stored in localStorage
- Redirects back to job page OR shows success message

**Screenshot:** Take screenshot of success state named `test-registration-success.png`

---

### Part 4: Job Application Submission (15 minutes)

#### Test 4.1: Return to Job Detail Page
1. Navigate back to `http://localhost:3000/jobs/4`
2. Scroll to application section

**Verify:**
- ✅ Application form now visible (not "Create Profile" button)
- ✅ Form title: "Apply for Full Stack Developer"
- ✅ Subtitle: "at Hudson Tech Solutions"
- ✅ Cover Letter textarea visible
- ✅ Resume upload field visible
- ✅ "Submit Application" button visible

**✅ Pass Criteria:** Application form displays for registered user

---

#### Test 4.2: Fill Out Application Form
**Cover Letter:**
```
Dear Hiring Manager,

I am excited to apply for the Full Stack Developer position at Hudson Tech Solutions. With 5 years of experience in React, Node.js, and PostgreSQL, I believe I would be a great fit for your growing tech team.

I have built multiple web applications using modern JavaScript frameworks and have strong experience with database design and API development. I am particularly interested in the remote work options mentioned in the job posting.

I look forward to discussing how my skills align with your needs.

Best regards,
John Doe
```

**Resume:** 
- Upload a different PDF (optional - to test job-specific resume)
- OR leave blank to use profile resume

**Verify:**
- ✅ Cover letter textarea accepts text
- ✅ File upload working (if uploading new resume)
- ✅ Helper text visible: "Upload a different resume for this specific job..."
- ✅ Submit button enabled

**✅ Pass Criteria:** Application form accepts all inputs

**Screenshot:** Take screenshot named `test-application-filled.png`

---

#### Test 4.3: Submit Application
1. Click "Submit Application" button
2. Wait for submission

**Expected Behavior:**
- ✅ Loading state shows ("Submitting Application...")
- ✅ POST request to `/api/jobs/4/apply`
- ✅ Success message appears
- ✅ Form disappears or is replaced with success card
- ✅ Job ID added to localStorage `appliedJobs` array

**To Verify localStorage:**
```javascript
JSON.parse(localStorage.getItem('appliedJobs'))
// Should show: ["4"]
```

**Verify Success Card:**
- ✅ Shows checkmark icon
- ✅ Heading: "Application Submitted"
- ✅ Message: "You have already applied for this position..."
- ✅ "View My Applications" button visible

**✅ Pass Criteria:** 
- Application submits successfully
- Success card displays
- Cannot apply twice (form replaced with success message)

**Screenshot:** Take screenshot named `test-application-success.png`

---

### Part 5: Admin Panel Testing (25 minutes)

⚠️ **Requires Clerk authentication access**

#### Test 5.1: Access Admin Panel
1. Navigate to `http://localhost:8000`
2. Log in via Clerk (if not already logged in)

**Verify:**
- ✅ Redirects to Clerk login if not authenticated
- ✅ After login, redirects to admin dashboard
- ✅ Sidebar visible with all menu items
- ✅ Dashboard widgets displaying

**✅ Pass Criteria:** Successfully logged into admin panel

---

#### Test 5.2: View Job Listings
1. Click "Jobs" → "Job Listings" in sidebar
2. Wait for table to load

**Verify:**
- ✅ Table shows all jobs (3 jobs)
- ✅ Columns visible: Status, Title, Company, Location, Type, Category, Salary range, Is featured, Posted at, Expires at
- ✅ Status badges colored correctly:
  - Green for "approved"
  - Orange for "pending"
- ✅ Actions available: Approve, Reject, Mark Expired, Feature, Edit, Delete
- ✅ Search bar working
- ✅ Filters working
- ✅ Pagination showing "Showing 1 to 3 of 3 results"

**✅ Pass Criteria:** Job listings table displays all jobs correctly

**Screenshot:** Take screenshot named `test-admin-jobs-list.png`

---

#### Test 5.3: View Companies
1. Click "Jobs" → "Companies" in sidebar
2. Wait for table to load

**Verify:**
- ✅ Table shows companies (2 companies)
- ✅ Columns: Name, Description, Location, Industry, Is Active, Created At
- ✅ "New company" button visible
- ✅ Can click on company to view details
- ✅ Each company row has Edit/Delete actions

**✅ Pass Criteria:** Companies table displays correctly

**Screenshot:** Take screenshot named `test-admin-companies.png`

---

#### Test 5.4: View Company Details with Jobs
1. Click on "Hudson Tech Solutions" company row
2. Wait for detail page to load

**Verify:**
- ✅ Company name displayed as heading
- ✅ Company details form visible
- ✅ "Job Listings" tab/relation manager visible below form
- ✅ Job Listings section shows 1 job (Full Stack Developer)
- ✅ Can click on job to view details

**✅ Pass Criteria:** Company detail page shows related job

**Screenshot:** Take screenshot named `test-admin-company-with-jobs.png`

---

#### Test 5.5: View Applicants
1. Click "Jobs" → "Applicants" in sidebar
2. Wait for table to load

**Verify:**
- ✅ Table shows at least 1 applicant (John Doe from our test)
- ✅ Columns: Name, Email, Phone, Current Job Title, Created At
- ✅ Can click on applicant to view profile
- ✅ Search working
- ✅ View/Edit/Delete actions available

**✅ Pass Criteria:** Applicants table shows registered job seeker

**Screenshot:** Take screenshot named `test-admin-applicants.png`

---

#### Test 5.6: View Applications
1. Click "Jobs" → "Applications" in sidebar
2. Wait for table to load

**Verify:**
- ✅ Table shows at least 1 application (John Doe → Full Stack Developer)
- ✅ Columns: Applicant, Job, Status, Applied At
- ✅ Status badge colored correctly
- ✅ Can click to view full application
- ✅ Actions available: View, Approve, Reject, Delete
- ✅ Filter by status working
- ✅ Search working

**✅ Pass Criteria:** Applications table shows submitted application

**Screenshot:** Take screenshot named `test-admin-applications.png`

---

#### Test 5.7: View Application Details
1. Click on the application row (John Doe → Full Stack Developer)
2. Wait for detail page to load

**Verify:**
- ✅ Applicant information displayed:
  - Name: John Doe
  - Email: john.doe.test@example.com
  - Phone: 555-123-4567
- ✅ Job information displayed:
  - Title: Full Stack Developer
  - Company: Hudson Tech Solutions
- ✅ Cover letter visible and readable
- ✅ Resume link visible (if uploaded)
- ✅ Skills displayed (JavaScript, React, Node.js)
- ✅ Professional summary visible
- ✅ LinkedIn and Portfolio links visible
- ✅ Actions: Approve, Reject, Edit, Delete

**✅ Pass Criteria:** All application details visible and accurate

**Screenshot:** Take screenshot named `test-admin-application-detail.png`

---

#### Test 5.8: Approve/Reject Application
1. From application detail page, test approval flow
2. Click "Approve" button (or Reject)

**Verify:**
- ✅ Confirmation modal appears (if requiresConfirmation is set)
- ✅ Clicking confirm changes status
- ✅ Status badge updates to "approved" (green) or "rejected" (red)
- ✅ Success notification appears
- ✅ Can't approve already approved application

**✅ Pass Criteria:** Status changes work correctly

---

### Part 6: Edge Cases & Error Handling (15 minutes)

#### Test 6.1: Try to Apply Twice
1. Navigate to `http://localhost:3000/jobs/4`
2. Scroll to application section

**Verify:**
- ✅ Shows "Application Submitted" success card
- ✅ Does NOT show application form
- ✅ Cannot submit duplicate application
- ✅ localStorage `appliedJobs` contains job ID

**✅ Pass Criteria:** Prevents duplicate applications

---

#### Test 6.2: Test Invalid Job ID
1. Navigate to `http://localhost:3000/jobs/99999`

**Verify:**
- ✅ Shows 404 page OR "Job not found" message
- ✅ Doesn't crash the app

**✅ Pass Criteria:** Handles invalid job IDs gracefully

---

#### Test 6.3: Test Empty Jobs List
1. In admin panel, mark all jobs as "rejected" or "expired"
2. Navigate to `http://localhost:3000/jobs`

**Verify:**
- ✅ Shows "No job listings at the moment. Check back soon!" message
- ✅ Page doesn't crash or show errors
- ✅ "Post a Job Opening" section still visible

**✅ Pass Criteria:** Handles empty state correctly

---

#### Test 6.4: Test Form Validation
1. Navigate to `/job-seeker-register`
2. Try to submit empty form

**Verify:**
- ✅ Required field errors show
- ✅ Email format validated
- ✅ Cannot submit with missing required fields

**Try invalid file upload:**
- ✅ Upload .exe file → Should reject
- ✅ Upload 10MB PDF → Should reject (max 5MB)

**✅ Pass Criteria:** All validation working

---

#### Test 6.5: Test API Rate Limiting
Open terminal and run:

```bash
# Test job submission rate limit (3 per day)
for i in {1..5}; do
  curl -X POST http://localhost:8000/api/jobs/submit \
    -H "Content-Type: application/json" \
    -d '{"title":"Test","company":"Test Co","location":"NY","type":"full-time","email":"test@test.com"}'
  echo ""
done
```

**Verify:**
- ✅ First 3 requests succeed (or return validation errors)
- ✅ 4th+ requests return "Too Many Attempts" (429 status)

**✅ Pass Criteria:** Rate limiting active

---

### Part 7: Production Readiness (10 minutes)

#### Test 7.1: Check Environment Variables
1. Verify `.env` file has all required variables:

```bash
cd hudson-life-dispatch-backend
grep -E "APP_URL|DB_|MAIL_" .env
```

**Verify:**
- ✅ `APP_URL` set correctly
- ✅ `DB_*` credentials configured
- ✅ `MAIL_*` configured for email sending

---

#### Test 7.2: Check Frontend Build
```bash
cd hudson-life-dispatch-frontend
npm run build
```

**Verify:**
- ✅ Build completes without errors
- ✅ No critical warnings
- ✅ `.next` folder created

**Note:** Some warnings are acceptable, but build should succeed.

---

#### Test 7.3: Test Production API URL
1. Check `hudson-life-dispatch-frontend/.env.local` or `.env.production`
2. Verify `NEXT_PUBLIC_API_URL` points to correct backend

**Development:**
```
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

**Production:**
```
NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com/api
```

**✅ Pass Criteria:** Environment configured correctly

---

## 📊 FINAL REPORT TEMPLATE

After completing all tests, fill out this report:

---

### ✅ TEST SUMMARY

**Date Tested:** [DATE]  
**Tester:** [YOUR NAME]  
**Environment:** Development (localhost)

#### Backend API Tests (Part 1)
- [ ] 1.1 Jobs List API
- [ ] 1.2 Single Job Detail API
- [ ] 1.3 Companies List API
- [ ] 1.4 Company with Jobs API

#### Frontend Tests (Part 2-4)
- [ ] 2.1 Jobs List Page
- [ ] 2.2 Job Detail Page
- [ ] 2.3 Application Section
- [ ] 3.1-3.3 Registration Flow
- [ ] 4.1-4.3 Application Submission

#### Admin Panel Tests (Part 5)
- [ ] 5.1 Access Admin Panel
- [ ] 5.2 View Job Listings
- [ ] 5.3 View Companies
- [ ] 5.4 View Company Details with Jobs
- [ ] 5.5 View Applicants
- [ ] 5.6 View Applications
- [ ] 5.7 View Application Details
- [ ] 5.8 Approve/Reject Application

#### Edge Cases (Part 6)
- [ ] 6.1 Prevent Duplicate Applications
- [ ] 6.2 Invalid Job ID Handling
- [ ] 6.3 Empty Jobs List
- [ ] 6.4 Form Validation
- [ ] 6.5 Rate Limiting

#### Production Readiness (Part 7)
- [ ] 7.1 Environment Variables
- [ ] 7.2 Frontend Build
- [ ] 7.3 Production API URL

---

### 🐛 BUGS FOUND

List any bugs or issues discovered:

1. **Bug:** [Description]
   - **Steps to Reproduce:** [Steps]
   - **Expected:** [What should happen]
   - **Actual:** [What actually happened]
   - **Severity:** [Critical/High/Medium/Low]
   - **Screenshot:** [Filename]

2. [Next bug...]

---

### ✅ PASSED TESTS

List all tests that passed:
- [Test name] - ✅ PASS

---

### ❌ FAILED TESTS

List all tests that failed:
- [Test name] - ❌ FAIL - [Reason]

---

### 📸 SCREENSHOTS CAPTURED

- [ ] test-jobs-list.png
- [ ] test-job-detail.png
- [ ] test-registration-filled.png
- [ ] test-registration-success.png
- [ ] test-application-filled.png
- [ ] test-application-success.png
- [ ] test-admin-jobs-list.png
- [ ] test-admin-companies.png
- [ ] test-admin-company-with-jobs.png
- [ ] test-admin-applicants.png
- [ ] test-admin-applications.png
- [ ] test-admin-application-detail.png

---

### 🎯 FINAL VERDICT

**Overall System Status:** [✅ PASS / ⚠️ PASS WITH ISSUES / ❌ FAIL]

**Production Ready?** [YES / NO / WITH FIXES]

**Critical Issues:** [List any critical issues that must be fixed]

**Recommendations:** [Any recommendations for improvement]

**Summary:** [Brief summary of test results]

---

## 🚀 ESTIMATED TIME

- Part 1 (Backend API): 10 minutes
- Part 2-4 (Frontend): 50 minutes
- Part 5 (Admin Panel): 25 minutes
- Part 6 (Edge Cases): 15 minutes
- Part 7 (Production): 10 minutes

**Total Time:** ~2 hours

---

## 💡 TIPS FOR TESTING

1. **Use Browser DevTools:**
   - Check Network tab for API calls
   - Check Console for errors
   - Check Application tab for localStorage

2. **Take Screenshots:**
   - Capture every major step
   - Include URL bar in screenshots
   - Note any errors or warnings

3. **Test in Multiple Browsers:**
   - Chrome
   - Firefox
   - Safari (if on Mac)

4. **Test Mobile Responsiveness:**
   - Use DevTools device emulation
   - Test on actual mobile device if possible

5. **Document Everything:**
   - Note any unusual behavior
   - Record API response times
   - Save error messages

---

## ✅ COMPLETION CHECKLIST

- [ ] All backend API tests completed
- [ ] Complete job seeker registration tested
- [ ] Complete application submission tested
- [ ] Admin panel fully tested
- [ ] Edge cases verified
- [ ] Screenshots captured
- [ ] Test report filled out
- [ ] Bugs documented
- [ ] Final verdict provided

---

**Good luck with testing! 🧪**

