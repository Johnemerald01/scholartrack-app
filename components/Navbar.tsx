import Link from 'next/link';

export default function Navbar() {
  return (
    <header className="border-b border-slate-800 bg-slate-950/80 backdrop-blur">
      <nav className="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
        <Link href="/" className="font-semibold tracking-tight">
          Scholar<span className="text-emerald-400">Track</span>
        </Link>
        <div className="flex gap-6 text-sm text-slate-400">
          <Link href="/scholarships" className="hover:text-slate-100">
            Scholarships
          </Link>
          <Link href="/dashboard" className="hover:text-slate-100">
            Dashboard
          </Link>
        </div>
      </nav>
    </header>
  );
}
