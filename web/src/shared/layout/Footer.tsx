// web/src/shared/layout/Footer.tsx
export default function Footer() {
  return (
    <footer className="border-t border-slate-200 bg-white px-6 py-3 text-center text-sm text-slate-500 dark:border-slate-700 dark:bg-slate-950 dark:text-slate-400">
      © {new Date().getFullYear()} MAMBONAMI
    </footer>
  );
}
