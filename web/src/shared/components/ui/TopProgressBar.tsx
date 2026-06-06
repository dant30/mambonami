// frontend/src/shared/components/ui/TopProgressBar.tsx
import { useEffect, useState } from "react";

export function TopProgressBar() {
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    let timer: number;
    
    // Animate to 85% over 3 seconds
    setProgress(15);
    timer = window.setTimeout(() => setProgress(40), 500);
    timer = window.setTimeout(() => setProgress(65), 1500);
    timer = window.setTimeout(() => setProgress(85), 3000);

    // If it takes longer than 10 seconds, slowly creep up
    const interval = window.setInterval(() => {
      setProgress((prev) => {
        if (prev >= 95) return prev;
        return prev + 1;
      });
    }, 2000);

    return () => {
      clearTimeout(timer);
      clearInterval(interval);
    };
  }, []);


  return (
    <div className="fixed inset-x-0 top-0 z-[9999] h-1 overflow-hidden bg-transparent">
      <div
        className="h-full bg-[#1b7339] shadow-[0_0_10px_#1b7339,0_0_5px_#1b7339] transition-all duration-300 ease-out"
        style={{ width: `${progress}%` }}
      />
    </div>
  );
}