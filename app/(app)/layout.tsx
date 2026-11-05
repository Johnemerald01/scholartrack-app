import Navbar from '@/components/Navbar';

export default function AppLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <>
      <Navbar />
      <div className="mx-auto max-w-5xl px-6 py-10">{children}</div>
    </>
  );
}
