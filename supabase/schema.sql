create extension if not exists pgcrypto;
create table if not exists players (id uuid primary key references auth.users(id) on delete cascade,email text not null unique,name text not null,is_admin boolean default false,created_at timestamp with time zone default now());
create table if not exists matches (id uuid primary key default gen_random_uuid(),match_number int not null unique,round text not null default 'Vorrunde',group_name text,kickoff_time timestamp with time zone not null,team_a text not null,team_b text not null,venue text,goals_a int,goals_b int,is_finished boolean default false);
create table if not exists tips (id uuid primary key default gen_random_uuid(),player_id uuid not null references players(id) on delete cascade,match_id uuid not null references matches(id) on delete cascade,tip_goals_a int not null check (tip_goals_a >= 0),tip_goals_b int not null check (tip_goals_b >= 0),updated_at timestamp with time zone default now(),unique(player_id, match_id));
create or replace view leaderboard as select p.id as player_id,p.name,p.email,coalesce(sum(case when m.is_finished=false or m.goals_a is null or m.goals_b is null then 0 when t.tip_goals_a=m.goals_a and t.tip_goals_b=m.goals_b then 5 when (t.tip_goals_a-t.tip_goals_b)=(m.goals_a-m.goals_b) then 3 when sign(t.tip_goals_a-t.tip_goals_b)=sign(m.goals_a-m.goals_b) then 2 else 0 end),0) as points,count(t.id) filter (where m.is_finished=true) as counted_tips from players p left join tips t on t.player_id=p.id left join matches m on m.id=t.match_id group by p.id,p.name,p.email order by points desc,p.name asc;
alter table players enable row level security; alter table matches enable row level security; alter table tips enable row level security;
drop policy if exists "Spieler duerfen alle Spieler sehen" on players; create policy "Spieler duerfen alle Spieler sehen" on players for select using (auth.role() = 'authenticated');
drop policy if exists "Alle eingeloggten Nutzer duerfen Spiele sehen" on matches; create policy "Alle eingeloggten Nutzer duerfen Spiele sehen" on matches for select using (auth.role() = 'authenticated');
drop policy if exists "Alle eingeloggten Nutzer duerfen Tipps sehen" on tips; create policy "Alle eingeloggten Nutzer duerfen Tipps sehen" on tips for select using (auth.role() = 'authenticated');
drop policy if exists "Eigene Tipps eintragen" on tips; create policy "Eigene Tipps eintragen" on tips for insert with check (auth.uid()=player_id and exists (select 1 from matches where matches.id=tips.match_id and matches.kickoff_time > now()));
drop policy if exists "Eigene Tipps vor Spielbeginn aendern" on tips; create policy "Eigene Tipps vor Spielbeginn aendern" on tips for update using (auth.uid()=player_id and exists (select 1 from matches where matches.id=tips.match_id and matches.kickoff_time > now())) with check (auth.uid()=player_id);
drop policy if exists "Admin darf Spiele eintragen" on matches; create policy "Admin darf Spiele eintragen" on matches for insert with check (exists (select 1 from players where players.id=auth.uid() and players.is_admin=true));
drop policy if exists "Admin darf Spiele aendern" on matches; create policy "Admin darf Spiele aendern" on matches for update using (exists (select 1 from players where players.id=auth.uid() and players.is_admin=true));
drop policy if exists "Admin darf Spieler aendern" on players; create policy "Admin darf Spieler aendern" on players for update using (exists (select 1 from players p where p.id=auth.uid() and p.is_admin=true));
delete from matches where round='Vorrunde';
insert into matches (match_number, round, group_name, kickoff_time, team_a, team_b, venue) values
(1, 'Vorrunde', 'A', '2026-06-11 19:00:00+00', 'Mexiko', 'Südafrika', 'Mexico City Stadium'),
(2, 'Vorrunde', 'A', '2026-06-12 02:00:00+00', 'Südkorea', 'Tschechien', 'Guadalajara Stadium'),
(3, 'Vorrunde', 'B', '2026-06-12 19:00:00+00', 'Kanada', 'Bosnien und Herzegowina', 'Toronto Stadium'),
(4, 'Vorrunde', 'D', '2026-06-13 01:00:00+00', 'USA', 'Paraguay', 'Los Angeles Stadium'),
(5, 'Vorrunde', 'B', '2026-06-13 19:00:00+00', 'Katar', 'Schweiz', 'San Francisco Bay Area Stadium'),
(6, 'Vorrunde', 'C', '2026-06-13 22:00:00+00', 'Brasilien', 'Marokko', 'New York New Jersey Stadium'),
(7, 'Vorrunde', 'C', '2026-06-14 01:00:00+00', 'Haiti', 'Schottland', 'Boston Stadium'),
(8, 'Vorrunde', 'D', '2026-06-14 04:00:00+00', 'Australien', 'Türkei', 'Vancouver Stadium'),
(9, 'Vorrunde', 'E', '2026-06-14 17:00:00+00', 'Deutschland', 'Curaçao', 'Houston Stadium'),
(10, 'Vorrunde', 'F', '2026-06-14 20:00:00+00', 'Niederlande', 'Japan', 'Dallas Stadium'),
(11, 'Vorrunde', 'E', '2026-06-14 23:00:00+00', 'Elfenbeinküste', 'Ecuador', 'Philadelphia Stadium'),
(12, 'Vorrunde', 'F', '2026-06-15 02:00:00+00', 'Schweden', 'Tunesien', 'Monterrey Stadium'),
(13, 'Vorrunde', 'H', '2026-06-15 16:00:00+00', 'Spanien', 'Kap Verde', 'Atlanta Stadium'),
(14, 'Vorrunde', 'G', '2026-06-15 19:00:00+00', 'Belgien', 'Ägypten', 'Seattle Stadium'),
(15, 'Vorrunde', 'H', '2026-06-15 22:00:00+00', 'Saudi-Arabien', 'Uruguay', 'Miami Stadium'),
(16, 'Vorrunde', 'G', '2026-06-16 01:00:00+00', 'Iran', 'Neuseeland', 'Los Angeles Stadium'),
(17, 'Vorrunde', 'I', '2026-06-16 19:00:00+00', 'Frankreich', 'Senegal', 'New York New Jersey Stadium'),
(18, 'Vorrunde', 'I', '2026-06-16 22:00:00+00', 'Irak', 'Norwegen', 'Boston Stadium'),
(19, 'Vorrunde', 'J', '2026-06-17 01:00:00+00', 'Argentinien', 'Algerien', 'Kansas City Stadium'),
(20, 'Vorrunde', 'J', '2026-06-17 04:00:00+00', 'Österreich', 'Jordanien', 'San Francisco Bay Area Stadium'),
(21, 'Vorrunde', 'K', '2026-06-17 17:00:00+00', 'Portugal', 'DR Kongo', 'Houston Stadium'),
(22, 'Vorrunde', 'L', '2026-06-17 20:00:00+00', 'England', 'Kroatien', 'Dallas Stadium'),
(23, 'Vorrunde', 'L', '2026-06-17 23:00:00+00', 'Ghana', 'Panama', 'Toronto Stadium'),
(24, 'Vorrunde', 'K', '2026-06-18 02:00:00+00', 'Usbekistan', 'Kolumbien', 'Mexico City Stadium'),
(25, 'Vorrunde', 'A', '2026-06-18 16:00:00+00', 'Tschechien', 'Südafrika', 'Atlanta Stadium'),
(26, 'Vorrunde', 'B', '2026-06-18 19:00:00+00', 'Schweiz', 'Bosnien und Herzegowina', 'Los Angeles Stadium'),
(27, 'Vorrunde', 'B', '2026-06-18 22:00:00+00', 'Kanada', 'Katar', 'Vancouver Stadium'),
(28, 'Vorrunde', 'A', '2026-06-19 01:00:00+00', 'Mexiko', 'Südkorea', 'Guadalajara Stadium'),
(29, 'Vorrunde', 'C', '2026-06-19 22:00:00+00', 'Schottland', 'Marokko', 'Boston Stadium'),
(30, 'Vorrunde', 'C', '2026-06-20 00:30:00+00', 'Brasilien', 'Haiti', 'Philadelphia Stadium'),
(31, 'Vorrunde', 'D', '2026-06-19 19:00:00+00', 'USA', 'Australien', 'Seattle Stadium'),
(32, 'Vorrunde', 'D', '2026-06-20 03:00:00+00', 'Türkei', 'Paraguay', 'San Francisco Bay Area Stadium'),
(33, 'Vorrunde', 'F', '2026-06-20 17:00:00+00', 'Niederlande', 'Schweden', 'Houston Stadium'),
(34, 'Vorrunde', 'E', '2026-06-20 20:00:00+00', 'Deutschland', 'Elfenbeinküste', 'Toronto Stadium'),
(35, 'Vorrunde', 'E', '2026-06-21 00:00:00+00', 'Ecuador', 'Curaçao', 'Kansas City Stadium'),
(36, 'Vorrunde', 'F', '2026-06-21 04:00:00+00', 'Tunesien', 'Japan', 'Monterrey Stadium'),
(37, 'Vorrunde', 'H', '2026-06-21 16:00:00+00', 'Spanien', 'Saudi-Arabien', 'Atlanta Stadium'),
(38, 'Vorrunde', 'G', '2026-06-21 19:00:00+00', 'Belgien', 'Iran', 'Los Angeles Stadium'),
(39, 'Vorrunde', 'H', '2026-06-21 22:00:00+00', 'Uruguay', 'Kap Verde', 'Miami Stadium'),
(40, 'Vorrunde', 'G', '2026-06-22 01:00:00+00', 'Neuseeland', 'Ägypten', 'Vancouver Stadium'),
(41, 'Vorrunde', 'I', '2026-06-22 21:00:00+00', 'Frankreich', 'Irak', 'Philadelphia Stadium'),
(42, 'Vorrunde', 'I', '2026-06-23 00:00:00+00', 'Norwegen', 'Senegal', 'New York New Jersey Stadium'),
(43, 'Vorrunde', 'J', '2026-06-22 17:00:00+00', 'Argentinien', 'Österreich', 'Dallas Stadium'),
(44, 'Vorrunde', 'J', '2026-06-23 03:00:00+00', 'Jordanien', 'Algerien', 'San Francisco Bay Area Stadium'),
(45, 'Vorrunde', 'K', '2026-06-23 17:00:00+00', 'Portugal', 'Usbekistan', 'Houston Stadium'),
(46, 'Vorrunde', 'L', '2026-06-23 20:00:00+00', 'England', 'Ghana', 'Boston Stadium'),
(47, 'Vorrunde', 'L', '2026-06-23 23:00:00+00', 'Panama', 'Kroatien', 'Toronto Stadium'),
(48, 'Vorrunde', 'K', '2026-06-24 02:00:00+00', 'Kolumbien', 'DR Kongo', 'Guadalajara Stadium'),
(49, 'Vorrunde', 'B', '2026-06-24 19:00:00+00', 'Schweiz', 'Kanada', 'Vancouver Stadium'),
(50, 'Vorrunde', 'B', '2026-06-24 19:00:00+00', 'Bosnien und Herzegowina', 'Katar', 'Seattle Stadium'),
(51, 'Vorrunde', 'C', '2026-06-24 22:00:00+00', 'Schottland', 'Brasilien', 'Miami Stadium'),
(52, 'Vorrunde', 'C', '2026-06-24 22:00:00+00', 'Marokko', 'Haiti', 'Atlanta Stadium'),
(53, 'Vorrunde', 'A', '2026-06-25 01:00:00+00', 'Tschechien', 'Mexiko', 'Mexico City Stadium'),
(54, 'Vorrunde', 'A', '2026-06-25 01:00:00+00', 'Südafrika', 'Südkorea', 'Monterrey Stadium'),
(55, 'Vorrunde', 'E', '2026-06-25 20:00:00+00', 'Curaçao', 'Elfenbeinküste', 'Philadelphia Stadium'),
(56, 'Vorrunde', 'E', '2026-06-25 20:00:00+00', 'Ecuador', 'Deutschland', 'New York New Jersey Stadium'),
(57, 'Vorrunde', 'F', '2026-06-25 23:00:00+00', 'Japan', 'Schweden', 'Dallas Stadium'),
(58, 'Vorrunde', 'F', '2026-06-25 23:00:00+00', 'Tunesien', 'Niederlande', 'Kansas City Stadium'),
(59, 'Vorrunde', 'D', '2026-06-26 02:00:00+00', 'Türkei', 'USA', 'Los Angeles Stadium'),
(60, 'Vorrunde', 'D', '2026-06-26 02:00:00+00', 'Paraguay', 'Australien', 'San Francisco Bay Area Stadium'),
(61, 'Vorrunde', 'I', '2026-06-26 19:00:00+00', 'Norwegen', 'Frankreich', 'Boston Stadium'),
(62, 'Vorrunde', 'I', '2026-06-26 19:00:00+00', 'Senegal', 'Irak', 'Toronto Stadium'),
(63, 'Vorrunde', 'H', '2026-06-27 00:00:00+00', 'Kap Verde', 'Saudi-Arabien', 'Houston Stadium'),
(64, 'Vorrunde', 'H', '2026-06-27 00:00:00+00', 'Uruguay', 'Spanien', 'Guadalajara Stadium'),
(65, 'Vorrunde', 'G', '2026-06-27 03:00:00+00', 'Ägypten', 'Iran', 'Seattle Stadium'),
(66, 'Vorrunde', 'G', '2026-06-27 03:00:00+00', 'Neuseeland', 'Belgien', 'Vancouver Stadium'),
(67, 'Vorrunde', 'L', '2026-06-27 21:00:00+00', 'Panama', 'England', 'New York New Jersey Stadium'),
(68, 'Vorrunde', 'L', '2026-06-27 21:00:00+00', 'Kroatien', 'Ghana', 'Philadelphia Stadium'),
(69, 'Vorrunde', 'K', '2026-06-27 23:30:00+00', 'Kolumbien', 'Portugal', 'Miami Stadium'),
(70, 'Vorrunde', 'K', '2026-06-27 23:30:00+00', 'DR Kongo', 'Usbekistan', 'Atlanta Stadium'),
(71, 'Vorrunde', 'J', '2026-06-28 02:00:00+00', 'Algerien', 'Österreich', 'Kansas City Stadium'),
(72, 'Vorrunde', 'J', '2026-06-28 02:00:00+00', 'Jordanien', 'Argentinien', 'Dallas Stadium');
