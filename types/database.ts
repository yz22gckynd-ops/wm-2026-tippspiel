export type Player={id:string;email:string;name:string;is_admin:boolean};
export type Match={id:string;match_number:number;round:string;group_name:string|null;kickoff_time:string;team_a:string;team_b:string;venue:string|null;goals_a:number|null;goals_b:number|null;is_finished:boolean};
export type Tip={id:string;player_id:string;match_id:string;tip_goals_a:number;tip_goals_b:number;updated_at:string};
