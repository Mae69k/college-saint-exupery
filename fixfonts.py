import sys
paths = [
  'index.html','admin.html','connexion.html','connexion-type.html','connexion-profil.html',
  'espace.html','inscription.html','recrutement.html','messagerie.html','espace-documentaire.html',
  'mes-applis.html','changement-mdp.html','style.css'
]
for p in paths:
    try:
        with open(p, encoding='utf-8', errors='ignore') as f:
            t = f.read()
        t = t.replace(\"'Inter'\", 'Arial').replace('\"Inter\"', 'Arial')
        t = t.replace(\"'Fraunces'\", 'Arial').replace('\"Fraunces\"', 'Arial')
        t = t.replace('Inter', 'Arial')
        t = t.replace('Fraunces', 'Arial')
        with open(p, 'w', encoding='utf-8') as f:
            f.write(t)
    except Exception as e:
        pass
print('ok')
