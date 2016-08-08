<?php

require_once "./php/myFunctions.php";
require_once "./php/constantes.php";

$a = new Action();
echo json_encode($a->output());

?>
