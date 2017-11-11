<?php
use ErrorController as EC;

// Pour le dev
// Afficher les erreurs à l'écran
ini_set('display_errors', 1);
// Enregistrer les erreurs dans un fichier de log
ini_set('log_errors', 1);
// Nom du fichier qui enregistre les logs (attention aux droits à l'écriture)
ini_set('error_log', dirname(__file__) . '/log_error_php.txt');
// Afficher les erreurs et les avertissements
error_reporting(E_ALL);

require_once "./php/myFunctions.php";
require_once "./php/constantes.php";
require "./php/class/Router.php";

$router = Router::getInstance();

// session
$router->addRule('api/session', 'session', 'fetch', 'GET'); // Session active
$router->addRule('api/session', 'session', 'insert', 'POST'); // Tentative de connexion
$router->addRule('api/session/:id', 'session', 'delete', 'DELETE'); // Déconnexion
$router->addRule('api/session/test', 'session', 'logged', 'GET'); // Vérifie l'état de connexion
$router->addRule('api/session/keylog', 'session', 'reinitMDP', 'POST'); // Essaie de se connecter avec une clé de réinit
$router->addRule('api/session/initpwd', 'users', 'forgottenWithEmail', 'POST'); // Demande d'envoyer un mail

// users
$router->addRule('api/users/:id', 'users', 'fetch', 'GET');
$router->addRule('api/users', 'users', 'fetchList', 'GET');
$router->addRule('api/users/:id', 'users', 'delete', 'DELETE');
$router->addRule('api/users/:id', 'users', 'update', 'PUT');
$router->addRule('api/users', 'users', 'insert', 'POST');
$router->addRule('api/users/:id/init', 'users', 'forgottenWithId', 'POST');


// classes
$router->addRule('api/classes/:id', 'classes', 'fetch', 'GET');
$router->addRule('api/classes', 'classes', 'fetch', 'GET');
$router->addRule('api/classes/:id', 'classes', 'delete', 'DELETE');
$router->addRule('api/classes/:id', 'classes', 'update', 'PUT');
$router->addRule('api/classes', 'classes', 'insert', 'POST');
$router->addRule('api/classes/:id/join', 'classes', 'join', 'POST');
$router->addRule('api/classes/:id/test', 'classes', 'testMDP', 'GET');

// fiches
$router->addRule('api/fiches', 'fiches', 'fetch', 'GET');
$router->addRule('api/fiches/:id', 'fiches', 'delete', 'DELETE');
$router->addRule('api/fiches/:id', 'fiches', 'update', 'PUT');
$router->addRule('api/fiches', 'fiches', 'insert', 'POST');
$router->addRule('api/fiches/:id/full', 'fiches', 'fetchFullInfos', 'GET');

// exosfiche
$router->addRule('api/exosfiche/:id', 'exosfiche', 'delete', 'DELETE');
$router->addRule('api/exosfiche/:id', 'exosfiche', 'update', 'PUT');
$router->addRule('api/exosfiche', 'exosfiche', 'insert', 'POST');

// exams
$router->addRule('api/exams/:id', 'exams', 'delete', 'DELETE');
$router->addRule('api/exams/:id', 'exams', 'update', 'PUT');
$router->addRule('api/exams', 'exams', 'insert', 'POST');

// assosUF
$router->addRule('api/assosUF/:id', 'assosUF', 'delete', 'DELETE');
$router->addRule('api/assosUF/:id', 'assosUF', 'update', 'PUT');
$router->addRule('api/assosUF', 'assosUF', 'insert', 'POST');

// notes
$router->addRule('api/notes/:id', 'notes', 'delete', 'DELETE');
$router->addRule('api/notes/:id', 'notes', 'update', 'PUT');
$router->addRule('api/notes', 'notes', 'insert', 'POST');
$router->addRule('api/users/:id/notes', 'notes', 'fetchUserNotes', 'GET');
//$router->addRule('api/notes/liste', 'notes', 'fetchListUserNotes', 'GET'); // abandonné ?

// Connexions
$router->addRule('api/cons', 'cons', 'fetch', 'GET');
$router->addRule('api/cons/:id', 'cons', 'delete', 'DELETE');
$router->addRule('api/cons', 'cons', 'purge', 'DELETE');

$response = $router->load();
if ($response === false) {
	echo json_encode(array("messages"=>EC::messages()));
} else {
	if (isset($response["errors"]) && (count($response["errors"])==0)) {
		unset($response["errors"]);
	}
	echo json_encode($response);
}
EC::header();
?>
