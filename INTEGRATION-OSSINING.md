# Integration Guide: Template System → Ossining Edit Project

## Overview
Connect the reusable local newsletter system (`01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/local-newsletter/`) with the active Ossining project (`01-ACTIVE-PROJECTS/ossining-edit/`).

## Current State

### What Ossining Edit Has
- **Next.js app** with business directory, events calendar
- **Weekly newsletter feature** (planned, see `/docs/features/weekly-newsletter.md`)
- **Resend** for email delivery
- **Database**: NeonDB with Drizzle ORM
- **Auth**: Clerk

### What Template System Has
- **Business model** (Selena 311 automation guide)
- **Operational guides** (Lookout Media strategies)
- **Claude Skills** for research, writing, transcription
- **Launch checklists** and market research
- **AI automation infrastructure**

## Integration Tasks

### Phase 1: Add Newsletter Automation to Ossining Edit

#### 1.1 Create Newsletter Research CLI

**Location**: `01-ACTIVE-PROJECTS/ossining-edit/scripts/newsletter/`

**Files to Create**:
```
scripts/newsletter/
├── research.ts          # Main research script
├── writer.ts            # Newsletter writer script
├── transcriber.ts       # Meeting transcriber script
├── lib/
│   ├── events.ts        # Event research functions
│   ├── meetings.ts      # Meeting research functions  
│   ├── businesses.ts    # Business news research
│   └── openai.ts        # OpenAI API wrapper
└── templates/
    └── newsletter.md    # Newsletter template
```

**Implementation**:
```typescript
// scripts/newsletter/research.ts
import { searchEventbrite } from './lib/events';
import { getTownMeetings } from './lib/meetings';
import { searchBusinessNews } from './lib/businesses';

interface NewsletterResearch {
  events: Event[];
  meetings: Meeting[];
  businessNews: BusinessNews[];
  quickHits: QuickHit[];
}

async function researchNewsletter(town: string, date: Date): Promise<NewsletterResearch> {
  console.log(`Researching newsletter for ${town} on ${date.toDateString()}`);
  
  const [events, meetings, businessNews] = await Promise.all([
    searchEventbrite(town, date),
    getTownMeetings(town),
    searchBusinessNews(town, date)
  ]);
  
  return {
    events,
    meetings,
    businessNews,
    quickHits: [] // TODO: implement
  };
}

// CLI usage
if (require.main === module) {
  const town = process.argv[2] || 'Ossining, NY';
  const date = new Date();
  
  researchNewsletter(town, date)
    .then(research => {
      console.log(JSON.stringify(research, null, 2));
    });
}
```

#### 1.2 Integrate with Existing Newsletter Feature

**Existing file**: `01-ACTIVE-PROJECTS/ossining-edit/docs/features/weekly-newsletter.md`

**Add automation section**:
```markdown
## Automation Options

### Manual Curation (Current)
- Editor researches and writes newsletter
- ~4 hours/week effort
- Full editorial control

### Hybrid Automation (Recommended)
- Scripts gather research (events, meetings, businesses)
- Editor writes newsletter using compiled research
- ~2 hours/week effort
- Balance of automation + human voice

### Full Automation (Future)
- AI generates complete newsletter draft
- Editor reviews and approves
- ~30 min/week effort
- Requires Ghost CMS instead of Resend
```

#### 1.3 Add Database Schema for Newsletter

**Location**: `01-ACTIVE-PROJECTS/ossining-edit/db/schema/newsletter.ts`

```typescript
import { pgTable, text, timestamp, jsonb, boolean } from 'drizzle-orm/pg-core';

export const newsletterIssues = pgTable('newsletter_issues', {
  id: text('id').primaryKey(),
  issueNumber: text('issue_number').notNull(),
  sendDate: timestamp('send_date').notNull(),
  subject: text('subject').notNull(),
  content: text('content').notNull(), // HTML or Markdown
  status: text('status').notNull(), // draft, scheduled, sent
  research: jsonb('research'), // Research data used
  metrics: jsonb('metrics'), // Open rate, clicks, etc.
  createdAt: timestamp('created_at').defaultNow(),
  publishedAt: timestamp('published_at'),
});

export const newsletterResearch = pgTable('newsletter_research', {
  id: text('id').primaryKey(),
  issueId: text('issue_id').references(() => newsletterIssues.id),
  researchDate: timestamp('research_date').notNull(),
  data: jsonb('data').notNull(), // Events, meetings, etc.
  source: text('source'), // 'manual', 'automated', 'hybrid'
  createdAt: timestamp('created_at').defaultNow(),
});
```

