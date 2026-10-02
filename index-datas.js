document.addEventListener('DOMContentLoaded', function(){
  const actualites = [
    {date:'[Exemple : 01/10/2026]', titre:'[Exemple - Rentrée scolaire]', description:'[Exemple - Informations relatives à la rentrée. Données à titre d exemple uniquement.]'},
    {date:'[Exemple : 15/10/2026]', titre:'[Exemple - Sortie pédagogique]', description:'[Exemple - Annonce à titre indicatif. Données à titre d exemple uniquement.]'},
    {date:'[Exemple : 05/11/2026]', titre:'[Exemple - Activité du collège]', description:'[Exemple - Actualité d exemple, modifiable dans le code.]'}
  ];
  const el = document.getElementById('actus-list');
  if(el){
    el.innerHTML = actualites.map(function(a){
      return '<div style=\"background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.25); border-radius:10px; padding:18px; display:flex; flex-direction:column;\"><div style=\"font-size:.85rem; color:#dbe6f0; margin-bottom:8px;\">' + a.date + '</div><h3 style=\"margin:0 0 8px; color:#fff; font-size:1.05rem;\">' + a.titre + '</h3><p style=\"color:#dbe6f0; margin:0 0 14px; line-height:1.6; flex-grow:1;\">' + a.description + '</p><a href=\"actualites.html\" style=\"color:#fff; text-decoration:none; align-self:flex-start; padding:6px 12px; border:1px solid rgba(255,255,255,.4); border-radius:6px; background:rgba(255,255,255,.1);\">Lire la suite</a></div>';
    }).join('');
  }
  const events = [
    {date:'[Exemple : 08/10/2026]', heure:'[Ex. 14h00]', titre:'[Exemple - Réunion de rentrée]', lieu:'[Exemple - Salle]', description:'[Exemple - Description à titre indicatif.]'},
    {date:'[Exemple : 22/10/2026]', heure:'[Ex. 10h00]', titre:'[Exemple - Sortie pédagogique]', lieu:'[Exemple - Extérieur]', description:'[Exemple - Description à titre indicatif.]'}
  ];
  const ev = document.getElementById('events-list');
  if(ev){
    ev.innerHTML = events.map(function(e){
      return '<div style=\"background:rgba(255,255,255,.1); border:1px solid rgba(255,255,255,.25); border-radius:10px; padding:16px; margin-bottom:12px;\"><div style=\"display:flex; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-bottom:6px;\"><div style=\"color:#fff; font-weight:600;\">' + e.titre + '</div><div style=\"color:#dbe6f0; font-size:.92rem;\">' + e.date + ' • ' + e.heure + '</div></div><div style=\"color:#dbe6f0; font-size:.92rem; margin-bottom:6px;\">Lieu : ' + e.lieu + '</div><p style=\"color:#dbe6f0; margin:0;\">' + e.description + '</p></div>';
    }).join('');
  }
  const infos = [{date:'[Exemple : 01/10/2026]', titre:'[Exemple - Information importante]', texte:'[Exemple - Annonce importante à titre d exemple uniquement.]'}];
  const inf = document.getElementById('infos-list');
  if(inf){
    inf.innerHTML = infos.map(function(i){
      return '<div style=\"background:rgba(255,255,255,.15); border:1px solid rgba(244,168,37,.6); border-radius:10px; padding:16px; margin-top:14px;\"><div style=\"display:flex; justify-content:space-between; flex-wrap:wrap; gap:8px; margin-bottom:8px;\"><div style=\"color:#fff; font-weight:600;\">' + i.titre + '</div><div style=\"color:#dbe6f0; font-size:.9rem;\">' + i.date + '</div></div><p style=\"color:#fff; margin:0; line-height:1.6;\">' + i.texte + '</p></div>';
    }).join('');
  }
  var se=document.getElementById('stat-eleves'); if(se) se.textContent='[Ex.]';
  var sp=document.getElementById('stat-personnels'); if(sp) sp.textContent='[Ex.]';
  var sc=document.getElementById('stat-classes'); if(sc) sc.textContent='[Ex.]';
  var sm=document.getElementById('stat-matieres'); if(sm) sm.textContent='[Ex.]';
});
