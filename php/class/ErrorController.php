<?php
	final class ErrorController
	{
		/* Classe statique */

		const BDD_DEBUG = true;
		const DEBUG = true;
		private static $_messages = null;

		##################################### METHODES STATIQUES #####################################

		public static function add($message,  $success = true)
		{
			if (self::$_messages === null) self::$_messages = array();
			self::$_messages[] = array('success'=>$success, 'message'=>$message);
		}

		public static function addError($message)
		{
			self::add($message, false);
		}

		public static function addBDDError($message, $code = null)
		{
			if ($code !== null) $strCode = " (".$code.")"; else $strCode="";
			if (self::BDD_DEBUG) self::add('Erreur BDD'.$strCode.' : '.$message, false);
			else self::add('Erreur BDD', false);
		}

		public static function addDebugError($message, $code = null)
		{
			if ($code !== null) $strCode = " (".$code.")"; else $strCode="";
			if (self::DEBUG) self::add('Erreur '.$strCode.' : '.$message, false);
		}

		public static function messages()
		{
			if (self::$_messages === null) return array();
			else return self::$_messages;
		}


	}


?>
