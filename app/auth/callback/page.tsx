'use client';

import { useEffect } from 'react';
import { supabase } from '@/lib/supabaseClient';

export default function AuthCallbackPage() {
  useEffect(() => {
    async function finishLogin() {
      const hash = window.location.hash;

      if (hash) {
        const params = new URLSearchParams(hash.substring(1));
        const access_token = params.get('access_token');
        const refresh_token = params.get('refresh_token');

        if (access_token && refresh_token) {
          await supabase.auth.setSession({
            access_token,
            refresh_token,
          });
        }
      }

      window.location.href = '/meine-tipps';
    }

    finishLogin();
  }, []);

  return <p>Login wird abgeschlossen...</p>;
}