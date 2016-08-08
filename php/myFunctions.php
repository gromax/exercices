<?php
	function send_mail($email,$subject,$texte) {
		$boundary = "-----=".md5(rand());
		//=====Création du header de l'e-mail
		$header = "From: \"".PSEUDO_FROM."\"<".EMAIL_FROM.">\n";
		$header .= "Reply-to: \"".PSEUDO_FROM."\" <".EMAIL_FROM.">\n";
		$header .= "MIME-Version: 1.0\n";
		$header .= "Content-Type: multipart/alternative;\n boundary=\"$boundary\"\n";
		//=====Création du message.au format texte
		$message = "\n--$boundary\n";
		$message.= "Content-Type: text/plain; charset=\"ISO-8859-1\"\n";
		$message.= "Content-Transfer-Encoding: 8bit\n";
		$message.= "\n$texte\n";
		//=====Ajout du message au format HTML
		//$message.= "\n--$boundary\n";
		//$message.= "Content-Type: text/html; charset=\"ISO-8859-1\"".$passage_ligne;
		//$message.= "Content-Transfer-Encoding: 8bit".$passage_ligne;
		//$message.= $passage_ligne.$message_html.$passage_ligne;
		//==========
		$message.= "\n--".$boundary."--\n";
		$message.= "\n--$boundary--\n";
		//=====Envoi de l'e-mail.
		mail($email,$subject,$message,$header);
	}

	function send_html_mail($email,$subject,$texte) {
		$boundary = "-----=".md5(rand());
		//=====Création du header de l'e-mail
		$header = "From: \"".PSEUDO_FROM."\"<".EMAIL_FROM.">\n";
		$header .= "Reply-to: \"".PSEUDO_FROM."\" <".EMAIL_FROM.">\n";
		$header .= "MIME-Version: 1.0\n";
		$header .= "Content-Type: multipart/alternative;\n boundary=\"$boundary\"\n";
		//=====Création du message.au format texte
		//$message = "\n--$boundary\n";
		//$message.= "Content-Type: text/plain; charset=\"ISO-8859-1\"\n";
		//$message.= "Content-Transfer-Encoding: 8bit\n";
		//$message.= "\n$texte\n";
		//=====Ajout du message au format HTML
		$message= "\n--$boundary\n";
		$message.= "Content-Type: text/html; charset=\"ISO-8859-1\"\n";
		$message.= "Content-Transfer-Encoding: 8bit\n";
		$message.= "\n$texte\n";
		//==========
		$message.= "\n--".$boundary."--\n";
		$message.= "\n--$boundary--\n";
		//=====Envoi de l'e-mail.
		mail($email,$subject,$message,$header);
	}

	function autoloadMyClass($className) {
		$className = str_replace('\\', DIRECTORY_SEPARATOR, $className);
		$filename = PATH_TO_CLASS."/". $className . ".php";
		if (is_readable($filename)) {
			require_once $filename;
		}
	}

	spl_autoload_register("autoloadMyClass");


	// Sur le serveur hosteur, la fonction array_column n'existe pas...
	if(!function_exists("array_column"))
	{
		function array_column($array,$column_name)
		{
			return array_map(function($element) use($column_name){return $element[$column_name];}, $array);
		}
	}

	function getPost($key, $defaultValue=null){
		if (isset($_POST[$key])) {
			return $_POST[$key];
		} else {
			return $defaultValue;
		}
	}

	function getGET($key, $defaultValue=null){
		if (isset($_GET[$key])) {
			return $_GET[$key];
		} else {
			return $defaultValue;
		}
	}

	function extractFromPost($list){
		$answer=array();
		foreach ($list as $key => $defaultValue) {
			if (isset($_POST[$key])) $answer[$key]=$_POST[$key];
			elseif ($defaultValue!==null) $answer[$key]=$defaultValue;
		}
		return $answer;
	}

	function excludeKey($key,$liste,$listToExclude){
		// Dans $liste, on enlève toutes les entrées dont la clé $key se trouve dans la liste $listToExclude
		$arrKey=array();
		foreach ($listToExclude as $item) {
			array_push($arrKey,$item[$key]);
		}
		$newListe=array();
		foreach ($liste as $item){
			if (!in_array($item[$key], $arrKey)) array_push($newListe, $item);
		}
		return $newListe;
	}

	function remove_accent($str)
	{
	  $a = array('À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ð',
	                'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß', 'à', 'á', 'â', 'ã',
	                'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ñ', 'ò', 'ó', 'ô', 'õ',
	                'ö', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'ÿ', 'Ā', 'ā', 'Ă', 'ă', 'Ą', 'ą', 'Ć', 'ć', 'Ĉ',
	                'ĉ', 'Ċ', 'ċ', 'Č', 'č', 'Ď', 'ď', 'Đ', 'đ', 'Ē', 'ē', 'Ĕ', 'ĕ', 'Ė', 'ė', 'Ę', 'ę',
	                'Ě', 'ě', 'Ĝ', 'ĝ', 'Ğ', 'ğ', 'Ġ', 'ġ', 'Ģ', 'ģ', 'Ĥ', 'ĥ', 'Ħ', 'ħ', 'Ĩ', 'ĩ', 'Ī', 'ī',
	                'Ĭ', 'ĭ', 'Į', 'į', 'İ', 'ı', 'Ĳ', 'ĳ', 'Ĵ', 'ĵ', 'Ķ', 'ķ', 'Ĺ', 'ĺ', 'Ļ', 'ļ', 'Ľ', 'ľ',
	                'Ŀ', 'ŀ', 'Ł', 'ł', 'Ń', 'ń', 'Ņ', 'ņ', 'Ň', 'ň', 'ŉ', 'Ō', 'ō', 'Ŏ', 'ŏ', 'Ő', 'ő', 'Œ',
	                'œ', 'Ŕ', 'ŕ', 'Ŗ', 'ŗ', 'Ř', 'ř', 'Ś', 'ś', 'Ŝ', 'ŝ', 'Ş', 'ş', 'Š', 'š', 'Ţ', 'ţ', 'Ť',
	                'ť', 'Ŧ', 'ŧ', 'Ũ', 'ũ', 'Ū', 'ū', 'Ŭ', 'ŭ', 'Ů', 'ů', 'Ű', 'ű', 'Ų', 'ų', 'Ŵ', 'ŵ', 'Ŷ',
	                'ŷ', 'Ÿ', 'Ź', 'ź', 'Ż', 'ż', 'Ž', 'ž', 'ſ', 'ƒ', 'Ơ', 'ơ', 'Ư', 'ư', 'Ǎ', 'ǎ', 'Ǐ', 'ǐ',
	                'Ǒ', 'ǒ', 'Ǔ', 'ǔ', 'Ǖ', 'ǖ', 'Ǘ', 'ǘ', 'Ǚ', 'ǚ', 'Ǜ', 'ǜ', 'Ǻ', 'ǻ', 'Ǽ', 'ǽ', 'Ǿ', 'ǿ');

	  $b = array('A', 'A', 'A', 'A', 'A', 'A', 'AE', 'C', 'E', 'E', 'E', 'E', 'I', 'I', 'I', 'I', 'D', 'N', 'O',
	                'O', 'O', 'O', 'O', 'O', 'U', 'U', 'U', 'U', 'Y', 's', 'a', 'a', 'a', 'a', 'a', 'a', 'ae', 'c',
	                'e', 'e', 'e', 'e', 'i', 'i', 'i', 'i', 'n', 'o', 'o', 'o', 'o', 'o', 'o', 'u', 'u', 'u', 'u',
	                'y', 'y', 'A', 'a', 'A', 'a', 'A', 'a', 'C', 'c', 'C', 'c', 'C', 'c', 'C', 'c', 'D', 'd', 'D',
	                'd', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'E', 'e', 'G', 'g', 'G', 'g', 'G', 'g', 'G', 'g',
	                'H', 'h', 'H', 'h', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'I', 'i', 'IJ', 'ij', 'J', 'j', 'K',
	                'k', 'L', 'l', 'L', 'l', 'L', 'l', 'L', 'l', 'L', 'l', 'N', 'n', 'N', 'n', 'N', 'n', 'n', 'O', 'o',
	                'O', 'o', 'O', 'o', 'OE', 'oe', 'R', 'r', 'R', 'r', 'R', 'r', 'S', 's', 'S', 's', 'S', 's', 'S',
	                's', 'T', 't', 'T', 't', 'T', 't', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'W',
	                'w', 'Y', 'y', 'Y', 'Z', 'z', 'Z', 'z', 'Z', 'z', 's', 'f', 'O', 'o', 'U', 'u', 'A', 'a', 'I', 'i',
	                'O', 'o', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'U', 'u', 'A', 'a', 'AE', 'ae', 'O', 'o');
	  return str_replace($a, $b, $str);
	}


	function dateSqlToFr($chaine) {
		$motif='`(\d{2,4})-(\d{1,2})-(\d{1,2})`';
		$afficher='$3/$2/$1';
		return preg_replace($motif,$afficher,$chaine);
	}





?>
