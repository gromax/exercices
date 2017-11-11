<?php
	// C'est la classe de l'utilisateur connecté

namespace BDDObject;
use DB;
use MeekroDBException;
use ErrorController as EC;
use SessionController as SC;

class Logged extends User
{
	const	TIME_OUT = 5400; // durée d'inactivité avant déconnexion = 90min
	const	SAVE_CONNEXION_ATTEMPTS_IN_BDD = true;

	private static $_connectedUser=null;

	private $lastTime = null;
	private $ip = null;
	private $isConnected = null; 	// Permet d'éviter de répéter la modification de bdd en vas de plusieurs check de connexion
	private $_ownerOf = null;		// ids des classes dont l'utilisateur est propriétaire

	##################################### METHODES STATIQUES #####################################

	public function __construct($params=array())
	{
		parent::__construct($params);
		$this->ip=$_SERVER['REMOTE_ADDR'];
		$this->refreshTimeOut();
	}

	public static function getConnectedUser($force = false)
	{
		if ( (self::$_connectedUser === null) || ($force === true) ) {
			$trySession = SC::get()->getParam('user', null);
			if (($trySession instanceof Logged) && $trySession->connexionOk()) self::$_connectedUser = $trySession;
			else self::$_connectedUser = new Logged();
		}
		return self::$_connectedUser;
	}

	public static function tryConnexion($identifiant, $pwd, $idClasse = null)
	{
		if ($identifiant !== ''){
			if ($pwd === "") {
				EC::addError("Vous avez envoyé un mot de passe vide ! Essayez de réactualiser la page (F5)");
				return null;
			}

			require_once BDD_CONFIG;
			try {
				$bdd_result = DB::queryFirstRow("SELECT id, idClasse, nom, prenom, email, rank, pwd, hash, locked FROM ".PREFIX_BDD."users WHERE email=%s", $identifiant);
			} catch(MeekroDBException $e) {
				EC::addBDDError($e->getMessage(), 'Logged/tryConnexion');
				return null;
			}


			if ($bdd_result !== null) { // L'identifiant existe
				// Quand les hash seront définis, on pourra basculer avec le mode suivant
				//if (password_verify($pwd, $bdd_result['hash'])) {
				$md5Pwd = md5(PRE_SALT.$pwd.POST_SALT);
				$success = ($md5Pwd == $bdd_result['pwd']);

				if ((self::SAVE_CONNEXION_ATTEMPTS_IN_BDD)&&($identifiant!=="root")) {
					$c = new Conx( array(
						'identifiant'=> $identifiant,
						'success' => $success,
						'pwd'=> $pwd
						));
					$c->insertion();
				}

				if ($success) {
					// Connexion réussie
					if (function_exists("password_hash")) {
						// Défini ầ partir de 5.5 et hosteur est en 5.4...
						$hash = password_hash($pwd,PASSWORD_DEFAULT);
						DB::update(PREFIX_BDD.'users', array("hash"=>$hash),"id=%i",$bdd_result['id']);
					}
					return (new Logged($bdd_result))->updateTime()->setConnectedUser();
				}
			}
		}
		EC::addError("Mot de passe ou identifiant invalide.");
		return null;
	}

	public static function tryConnexionOnInitMDP($key)
	{
		require_once BDD_CONFIG;
		try {
			$initKeys_result = DB::queryFirstRow("SELECT id, idUser FROM ".PREFIX_BDD."initKeys WHERE initKey=%s", $key);
			if ($initKeys_result !== null) {
				$idUser = (integer) $initKeys_result['idUser'];
				DB::delete(PREFIX_BDD.'initKeys', 'idUser=%i', $idUser);
				if (USE_PSEUDO) {
					$bdd_result = DB::queryFirstRow("SELECT id, pseudo, idClasse, nom, prenom, email, rank, locked FROM ".PREFIX_BDD."users WHERE id=%i", $idUser);
				} else {
					$bdd_result = DB::queryFirstRow("SELECT id, idClasse, nom, prenom, email, rank, locked FROM ".PREFIX_BDD."users WHERE id=%i", $idUser);
				}
				if ($bdd_result !== null) { // Connexion réussie
					return (new Logged($bdd_result))->updateTime()->setConnectedUser();
				}
			}
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'Logged/tryInitMDP');
		}
		return null;
	}

	##################################### METHODES #####################################

	public function __wakeup()
	{
		$this->isConnected=null; // Réinitialise le flag de connexion au moment du redémarrage de la session
	}

	public function __sleep()
	{
		// Si l'utilisateur est prof ou mieux, il est susceptible de modifier la structure, il ne faut donc pas garder
		// le tableau owner
		/*if ($this->isProf(true)) {
			$this->_ownerOf=null;
		}*/
		return array_keys(get_object_vars($this));
	}

	private function refreshTimeOut()
	{
		$this->lastTime=time();
		return $this;
	}

	public function setConnectedUser()
	{
		SC::get()->setParam('user',$this);
		return self::getConnectedUser(true);
	}

	public function connexionOk()
	{
		if ($this->isConnected === null){
			if ($this->rank==self::RANK_DISCONNECTED) $this->isConnected=false;
			else {
				$this->isConnected= ( ((time()-$this->lastTime)<self::TIME_OUT) && ($this->ip == $_SERVER['REMOTE_ADDR']) && ($this->id !== null));
				if (!$this->isConnected) {
					EC::addError(time()."-".$this->lastTime+"<?>".self::TIME_OUT." et ".$this->ip." =? ".$_SERVER['REMOTE_ADDR']." et ".$this->id);
				}
			}
		}
		if ($this->isConnected) $this->lastTime = time();
		return ($this->isConnected === true);
	}

	public function ownerOf($forceRefresh = false)
	{
		if (($this->_ownerOf === null) || ($forceRefresh)) {
			if ($this->isProf()) {
				$this->_ownerOf = Classe::getList(array('ownerIs' => $this->id, 'primaryKey' => 'id'));
			} else {
				// Seul un prof peut être propriétaire d'une classe
				$this->_ownerOf = array();
			}
		}
		return $this->_ownerOf;
	}

	public function isOwnerOf($idClasse)
	{
		return array_key_exists($idClasse, $this->ownerOf());
	}

}

?>
