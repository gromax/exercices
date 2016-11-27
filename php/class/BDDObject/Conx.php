<?php

namespace BDDObject;
use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

class Conx extends Item
{
	static protected $myName = "connexion_history";
	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		// Date de création
		// identifiant utilisé
		// mot de passe utilisé
		// connexion réussie
		return array("date"=>"dateHeure", "identifiant"=>"string", "pwd"=>"string", "success"=>"boolean");
	}

	protected static function defValues()
	{
		return array("date"=>date('Y-m-d H:i:s'), "identifiant"=>"", "pwd"=>"", "success"=>false);
	}

	public static function getList($params= array())
	{
		require_once BDD_CONFIG;
		try {
			$bdd_result=DB::query("SELECT id, date, identifiant, pwd, success FROM ".PREFIX_BDD."connexion_history ORDER BY date DESC");
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "Conx/getList");
			return array();
		}
		return $bdd_result;
	}

	public static function purge()
	{
		require_once BDD_CONFIG;
		try {
			DB::delete(PREFIX_BDD.static::$myName,"1=%i",1);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "Conx/purge");
			return false;
		}
		return true;
	}

	##################################### METHODES     #####################################

	protected function reformat()
	{
		// Si c'est un succès, on ne garde pas de copie de pwd
		if ($this->values["success"]) $this->values["pwd"] = "";
	}

}
?>
