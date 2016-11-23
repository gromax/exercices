<?php

namespace BDDObject;
use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

abstract class Item
{
	const	SAVE_IN_SESSION = true;
	protected $id = null;
	protected $values = null;
	protected static $myName = "Item";

	##################################### METHODES STATIQUES #####################################

	protected static function keys()
	{
		$arr = array_keys(static::champs());
		array_unshift($arr,"id");
		return $arr;
	}

	protected static function champs()
	{
		return array();
	}

	protected static function defValues()
	{
		return array();
	}

	public function __construct($options=array())
	{
		$arr = static::champs();
		$this->values = static::defValues();
		if (isset($options["id"])) {
			$this->id = (integer) $options["id"];
			$this->values["id"] = $this->id;
		}
		foreach ( $arr as $key => $value) {
			if(isset($options[$key])) {
				switch ($value) {
					case "integer":
						$this->values[$key] = (integer) $options[$key];
						break;
					case "string":
						$this->values[$key] = (string) $options[$key];
						break;
					case "boolean":
						$this->values[$key] = (boolean) $options[$key];
						break;
					case "dateHeure":
						$this->values[$key] = $options[$key];
						break;
					case "date":
						$this->values[$key] = $options[$key];
						break;
					default:
						$this->values[$key] = $options[$key];
				}
			}
		}
		if (method_exists($this,"reformat")) $this->reformat();
	}

	public static function getObject($idInput)
	{
		if (is_numeric($idInput)) {
			$id = (integer) $idInput;
		} else return null;
		if (self::SAVE_IN_SESSION) {
			$item = SC::get()->getParamInCollection(static::$myName, $id, null);
			if ($item !== null){
				return $item;
			}
		}

		// Pas trouvé dans la session, il faut chercher en bdd
		require_once BDD_CONFIG;
		try {
			$bdd_result=DB::queryFirstRow("SELECT ".join(self::keys(),",")." FROM ".PREFIX_BDD.static::$myName." WHERE id=%i", $id);
			if ($bdd_result === null) return null;

			$item = new static($bdd_result);
			if (self::SAVE_IN_SESSION) {
				SC::get()->setParamInCollection(static::$myName, $item->id, $item);
			}
			return $item;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(),static::$myName."/getObject");
		}
		return null;
	}

	##################################### METHODES #####################################

	public function __toString()
	{
		if ($this->id!==null) {
			return static::$myName."@".$this->id;
		} else {
			return static::$myName."@?";
		}
	}

	public function delete()
	{
		if ((method_exists($this, "okToDelete"))&&(!$this->okToDelete())) {
			return false;
		}

		require_once BDD_CONFIG;
		if (method_exists($this, "customDelete")) {
			$this->customDelete();
		}
		try {
			// Suppression des assoc liées
			if (method_exists(get_called_class(),"getAssocs")) {
				$arr = static::getAssocs();
				foreach ($arr as $table => $col) {
					DB::delete(PREFIX_BDD.$table, '%s=%i', $col, $this->id);
				}
			}
			DB::delete(PREFIX_BDD.static::$myName, 'id=%i', $this->id);
			EC::add("L'item a bien été supprimée.");
			if (static::SAVE_IN_SESSION) $session=SC::get()->unsetParamInCollection(static::$myName, $this->id);
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), static::$myName."/delete");
		}
		return false;
	}

	public function insertion($force = false)
	{
		// $force permet de passer les tests
		if ((!$force)&&(method_exists($this, "okToInsert"))&&(!$this->okToInsert())) {
			return null;
		}
		require_once BDD_CONFIG;
		try {
			DB::insert(PREFIX_BDD.static::$myName, $this->toArray());
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
			return null;
		}

		$this->id=DB::insertId();
		$this->values["id"] = $this->id;
		EC::add($this." a bien été ajouté.");
		return $this->id;
	}

	public function update($params=array(),$updateBDD=true)
	{
		if ($this->id===false) {
			EC::addDebugError(static::$myName."/update : Id manquant.");
			return false;
		}
		$bddModif=(method_exists($this,"okToUpdate") && ($this->okToUpdate($params)));

		if (!$bddModif) {
			EC::add(static::$myName."/update : Aucune modification.");
			return false;
		}
		if (!$updateBDD) {
			EC::add(static::$myName."/update : Succès.");
			return true;
		}
		require_once BDD_CONFIG;
		try{
			DB::update(PREFIX_BDD.static::$myName, $this->toArray(),"id=%i",$this->id);
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), static::$myName."/update");
			return false;
		}
		EC::add(static::$myName."/update : Succès.");
		return true;
	}

	public function isSameAs($id)
	{
		return ($this->id ===$id);
	}

	public function getId()
	{
		return $this->id;
	}

	public function toArray()
	{
		return $this->values;
	}
}
?>
