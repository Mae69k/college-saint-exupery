// ============================================================
// Garde d'accès pour les pages privées (espace personnel).
// À utiliser APRÈS avoir chargé le SDK Supabase et config.js.
// Usage dans chaque page privée :
//   const user = await requireAuth();
//   if (!user) return; // déjà redirigé vers la connexion
// ============================================================

window.requireAuth = async function () {
  const { data: { user } } = await supabaseClient.auth.getUser();
  if (!user) {
    window.location.href = 'connexion-type.html';
    return null;
  }
  return user;
};
