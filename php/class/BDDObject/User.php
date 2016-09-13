<?php

namespace BDDObject;
use DB;
use MeekroDBException;
use ErrorController as EC;
use SessionController as SC;

class User
{
	const	RANK_ROOT="Root";
	const	RANK_ADMIN="Admin";
	const	RANK_PROF="Prof";
	const	RANK_ELEVE="Élève";
	const	RANK_DISCONNECTED="Off";

	const	SAVE_IN_SESSION = true;

	protected $id=null;
	protected $idClasse = null; // 0 est équivalent à pas de classe
	protected $classe = null;
	protected $pseudo = '';
	protected $rank = self::RANK_DISCONNECTED;
	protected $nom = 'Disconnected';
	protected $prenom ='';
	protected $email ='';
	protected $_cryptedPwd =null;
	protected $date = null;
	protected $locked = false;

	protected $_notes = null;			// Liste des notes, tableau trié par idClasse

	##################################### METHODES STATIQUES #####################################

	public function __construct($options=array())
	{
		if(isset($options['id'])) $this->id = (integer) $options['id'];
		if(isset($options['idClasse'])) $this->idClasse = (integer) $options['idClasse'];
		if(USE_PSEUDO && isset($options['pseudo'])) $this->pseudo = $options['pseudo'];
		if(isset($options['nom'])) $this->nom = $options['nom'];
		if(isset($options['prenom'])) $this->prenom = $options['prenom'];
		if(isset($options['email'])) $this->email = $options['email'];
		if(isset($options['date'])) $this->date = $options['date'];
		else $this->date = date('Y-m-d H:i:s');
		if(isset($options['rank'])) $this->rank = $options['rank'];
		if(isset($options['pwd'])) $this->_cryptedPwd = $options['pwd'];
		if(isset($options['locked'])) $this->locked = (boolean)$options['locked'];
		if (isset($options['userToCopy'])) {
			$modele = $otions['userToCopy'];
			if (USE_PSEUDO) $this->pseudo = $modele->pseudo;
			$this->nom = $modele->nom;
			$this->prenom = $modele->prenom;
			$this->email = $modele->email;
			$this->rank = $modele->rank;
			$this->_cryptedPwd = $modele->_cryptedPwd;
			$this->date = $modele->date;
			$this->locked = $modele->locked;
		}
	}

