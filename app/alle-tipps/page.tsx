'use client';
import { useEffect, useRef, useState } const nextGameRef = useRef<HTMLTableRowElement | null>(null) from 'react'; import { supabase } from '@/lib/supabaseClient';
export default function AllTipsPage(){ const [matches,setMatches]=useState<any[]>([]); const [players,setPlayers]=useState<any[]>([]); const [tips,setTips]=useState<any[]>([]); useEffect(()=>{load();},[]); async function load(){ const {data:userData}=await supabase.auth.getUser(); if(!userData.user){window.location.href='/login';return;} const {data:matchData}=await supabase.from('matches').select('*').order('kickoff_time'); const {data:playerData}=await supabase.from('players').select('*').order('name');const {data:tipData}=await supabase
.from(`tips`)
.select(`*`)
.range(0, 5000); setMatches(matchData||[]); setPlayers(playerData||[]); setTips(tipData||[]);} function tipFor(playerId:string,matchId:string){ const t=tips.find(x=>x.player_id===playerId&&x.match_id===matchId); return t?`${t.tip_goals_a}:${t.tip_goals_b}`:'';} useEffect(() => {
if (nextMatch && nextGameRef.current) {
setTimeout(() => {
nextGameRef.current?.scrollIntoView({
behavior: 'smooth',
block: 'center',
});
}, 300);
}
}, [nextMatch?.id]);
 return <div><h1>Alle Tipps</h1><div style={{ maxHeight: '75vh', overflow: 'auto' }}>
  <table><thead>
<tr>
 <th style={{position:'sticky',top:0,background:'#fff',zIndex:10}}>Nr.</th>
<th style={{position:'sticky',top:0,background:'#fff',zIndex:10}}>Datum</th>
<th style={{position:'sticky',top:0,left:0,background:'#fff',zIndex:30}}>Spiel</th>
  {players.map(p =>
    <th
      key={p.id}
      style={{
        position:'sticky',
        top:0,
        background:'#fff',
        zIndex:10
      }}
    >
      {p.name}
    </th>
  )}
</tr>
</thead><tbody>{matches.map(m=><tr
key={m.id}
ref={nextMatch?.id === m.id ? nextGameRef : null}
><td>{m.match_number}</td>
<td>{new Date(m.kickoff_time).toLocaleString('de-DE')}</td>
<td style={{position:'sticky',left:0,background:'#fff',zIndex:20}}>
  {m.team_a} – {m.team_b}
</td>{players.map(p=><td key={p.id}>{tipFor(p.id,m.id)}</td>)}</tr>)}</tbody></table></div></div>; }
