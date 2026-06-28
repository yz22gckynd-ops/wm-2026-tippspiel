'use client';

import { useEffect, useRef,useState } from 'react';
import { supabase } from '@/lib/supabaseClient';

export default function MyTipsPage() {
  const [matches, setMatches] = useState<any[]>([]);
  const [tips, setTips] = useState<Record<string, any>>({});
  const [userId, setUserId] = useState<string | null>(null);
const nextGameRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    load();
  }, []);

  async function load() {
    const { data: userData } = await supabase.auth.getUser();
    const user = userData.user;

    if (!user) {
      window.location.href = '/login';
      return;
    }

    setUserId(user.id);
const { error: playerError } = await supabase.from('players').upsert({
  id: user.id,
  email: user.email,
  name: user.email
});

if (playerError) {
  alert('PLAYER ERROR: ' + playerError.message);
}

    const { data: profile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single();

    if (!profile) {
      const name = prompt('Bitte gib deinen Tippnamen ein:');

      if (name) {
        await supabase.from('profiles').insert({
          id: user.id,
          display_name: name,
        });
      }
    }

    const { data: matchData } = await supabase
      .from('matches')
      .select('*')
   
      .order('kickoff_time');

    const { data: tipData } = await supabase
      .from('tips')
      .select('*')
      .eq('player_id', user.id);

    const byMatch: Record<string, any> = {};
    tipData?.forEach((t) => (byMatch[t.match_id] = t));

    setMatches(matchData || []);
    setTips(byMatch);
  }

  async function saveTip(matchId: string, goalsA: number, goalsB: number) {
    if (!userId) return;

    const { error } = await supabase.from('tips').upsert(
      {
        player_id: userId,
        match_id: matchId,
        tip_goals_a: goalsA,
        tip_goals_b: goalsB,
        updated_at: new Date().toISOString(),
      },
      { onConflict: 'player_id,match_id' }
    );

    if (error) {
      alert('Tipp konnte nicht gespeichert werden: ' + error.message);
    } else {
      await load();
    }
  }
const nextMatch = matches.find(
(m) => new Date(m.kickoff_time) > new Date() && !tips[m.id]
);
useEffect(() => {
if (nextMatch && nextGameRef.current) {
setTimeout(() => {
nextGameRef.current?.scrollIntoView({
behavior: 'smooth',
block: 'center',
});
}, 300);
}
}, [nextMatch?.id]);
  return (
    <div>
      <h1>Meine Tipps</h1>
      <p className="muted">
        Jeder Tipp kann bis zum jeweiligen Spielbeginn geändert werden.
      </p>

{matches.map((match) => {

 
        const locked = new Date(match.kickoff_time) <= new Date();

        return (
          <TipCard
key={match.id}
match={match}
tip={tips[match.id]}
locked={locked}
onSave={saveTip}
scrollRef={nextMatch?.id === match.id ? nextGameRef : null}
/>
        );
      })}
    </div>
  );
}

function TipCard({ match, tip, locked, onSave, scrollRef }: any) {
  const [a, setA] = useState(tip?.tip_goals_a ?? '');
  const [b, setB] = useState(tip?.tip_goals_b ?? '');

  return (
    <div className="card" ref={scrollRef}>
      <strong>
        Spiel {match.match_number}: {match.team_a} – {match.team_b}
      </strong>

      <p className="muted">
        Gruppe {match.group_name} ·{' '}
        {new Date(match.kickoff_time).toLocaleString('de-DE')} · {match.venue}
      </p>

      <input
        type="number"
        min="0"
        value={a}
        disabled={locked}
        onChange={(e) => setA(e.target.value)}
      />

      <input
        type="number"
        min="0"
        value={b}
        disabled={locked}
        onChange={(e) => setB(e.target.value)}
      />

      <button
        disabled={locked || a === '' || b === ''}
        onClick={() => onSave(match.id, Number(a), Number(b))}
      >
        {locked ? 'Gesperrt' : 'Speichern'}
      </button>
    </div>
  );
}