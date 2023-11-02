'use client';

import { Kosugi_Maru } from 'next/font/google';
import { useEffect, useState } from 'react';

const kosugiMaru = Kosugi_Maru({
  weight: ['400'],
  subsets: ['latin'],
});

const NormalLayout = ({ children }: { children: React.ReactNode }) => {
  const [first, setFirst] = useState(true);

  useEffect(() => {
    if (first) {
      const timer = setTimeout(() => {
        setFirst(false);
      }, 100);
      return () => clearTimeout(timer);
    }
  }, []);

  return (
    <div
      className={`relative flex flex-col h-screen max-w-xl w-screen mx-auto  box-border bg-transparent ${kosugiMaru.className}`}
    >
      <div className="absolute w-full h-full blur-md bg-[url('/image/back.webp')] bg-cover z-0"></div>
      <div
        className={`flex flex-col h-screen max-w-xl w-screen mx-auto  box-border bg-transparent z-10 ${kosugiMaru.className}`}
      >
        <div
          className={`absolute w-[90%] max-h-[80vh] z-20 left-[5%] top-[-100vh] bg-white overflow-hidden transition-all duration-1000${
            first ? '' : ' translate-y-[110vh]'
          }`}
        >
          {children}
        </div>
      </div>
    </div>
  );
};

export default NormalLayout;
