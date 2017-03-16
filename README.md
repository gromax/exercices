exercices
==
Installation (Ubuntu)
-

* Télécharger la base de données
* Modifier le fichier de config
* Si ce n'est déjà fait, installer "sudo apt-get install nodejs-legacy npm" si ce n'est déjà fait. "node -v" et "npm -v" pour vérifier le bon fonctionnement
* Si ce n'est déjà fait, installer Bower : "npm install –g bower" et "bower -h" pour vérifier
* "bower install" pour installer les dépendances indiquées dans bower.json
* "npm install" pour installer les dépendances indiquées dans package.json
* compiler avec "grunt coffee" et "grunt handlebars"

Documentation
==
Fonction tex des objets Number
-
On peut transmettre un objet d'options.
* symbolsUp : Dans le cas d'un monome, par exemple si on a 2xy/3. Si symbolsUp=true, alors on aura \frac{2xy}{3} sinon ce sera \frac{2}{3}xy
* floatNumber : Dans RadicalNumber et RationalNumber, si true, provoque le calcul approximatif et l'affichage en tant que nombre décimal.
