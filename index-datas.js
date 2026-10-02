// Affiche le contenu du site (actualités, événements, informations, chiffres).
// Les données viennent de l'espace d'administration (table Supabase "settings").
// Si aucun contenu n'est publié, les données d'exemple sont utilisées.

document.addEventListener('DOMContentLoaded', function() {

  const contenu = { actualites: [], evenements: [], infos: [], stats: {} };

  const champsStats = { stat_eleves: 'eleves', stat_personnels: 'personnels', stat_classes: 'classes', stat_matieres: 'matieres' };

  function vide(message) {

    return '<p class="portal-empty">' + echapperTexte(message) + '</p>';

  }


  function afficher() {

    const elActus = document.getElementById('actus-list');

    if (elActus) {

      elActus.innerHTML = contenu.actualites.length === 0
        ? vide('Aucune actualité publiée pour le moment.')
        : contenu.actualites.slice(0, 3).map(function(a) {

          return '<div class="portal-item"><div class="date">' + echapperTexte(a.date) + '</div><div class="titre">' + echapperTexte(a.titre) + '</div><p>' + echapperTexte(a.description) + '</p></div>';

        }).join('');

    }

    const elEvents = document.getElementById('events-list');

    if (elEvents) {

      elEvents.innerHTML = contenu.evenements.length === 0
        ? vide('Aucun événement publié pour le moment.')
        : contenu.evenements.slice(0, 3).map(function(e) {

          return '<div class="portal-item"><div class="date">' + echapperTexte(e.date) + ' • ' + echapperTexte(e.heure) + '</div><div class="titre">' + echapperTexte(e.titre) + '</div><p>Lieu : ' + echapperTexte(e.lieu) + '</p></div>';

        }).join('');

    }

    const elInfos = document.getElementById('infos-list');

    if (elInfos) {

      elInfos.innerHTML = contenu.infos.length === 0
        ? ''
        : contenu.infos.map(function(i) {

          return '<div class="portal-item" style="border-color:rgba(244,168,37,.6); background:#fffdf7;"><div class="date">' + echapperTexte(i.date) + '</div><div class="titre">' + echapperTexte(i.titre) + '</div><p>' + echapperTexte(i.texte) + '</p></div>';

        }).join('');

    }

    Object.keys(champsStats).forEach(function(id) {

      const cible = document.getElementById(id);

      if (cible) cible.textContent = contenu.stats[champsStats[id]] ?? '[Ex.]';

    });

  }

  afficher();

  chargerContenu().then(function(charge) {

    contenu.actualites = charge.actualites;

    contenu.evenements = charge.evenements;

    contenu.infos = charge.infos;

    contenu.stats = charge.stats;

    afficher();

  });

});