<?php
	define("PATH_TO_MEEKRODB", "./php/meekrodb/db.class.php");
	define("PATH_TO_CLASS", "./php/class");

	// Sel pour les mots de passe
	define("PRE_SALT", "l@;1Az");
	define("POST_SALT", "6G)i*");

	// Chemin du dossier
	define("BDD_CONFIG","./config/bddConfig.php");

	// Utilisateurs
	define("PSEUDO_MIN_SIZE", 6);
	define("PSEUDO_MAX_SIZE", 20);
	define("USE_PSEUDO",false);

	// Classes
	define("NOMCLASSE_MIN_SIZE", 3);
	define("NOMCLASSE_MAX_SIZE", 20);

	// mails
	define("PSEUDO_FROM","Exercices de maths");
	define("EMAIL_FROM","noreply@goupill.fr");
	define("PATH_TO_SITE","exercices.goupill.fr");
	define("NOM_SITE","Exercices de maths sur goupill.fr");

	// Calcul de notes
	//define("POIDS_GEO", 0.8);
	define("N_EXO_SUP", 5); // Nombre d'exercices encore pris en compte au-delà de la quantité à faire

	// debug
	define("DEBUG",true);
	define("DEBUG_TEMPLATES",true);
	define("BDD_DEBUG_ON",true);
	define("SAVE_CLASSES_IN_SESSION",true);




?>
