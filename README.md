# ScholarTrack

Find and track scholarships matched to your CGPA (3.00 to 5.00).

**Stack:** Next.js (App Router), Tailwind CSS, Supabase (Auth + Postgres).

## Getting started

1. `npm install`
2. Create a Supabase project, then run `supabase/schema.sql` in the SQL editor.
3. Optional: run `supabase/seed.sql` for sample (fictional) scholarships.
4. Copy `.env.example` to `.env.local` and fill in your project URL and anon key.
5. `npm run dev` and open http://localhost:3000

## Structure

- `app/(auth)` login and signup
- `app/(app)/scholarships` eligibility-matched feed with CGPA filter
- `app/(app)/dashboard` saved and tracked scholarships
- `lib/supabase` browser, server and middleware clients
- `supabase/` schema, RLS policies and seed data

## Status

Scaffold only. Features are built on top of this commit.
