// Dynamic sitemap: combines the site's static pages with every published
// blog post pulled live from Supabase, so new posts are automatically
// included without ever needing to hand-edit a sitemap file.
//
// This runs as a Vercel serverless function (mapped to /sitemap.xml via
// vercel.json rewrites).

const SUPABASE_URL = "https://nerntdfyptcdftcmlixc.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lcm50ZGZ5cHRjZGZ0Y21saXhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5ODY1OTAsImV4cCI6MjEwMjU2MjU5MH0.bhpLZw0DU7qx1RJ9pOdXIN9ox-z8gBj8xHuhlNhvc7I";
const BASE = "https://digitalpmm.vercel.app";

const staticUrls = [
  { loc: `${BASE}/`, priority: "1.0" },
  { loc: `${BASE}/services`, priority: "0.9" },
  { loc: `${BASE}/services/digital-project-management`, priority: "0.8" },
  { loc: `${BASE}/services/seo`, priority: "0.8" },
  { loc: `${BASE}/services/website-development`, priority: "0.8" },
  { loc: `${BASE}/services/consulting`, priority: "0.8" },
  { loc: `${BASE}/projects`, priority: "0.8" },
  { loc: `${BASE}/about`, priority: "0.7" },
  { loc: `${BASE}/blog`, priority: "0.7" },
  { loc: `${BASE}/contact`, priority: "0.6" },
];

module.exports = async (req, res) => {
  let postUrls = [];

  try {
    const resp = await fetch(
      `${SUPABASE_URL}/rest/v1/posts?select=slug,id,updated_at,scheduled_at&published=eq.true`,
      {
        headers: {
          apikey: SUPABASE_ANON_KEY,
          Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
        },
      }
    );
    const posts = await resp.json();
    const now = new Date();

    if (Array.isArray(posts)) {
      postUrls = posts
        .filter((p) => !p.scheduled_at || new Date(p.scheduled_at) <= now)
        .map((p) => ({
          loc: `${BASE}/post?${p.slug ? "slug=" + encodeURIComponent(p.slug) : "id=" + encodeURIComponent(p.id)}`,
          lastmod: p.updated_at ? new Date(p.updated_at).toISOString().split("T")[0] : undefined,
          priority: "0.6",
        }));
    }
  } catch (e) {
    // If Supabase is unreachable, still serve the static pages below
    // rather than failing the whole sitemap.
  }

  const allUrls = [...staticUrls, ...postUrls];

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${allUrls
  .map(
    (u) => `  <url>
    <loc>${u.loc}</loc>
${u.lastmod ? `    <lastmod>${u.lastmod}</lastmod>\n` : ""}    <priority>${u.priority}</priority>
  </url>`
  )
  .join("\n")}
</urlset>`;

  res.setHeader("Content-Type", "application/xml");
  res.status(200).send(xml);
};
