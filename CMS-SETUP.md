# CMS / Backend setup

The website now includes a Supabase-backed content manager.

## What you can manage
- Blog posts: title, slug, excerpt, article, image, publish/draft
- Services: title, description, full content, image, publish/draft
- Case studies: title, category, description, result, project URL, image, publish/draft
- Image uploads through Supabase Storage

## One-time setup
1. Create a project at Supabase.
2. In Supabase SQL Editor, run `supabase-schema.sql`.
3. In Supabase Authentication, create your admin user with email/password.
4. Copy your Supabase Project URL and anon public key.
5. Put them in `supabase-config.js`:
   url: "YOUR_SUPABASE_PROJECT_URL"
   anonKey: "YOUR_SUPABASE_ANON_KEY"
6. Deploy the whole folder to Netlify.
7. Open `/admin.html` to log in and manage content.

The anon key is safe to expose in the browser when Row Level Security policies are configured as in the supplied SQL. Never put a Supabase service-role key in this website.

## Image sources
The default visual images are from Unsplash and are used as presentation imagery for website development, SEO, project management and interior/project presentation sections. Replace them from the admin dashboard as you add your own project images.

## Production note
For the contact form, connect it to Netlify Forms, Formspree, or a server-side email endpoint before launch. The current site keeps the existing contact flow.

## Blog editor
The admin dashboard includes a visual rich-text editor for blog content. Use H2/H3, bold, italic, lists and links instead of typing Markdown symbols such as `**bold**`.

## Blog scheduling
Run `supabase-schedule-migration.sql` once in the Supabase SQL Editor. The admin dashboard then supports Publish immediately, Schedule for later, and Save as draft. Scheduled posts appear in the admin list but are not publicly visible until their scheduled time.
