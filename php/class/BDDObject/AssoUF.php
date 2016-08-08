<?php

namespace BDDObject;

use DB;
use SessionController as SC;
use ErrorController as EC;
use MeekroDBException;


final class AssoUF
{
	const SAVE_IN_SESSION = true;

	private static $_liste = null;

	// Pour un exercice associé à une fiche
	private $id = null;			// id de l'assoc dans la bdd
	private $idFiche = null;	// id de la fiche
	private $idUser = null;		// id de l'utilisateur
	private $actif = true;		// actif par défaut
	private $date = null;		// date de création

	##################################### METHODES STATIQUES #####################################

	public function __construct($params=array())
	{
		if(isset($params['id'])) $this->id = (integer) $params['id'];
		if(isset($params['idFiche'])) $this->idFiche = (integer) $params['idFiche'];
		if(isset($params['idUser'])) $this->idUser = (integer) $params['idUser'];
		if(isset($params['actif'])) $this->actif = (boolean) $params['actif'];
		if(isset($params['date'])) $this->date=$params['date'];
		else $this->date=date('Y-m-d');	}

	public static function get($id,$returnObject=false)
	{
		if ($id === null) return null;

		if (self::SAVE_IN_SESSION) {
			// On essaie de récupérer l'objet en session
			$aUF = SC::get()->getParamInCollection('aUFs', $id, null);
			if ($aUF !== null){
				if ($returnObject) return $aUF;
				else return $aUF->toArray();
			}
		}

		require_once BDD_CONFIG;
		try {
			$bdd_result=DB::queryFirstRow("SELECT id, idUser, idFiche FROM ".PREFIX_BDD."assocUF WHERE id=%s", $id);
			if ($bdd_result === null) {
				EC::addError("Association Utilisateur-Fiche introuvable.");
				return null;
			}
			if ($returnObject || self::SAVE_IN_SESSION) {
				$aUF = new AssoUF($bdd_result);
				if (self::SAVE_IN_SESSION) SC::get()->setParamInCollection('aUFs', $aUF->getId(), $aUF);
				if ($returnObject) return $aUF;
				else return $aUF->toArray();
			}
			return $bdd_result;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'assoUF/get');
			return null;
		}
	}

	public static function getList($params)
	{
		if (isset($params["idUser"])) $idUser = (integer) $params["idUser"];
		else $idUser = null;
		if (isset($params["idFiche"])) $idFiche = (integer) $params["idFiche"];
		else $idFiche = null;
		require_once BDD_CONFIG;
		try {
			if ($idUser!==null) {
				if ($idFiche!==null) {
					$bdd_result=DB::query("SELECT id, idUser, idFiche, actif, date FROM ".PREFIX_BDD."assocUF WHERE idUser=%i AND idFiche=%i ORDER BY date",$idUser, $idFiche);
				} else {
					$bdd_result=DB::query("SELECT id, idUser, idFiche, actif, date FROM ".PREFIX_BDD."assocUF WHERE idUser=%i ORDER BY date",$idUser);
				}
			} elseif ($idFiche!==null) {
				$bdd_result=DB::query("SELECT id, idUser, idFiche, actif, date FROM ".PREFIX_BDD."assocUF WHERE idFiche=%i ORDER BY date",$idFiche);
			} else {
				$bdd_result=DB::query("SELECT id, idUser, idFiche, actif, date FROM ".PREFIX_BDD."assocUF ORDER BY date");
			}
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "AssoUF/getList");
			return array();
		}
		return $bdd_result;
	}

	public static function getObject($id)
	{
		return self::get($id,true);
	}

	##################################### METHODES #####################################

	public function getId()
	{
		return $this->id;
	}

	public function getIdFiche()
	{
		return $this->idFiche;
	}

	public function getIdUser()
	{
		return $this->idUser;
	}

	public function getUser()
	{
		return User::getObject($this->idUser);
	}

	public function getFiche()
	{
		return Fiche::getObject($this->idFiche);
	}

	public function insertion()
	{
		require_once BDD_CONFIG;
		try {
			DB::insert(PREFIX_BDD.'assocUF', $this->toArray());
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'AssoUF/insertion');
			return null;
		}

		$this->id = DB::insertId();

		EC::add("Association Utilisateur-Fiche créée avec succès");

		return $this->id;
	}

	public function delete()
	{
		require_once BDD_CONFIG;
		try {
			// Suppression des notes liées à l'association
			DB::delete(PREFIX_BDD.'assocUE', 'aUF=%i', $this->id);
			// Suppression de l'association
			DB::delete(PREFIX_BDD.'assocUF', 'id=%i', $this->id);
			EC::add("L'exercice a bien été supprimé.");
			if (self::SAVE_IN_SESSION) $session=SC::get()->unsetParamInCollection('aUFs', $this->id);
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "AssoUF/Suppression");
		}
		return false;
	}

	public function update($params=array(),$updateBDD=true)
	{
		$modifs = array();

		if(isset($params['actif'])) {
			$this->actif = (boolean) $params['actif'];
			$modifs['actif']=$this->actif;
		}

		if (count($modifs)===0) {
			EC::add("Aucune modification.");
			return true;
		}

		if (!$updateBDD) return true;

		if ($this->id === null) {
			EC::addError("L'association Utilisateur-Fiche n'existe pas en BDD.");
			return false;
		}

		require_once BDD_CONFIG;
		try{
			DB::update(PREFIX_BDD.'assocUF', $modifs,"id=%i",$this->id);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), 'AssoUF/update');
			return false;
		}
		EC::add("La modification a bien été effectuée.");
		return true;
	}

	public function toArray()
	{
		return array(
			'id'=>$this->id,
			'idUser'=>$this->idUser,
			'idFiche'=>$this->idFiche,
			'actif'=>$this->actif,
			'date'=>$this->date
			);
	}

	public function isOwnedBy($user)
	{
		$fiche = Fiche::getObject($this->idFiche);
		if ($fiche===null) return false;
		return $fiche->isOwnedBy($user);
	}

	public function isMyTeacher($user)
	{
		$assoUser = User::getObject($this->idUser);
		if ($assoUser===null) return false;
		return $assoUser->isMyTeacher($user);
	}

}

?>
