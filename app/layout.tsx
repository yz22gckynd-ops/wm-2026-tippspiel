import './globals.css';
export const metadata = { title: 'WM 2026 Tippspiel', description: 'Privates Tippspiel zur FIFA WM 2026' };
export default function RootLayout({ children }: { children: React.ReactNode }) { return (<html lang='de'><body><main className='page'><nav className='nav'><a href='/meine-tipps'>Meine Tipps</a><a href='/alle-tipps'>Alle Tipps</a><a href='/rangliste'>Rangliste</a><a href='/admin/ergebnisse'>Ergebnisse</a><a href='/admin/spiele'>Spiele</a><a href='/admin/spieler'>Spieler</a></nav>{children}</main></body></html>); }
