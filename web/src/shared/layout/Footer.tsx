// web/src/shared/layout/Footer.tsx
export default function Footer() {
  return (
    <footer className="bg-white border-t border-slate-200 py-3 text-center text-sm text-slate-500">
      © {new Date().getFullYear()} MAMBONAMI
    </footer>
  );
}
