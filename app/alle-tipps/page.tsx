'use client';
import { useEffect, useState } from 'react'; import { supabase } from '@/lib/supabaseClient';
export default function AllTipsPage(){ const [matches,setMatches]=useState<any[]>([]); const [players,setPlayers]=useState<any[]>([]); const [tips,setTips]=useState<any[]>([]); useEffect(()=>{load();},[]); async function load(){ const {data:userData}=await supabase.auth.getUser(); if(!userData.user){window.location.href='/login';return;} const {data:matchData}=await supabase.from('matches').select('*').eq('round','Vorrunde').order('kickoff_time'); const {data:playerData}=await supabase.from('players').select('*').order('name'); const {data:tipData}=await supabase.from('tips').select('*'); setMatches(matchData||[]); setPlayers(playerData||[]); setTips(tipData||[]);} function tipFor(playerId:string,matchId:string){ const t=tips.find(x=>x.player_id===playerId&&x.match_id===matchId); return t?`${t.tip_goals_a}:${t.tip_goals_b}`:'';} return <div><h1>Alle Tipps</h1><div style={{ maxHeight: '75vh', overflow: 'auto' }}>
  <table><thead>
<tr>
  <th style={{position:'sticky',top:0,left:0,background:'#fff',zIndex:20}}>Nr.</th>
<th style={{position:'sticky',top:0,left:60,background:'#fff',zIndex:20}}>Datum</th>
<th style={{position:'sticky',top:0,left:180,background:'#fff',zIndex:20}}>Spiel</th>
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
</thead><tbody>{matches.map(m=><tr key={m.id}><td style={{position:'sticky',left:0,background:'#fff',zIndex:5}}>
  {m.match_number}
</td>

<td style={{position:'sticky',left:60,background:'#fff',zIndex:5}}>
  {new Date(m.kickoff_time).toLocaleString('de-DE')}
</td>

<td style={{position:'sticky',left:180,background:'#fff',zIndex:5}}>
  {m.team_a} – {m.team_b}
</td>{players.map(p=><td key={p.id}>{tipFor(p.id,m.id)}</td>)}</tr>)}</tbody></table></div></div>; }
