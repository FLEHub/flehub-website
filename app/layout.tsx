import './globals.css';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'MFK — Maison de la Francophonie Kigali',
  description: 'Maison de la Francophonie Kigali (MFK) — examens et apprentissage du français langue étrangère, certifications CECRL A1 à C2.',
  icons: {
    icon: [{ url: '/logo-mfk.png', type: 'image/png' }],
    apple: '/logo-mfk.png',
    shortcut: '/logo-mfk.png',
  },
  openGraph: {
    title: 'MFK — Maison de la Francophonie Kigali',
    description: 'Examens et apprentissage du français — Maison de la Francophonie Kigali',
    images: [{ url: '/logo-mfk.png', width: 512, height: 512, alt: 'Logo MFK' }],
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className={`${inter.className} antialiased`}>{children}</body>
    </html>
  );
}