**Add migration**:
```bash
cd 01-ACTIVE-PROJECTS/ossining-edit
npx drizzle-kit generate:pg --schema=./db/schema/newsletter.ts
npx drizzle-kit push:pg
```

#### 1.4 Create Newsletter Admin UI

**Location**: `01-ACTIVE-PROJECTS/ossining-edit/app/(authenticated)/admin/newsletter/`

**Files**:
```
app/(authenticated)/admin/newsletter/
├── page.tsx                  # Newsletter dashboard
├── research/
│   └── page.tsx              # Run research, view results
├── editor/
│   └── page.tsx              # Write/edit newsletter
└── schedule/
    └── page.tsx              # Schedule send
```

**Dashboard** (`page.tsx`):
```tsx
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';

export default async function NewsletterDashboard() {
  // Fetch recent issues from DB
  const issues = await db.select().from(newsletterIssues).limit(10);
  
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-semibold">Newsletter</h1>
        <Button asChild>
          <Link href="/admin/newsletter/research">Start New Issue</Link>
        </Button>
      </div>
      
      <div className="grid gap-4">
        {issues.map(issue => (
          <Card key={issue.id} className="p-4">
            <div className="flex justify-between">
              <div>
                <h3 className="font-medium">Issue #{issue.issueNumber}</h3>
                <p className="text-sm text-muted-foreground">{issue.subject}</p>
                <p className="text-xs text-muted-foreground">
                  Send: {issue.sendDate.toLocaleDateString()}
                </p>
              </div>
              <div className="flex gap-2">
                <Button variant="outline" size="sm">Edit</Button>
                <Button variant="outline" size="sm">Preview</Button>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
```

### Phase 2: Connect to Template Resources

#### 2.1 Link to Guides from Admin

Add "Resources" section to Newsletter dashboard:

```tsx
<Card className="p-4 bg-card/50">
  <h3 className="font-medium mb-2">Resources & Guides</h3>
  <ul className="space-y-1 text-sm">
    <li>
      <a href="/docs/local-newsletter-ops" className="text-primary hover:underline">
        → Operational Playbooks
      </a>
    </li>
    <li>
      <a href="/docs/selena-311-case-study" className="text-primary hover:underline">
        → Selena 311: $500K Automation Model
      </a>
    </li>
    <li>
      <a href="/docs/claude-skills" className="text-primary hover:underline">
        → Claude Skills for Research & Writing
      </a>
    </li>
  </ul>
</Card>
```

#### 2.2 Copy Guides to Ossining Project

**Option A**: Symlink (keeps in sync)
```bash
cd 01-ACTIVE-PROJECTS/ossining-edit/docs
ln -s ../../../01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/local-newsletter local-newsletter-ops
ln -s ../../../01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/claude-skills claude-skills
```

**Option B**: Copy (can customize)
```bash
cp -r 01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/local-newsletter/local-newsletter-ops 01-ACTIVE-PROJECTS/ossining-edit/docs/
cp -r 01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/claude-skills 01-ACTIVE-PROJECTS/ossining-edit/docs/
```

### Phase 3: Implement Automation Scripts

#### 3.1 Event Research Script

**File**: `01-ACTIVE-PROJECTS/ossining-edit/scripts/newsletter/lib/events.ts`

```typescript
import axios from 'axios';

interface Event {
  title: string;
  date: string;
  time: string;
  venue: string;
  description: string;
  url: string;
  source: string;
}

export async function searchEventbrite(town: string, date: Date): Promise<Event[]> {
  // Implement Eventbrite API search
  // For now, return mock data
  return [
    {
      title: 'Holiday Market at Veterans Park',
      date: date.toISOString().split('T')[0],
      time: '10:00 AM - 4:00 PM',
      venue: 'Veterans Park',
      description: 'Annual holiday market with local vendors',
      url: 'https://eventbrite.com/...',
      source: 'Eventbrite'
    }
  ];
}

export async function searchFacebookEvents(town: string): Promise<Event[]> {
  // Implement Facebook events search (requires Graph API)
  return [];
}

export async function scrapeTownCalendar(townUrl: string): Promise<Event[]> {
  // Scrape town website calendar
  return [];
}
```

#### 3.2 Meeting Transcriber Script

**File**: `01-ACTIVE-PROJECTS/ossining-edit/scripts/newsletter/transcriber.ts`

