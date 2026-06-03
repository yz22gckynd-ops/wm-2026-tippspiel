'use client';

import { useEffect } from 'react';
import { supabase } from '@/lib/supabaseClient';

export default function AuthCallbackPage() {
  useEffect(() => {
    async function finishLogin() {
      await supabase.auth.getSession();
      window.location.href = '/meine-tipps';
    }

    finishLogin();
  }, []);

  return <p>Login wird abgeschlossen...</p>;
}