import type { AppProps } from 'next/app';
import { useEffect } from 'react';

export default function MyApp({ Component, pageProps }: AppProps) {
  useEffect(() => {
    if ('serviceWorker' in navigator) {
      try {
        navigator.serviceWorker
          .register('/sw.js')
          .then(() => console.log('Service Worker registered successfully'));
      } catch (error) {
        console.log('Service Worker registration failed:', error);
      }
    }
  }, []);
  return <Component {...pageProps} />;
}