```typescript
import OpenAI from 'openai';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

interface MeetingTranscript {
  text: string;
  topics: Topic[];
}

interface Topic {
  title: string;
  keyPoints: string[];
  quotes: Quote[];
  newsworthiness: number;
}

async function transcribeMeeting(videoUrl: string): Promise<MeetingTranscript> {
  // Download audio
  const audioFile = await downloadAudio(videoUrl);
  
  // Transcribe with Whisper
  const transcript = await openai.audio.transcriptions.create({
    file: fs.createReadStream(audioFile),
    model: 'whisper-1'
  });
  
  // Analyze topics
  const topics = await analyzeTopics(transcript.text);
  
  return {
    text: transcript.text,
    topics
  };
}

async function downloadAudio(videoUrl: string): Promise<string> {
  const outputFile = `/tmp/meeting-${Date.now()}.mp3`;
  await execAsync(`yt-dlp -f 'bestaudio' -x --audio-format mp3 "${videoUrl}" -o "${outputFile}"`);
  return outputFile;
}

async function analyzeTopics(transcript: string): Promise<Topic[]> {
  const response = await openai.chat.completions.create({
    model: 'gpt-4',
    messages: [
      {
        role: 'system',
        content: 'You are a local news analyst. Identify 5-7 newsworthy topics from this town board meeting transcript.'
      },
      {
        role: 'user',
        content: transcript
      }
    ],
    response_format: { type: 'json_object' }
  });
  
  return JSON.parse(response.choices[0].message.content || '{}').topics || [];
}
```

### Phase 4: Add to Package Scripts

**File**: `01-ACTIVE-PROJECTS/ossining-edit/package.json`

```json
{
  "scripts": {
    "newsletter:research": "tsx scripts/newsletter/research.ts",
    "newsletter:write": "tsx scripts/newsletter/writer.ts",
    "newsletter:transcribe": "tsx scripts/newsletter/transcriber.ts",
    "newsletter:send": "tsx scripts/newsletter/send.ts"
  }
}
```

**Usage**:
```bash
# Research this week's content
npm run newsletter:research -- "Ossining, NY"

# Transcribe meeting
npm run newsletter:transcribe -- "https://youtube.com/..."

# Generate newsletter draft
npm run newsletter:write

# Send newsletter
npm run newsletter:send -- --issue=8
```

## Quick Start: Ossining Newsletter Launch

### Week 1: Setup
```bash
# 1. Copy scripts to Ossining project
cp -r 01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/claude-skills 01-ACTIVE-PROJECTS/ossining-edit/scripts/claude-skills

# 2. Install dependencies
cd 01-ACTIVE-PROJECTS/ossining-edit
npm install openai yt-dlp-exec

# 3. Add environment variables
echo "OPENAI_API_KEY=sk-..." >> .env.local

# 4. Create database tables
npx drizzle-kit push:pg

# 5. Test research script
npm run newsletter:research -- "Ossining, NY"
```

### Week 2-3: Manual Process (Test)
1. Run research script manually
2. Copy output to newsletter template
3. Write newsletter manually using research
4. Send via Resend
5. Track what works

### Week 4+: Hybrid Automation
1. Research script runs weekly (cron job)
2. AI drafts sections (events, quick hits)
3. Human writes top story + business spotlight
4. Review and send

### Month 3+: Full Automation
1. Consider switching to Ghost CMS
2. Implement full AI workflow
3. Human review only
4. Scale to daily

## Templates for Other Local Business Types

### Coming Next
1. **Local Directory** (business listing site)
2. **Events Calendar** (community events)
3. **Job Board** (local employment)
4. **Classifieds** (buy/sell/trade)
5. **Service Marketplace** (find local pros)

Each will follow same pattern:
- Business model guide
- Technical implementation
- Claude Skills
- Integration with existing projects

## Success Metrics

Track in Ossining Edit admin:
- Time saved vs manual (target: 50-75% reduction)
- Newsletter quality (open rate >30%)
- Automation accuracy (>90% usable content)
- Cost per issue (target: <$5)

## Next Steps

1. **Implement Phase 1** (Newsletter automation in Ossining Edit)
2. **Test with one issue** (manual review, gather feedback)
3. **Iterate on automation** (improve prompts, add sources)
4. **Document learnings** (update template system)
5. **Scale** (daily newsletter, multiple towns)

## Resources

- Template System: `/01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/local-newsletter/`
- Ossining Project: `/01-ACTIVE-PROJECTS/ossining-edit/`
- Claude Skills: `/01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/claude-skills/`
- Case Studies: `/01-NEW-PROJECT-SYSTEMS/7-TEMPLATES/local-newsletter/local-newsletter-ops/`