	public static function getList($params=array())
	{
		// $params['classe'] permet de préciser l'id d'une classe dont on veut les élèves
		// $params['classes'] permet de préciser une liste d'id de classe dont on veut les élèves
		// $params['ranks'] indique les rangs à garder sous forme d'un tableau
		require_once BDD_CONFIG;
		try {
			if (USE_PSEUDO) {
				// on utilise le champ pseudo
				if (isset($params['ranks'])) return DB::query("SELECT u.id, idClasse, c.nom AS nomClasse, pseudo, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE rank IN %ls ORDER BY u.date DESC",$params['ranks']);
				elseif (isset($params['classe'])) return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, pseudo, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE idClasse=%i",$params['classe']);
				elseif (isset($params['classes'])) return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, pseudo, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE idClasse IN %ls",$params['classes']);
				else return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, pseudo, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id)");
			} else {
				// on n'utilise pas le champ pseudo
				if (isset($params['ranks'])) return DB::query("SELECT u.id, idClasse, c.nom AS nomClasse, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE rank IN %ls ORDER BY u.date DESC",$params['ranks']);
				elseif (isset($params['classe'])) return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE idClasse=%i",$params['classe']);
				elseif (isset($params['classes'])) return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id) WHERE idClasse IN %ls",$params['classes']);
				else return DB::query("SELECT u.id, c.nom AS nomClasse, idClasse, u.nom, prenom, email, rank, u.date, u.locked FROM (".PREFIX_BDD."users u LEFT JOIN ".PREFIX_BDD."classes c ON u.idClasse = c.id)");
			}
		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#User/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	public static function search($id,$returnObject=false)
	{
		if (is_numeric($id)) {
			$idUser = (integer) $id;
		} else return null;

		if (self::SAVE_IN_SESSION) {
			$user = SC::get()->getParamInCollection('users', $idUser, null);
			if ($user !== null){
				if ($returnObject) return $user;
				else return $user->toArray();
			}
		}

		// Pas trouvé dans la session, il faut chercher en bdd
		require_once BDD_CONFIG;
		try {
			if (USE_PSEUDO) {
				$bdd_result=DB::queryFirstRow("SELECT id, idClasse, pseudo, nom, prenom, email, rank, date, locked FROM ".PREFIX_BDD."users WHERE id=%s", $idUser);
			} else {
				$bdd_result=DB::queryFirstRow("SELECT id, idClasse, nom, prenom, email, rank, date, locked FROM ".PREFIX_BDD."users WHERE id=%s", $idUser);
			}
			if ($bdd_result === null) return null;

			if ($returnObject || self::SAVE_IN_SESSION) {
				$user = new User($bdd_result);
				if (self::SAVE_IN_SESSION) {
					SC::get()->setParamInCollection('users', $user->getId(), $user);
				}
				if ($returnObject) return $user;
			}

			return $bdd_result;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(),"User/Search");
		}
		return null;
	}

	public static function getObject($id)
	{
		// alias pour search avec retour sous forme d'objet
		return self::search($id, true);
	}

	public static function checkPseudo($pseudo)
	{
		return (is_string($pseudo) && (strlen($pseudo)>=PSEUDO_MIN_SIZE) && (strlen($pseudo)<=PSEUDO_MAX_SIZE));
	}

	public static function checkPwd($pwd)
	{
		return true;
	}

	public static function checkEMail($email)
	{
		return preg_match("#^[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9._-]{2,}\.[a-z]{2,4}$#", $email);
	}


	public static function identifiantExists($identifiant)
	{
		// On a choisi un identifiant unique : email ou pseudo, selon la valeur de USE_PSEUDO
		require_once BDD_CONFIG;
		try {
			// Vérification que l'identifiant
			if (USE_PSEUDO) $results = DB::query("SELECT id FROM ".PREFIX_BDD."users WHERE pseudo=%s",$identifiant);
			else $results = DB::query("SELECT id FROM ".PREFIX_BDD."users WHERE email=%s",$identifiant);
			if (DB::count()>0) return $results[0]["id"];
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
		}
		return false;
	}

	public static function initKey($id)
	{
		$key = md5(rand());
		try {
			DB::insert(PREFIX_BDD.'initKeys', array("initKey"=>$key, "idUser"=>$id));
			return $key;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
		}
		return null;
	}

	##################################### METHODES #####################################

	public function __toString()
	{
		return $this->nom;
	}

	public function identifiant()
	{
		if (USE_PSEUDO) return $this->pseudo;
		else return $this->email;
	}

	public function getName()
	{
		return $this->nom;
	}

	public function cryptedPwd()
	{
		return $this->_cryptedPwd;
	}

	public function isRoot ()
	{
		return ( $this->rank == self::RANK_ROOT );
	}

	public function isAdmin ()
	{
		return (( $this->rank == self::RANK_ROOT ) || ( $this->rank == self::RANK_ADMIN ));
	}

	public function isProf ($orBetter = false)
	{
		return ( ($this->rank == self::RANK_PROF ) || ($orBetter && ( ($this->rank == self::RANK_ROOT ) || ($this->rank == self::RANK_ADMIN ) ) ) );
	}

	public function isEleve ()
	{
		return ( $this->rank == self::RANK_ELEVE );
	}

	public function isStronger(User $user)
	{
		if ($user->isRoot()) return false;
		if ($user->isAdmin()) return $this->isRoot();
		if ($user->isProf()) return $this->isAdmin();
		return $this->isProf(true);
	}

	public function delete()
	{
		if ($this->isRoot()) {
			EC::add("Le compte root ne peut être supprimé.");
			return false;
		}
		if ($this->isProf(true)) {
			// Le compte ne doit pas posséder de classe
			$liste = Classe::getList(array("ownerIs"=>$this->id));
			if (count($liste)>0) {
				EC::addError("Vous devez d'abord supprimer toutes les classes de cet utilisateur.", "Classe/Suppression");
				return false;
			}
		}

		require_once BDD_CONFIG;
		if ($this->isEleve()) {
			try {
				// Suppression de toutes les notes liées
				DB::delete(PREFIX_BDD.'assocUE', 'idUser=%i', $this->id);
				// Suppression de tous les devoirs liés
				DB::delete(PREFIX_BDD.'assocUF', 'idUser=%i', $this->id);
			} catch(MeekroDBException $e) {
				EC::addBDDError($e->getMessage(), "User/Suppression");
			}
		}
		try {
			DB::delete(PREFIX_BDD.'users', 'id=%i', $this->id);
			EC::add("L'utilisateur a bien été supprimée.");
			if (self::SAVE_IN_SESSION) $session=SC::get()->unsetParamInCollection('users', $this->id);
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "User/Suppression");
		}
		return false;
	}

	public function insertion($force = false)
	{
		// $force permet de passer les tests
		if (!$force) {
			if ((USE_PSEUDO) && (!self::checkPseudo($this->pseudo))) {
				EC::addError("Pseudo invalide.");
				return null;
			}

			if (!self::checkEMail($this->email)) {
				EC::addError("EMail invalide.");
				return null;
			}
		}
		require_once BDD_CONFIG;
		try {
			// Vérification que l'identifiant n'existe pas déjà
			if ((USE_PSEUDO) && (!$force) && (self::identifiantExists($this->identifiant()!==false ))) {
				EC::addError("L'identifiant existe déjà.");
				return null;
			}
			DB::insert(PREFIX_BDD.'users', $this->toArray(false));
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
			return null;
		}

		$this->id=DB::insertId();
		EC::add($this->prenom." ".$this->nom." a bien été ajouté.");
		return $this->id;
	}

	public function update($params=array(),$updateBDD=true)
	{
		$bddModif=false;
		if ($this->id===null) {
			EC::addDebugError('Id manquant.');
			return false;
		}
		if (isset($params['email'])&&($params['email']!==$this->email)) {
			if (!self::checkEMail($params['email'])) {
				EC::addError("EMail invalide.");
				return false;
			}
			if ((!USE_PSEUDO)&&(self::identifiantExists($params['email'])!==false)) {
				EC::addError("L'EMail existe déjà.");
				return false;
			}
			if ($this->isRoot()&&(!USE_PSEUDO)) {
				EC::addError("L'EMail du root ne peut être changé.");
				return false;
			}
		}

		if (isset($params['pseudo'])&&($params['pseudo']!==$this->pseudo)){
			if (!self::checkPseudo($params['pseudo'])) {
				EC::addError("Pseudo invalide.");
				return false;
			}
			if (USE_PSEUDO && (self::identifiantExists($params['pseudo'])!==false)) {
				EC::addError("Le pseudo existe déjà.");
				return false;
			}
			if ($this->isRoot()) {
				EC::addError("Le pseudo du root ne peut être changé.");
				return false;
			}
		}

		if(isset($params['locked'])) { $this->locked = (boolean) $params['locked']; $bddModif=true; }
		if (!$this->locked) {
			# locked empêche la modification du nom et du prénom
			if(isset($params['nom'])) { $this->nom = $params['nom']; $bddModif=true; }
			if(isset($params['prenom'])) { $this->prenom = $params['prenom']; $bddModif=true; }
			if(isset($params['pseudo']) && ($params['pseudo']!==$this->pseudo)&&USE_PSEUDO) {
				$this->pseudo = $params['pseudo'];
				$bddModif=true;
			}
		}
		if(isset($params['rank'])) { $this->rank = $params['rank']; $bddModif=true; }
		if(isset($params['email'])) { $this->email = $params['email']; $bddModif=true; }
		if(isset($params['pwd'])) { $this->_cryptedPwd = $params['pwd']; $bddModif=true; }


		if (!$bddModif) {
			EC::add("Aucune modification.");
			return true;
		}
		if (!$updateBDD) {
			EC::add("La modification a bien été effectuée.");
			return true;
		}
		require_once BDD_CONFIG;
		try{
			DB::update(PREFIX_BDD.'users', $this->toArray(false),"id=%i",$this->id);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'User/update');
			return false;
		}
		EC::add("La modification a bien été effectuée.");
		return true;
	}

	public function updateTime()
	{
		$this->date = date('Y-m-d H:i:s');
		require_once BDD_CONFIG;
		try{
			DB::update(PREFIX_BDD.'users', array("date"=>$this->date),"id=%i",$this->id);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'User/updateTime');
		}
		return $this;
	}

	public function isSameAs($key)
	{
		return ( ($this->id ===$key) ||
			(USE_PSEUDO && ($this->pseudo === $key)) ||
			(!USE_PSEUDO && ($this->email === $key)));
	}

	public function toArray($notForBDDUpdate = true)
	{
		$answer=array('nom'=>$this->nom, 'prenom'=>$this->prenom, 'email'=>$this->email, 'rank'=>$this->rank, 'date'=>$this->date, 'locked'=>$this->locked);
		if (USE_PSEUDO) $answer['pseudo'] = $this->pseudo;
		if ($this->_cryptedPwd !== null) $answer['pwd']=$this->_cryptedPwd;
		if ($this->id !== null) $answer['id']=$this->id;
		if ($this->idClasse !== null) $answer['idClasse'] = $this->idClasse;
		if ($notForBDDUpdate) {
			$classe = $this->getClasse();
			if ($classe !== null) $answer['nomClasse'] = $classe->getNom();
		}
		return $answer;
	}

	public function fichesAssoc()
	{
		if ($this->isEleve()) {
			require_once BDD_CONFIG;
			try{
				return DB::query("SELECT id,idFiche, actif, date FROM ".PREFIX_BDD."assocUF WHERE idUser=%i ORDER BY idFiche",$this->id);
			} catch(MeekroDBException $e) {
				EC::addBDDError($e->getMessage(), "User/assocUF");
				return array();
			}
		}
		return array();
	}

	public function getId()
	{
		return $this->id;
	}

	public function getClasseId()
	{
		return $this->idClasse;
	}

	public function getClasse()
	{
		// alias de classe
		if ($this->isEleve()) return Classe::getObject($this->idClasse);
		else return null;
	}

	public function isMyTeacher(User $account)
	{
		if (!$this->isEleve()) return false; // Pas réussi à mettre les deux tests en un seul
		if (!$account->isProf()) return false;
		$classe = $this->getClasse();
		if (($classe !== null) && $classe->isOwnedBy($account)) return true;
		return false;
	}


	public function classe()
	{
		if ($this->isEleve()) return Classe::getObject($this->idClasse);
		else return null;
	}

	public function notes()
	{
		return UserNotes::getObject($this);
	}

	public function insertNote($params)
	{
		if (($notes = $this->notes()) !== null) $notes->insertion($params);
	}

	public function updateNote($params)
	{
		if (($notes = $this->notes()) !== null) $notes->update($params);
	}

	public function isMemberOf($idClasse){
		if (is_numeric($idClasse)) $idClasse = (integer) $idClasse;
		// test si l'utilisateur est membre d'une classe
		return ($idClasse === $this->idClasse);
	}

}


?>
