import Link from 'next/link';

export default function Home() {
  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col justify-center px-6">
      <p className="text-sm font-medium uppercase tracking-widest text-emerald-400">
        ScholarTrack
      </p>
      <h1 className="mt-4 text-4xl font-semibold tracking-tight sm:text-5xl">
        Scholarships that fit your CGPA.
      </h1>
      <p className="mt-4 text-lg text-slate-400">
        Enter your CGPA, see only what you qualify for, and track every
        application in one place.
      </p>
      <div className="mt-8 flex gap-3">
        <Link
          href="/scholarships"
          className="rounded-lg bg-emerald-400 px-5 py-2.5 text-sm font-semibold text-slate-950 hover:bg-emerald-300"
        >
          Browse scholarships
        </Link>
        <Link
          href="/signup"
          className="rounded-lg border border-slate-700 px-5 py-2.5 text-sm font-semibold text-slate-100 hover:border-slate-500"
        >
          Create account
        </Link>
      </div>
    </main>
  );
}
