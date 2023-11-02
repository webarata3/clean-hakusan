import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'クリーン白山 - 白山市ゴミ収集日程',
  description: '石川県白山市のゴミ収集日程確認アプリです。白山市公式のものではありません。',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <html lang="ja">
        <body className={inter.className}>{children}</body>
      </html>
    </>
  );
}
