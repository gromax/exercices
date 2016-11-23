<?php
	include "./php/constantes.php"
?>
	var PRE_SALT = "<?php echo PRE_SALT; ?>";
	var POST_SALT = "<?php echo POST_SALT; ?>";
	var SEND_CRYPTED_PWD = ("<?php echo SEND_CRYPTED_PWD; ?>" == "true")||("<?php echo SEND_CRYPTED_PWD; ?>" == "1");
	var PSEUDO_MIN_SIZE = "<?php echo PSEUDO_MIN_SIZE; ?>";
	var PSEUDO_MAX_SIZE = "<?php echo PSEUDO_MAX_SIZE; ?>";
	var NOMCLASSE_MIN_SIZE = "<?php echo NOMCLASSE_MIN_SIZE; ?>";
	var NOMCLASSE_MAX_SIZE = "<?php echo NOMCLASSE_MAX_SIZE; ?>";
	var USE_PSEUDO = "<?php echo USE_PSEUDO; ?>";
