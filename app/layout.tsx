import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'FLEHub — French Language Examinations Rwanda',
  description: 'Online French Language (FLE) Examination and Learning Management System for Rwanda. CEFR-aligned certification for A1 to C2.',
  openGraph: {
    title: 'FLEHub Rwanda',
    description: 'French Language Examinations & Learning Platform',
    images: [{ url: 'https://bolt.new/static/og_default.png' }],
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.className} antialiased`}>{children}</body>
    </html>
  );
}
