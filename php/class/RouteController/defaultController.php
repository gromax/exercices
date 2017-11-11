<?php
namespace RouteController;
use ErrorController as EC;

class defaultController
{
    private $id;
    /**
     * Constructeur
     */
    public function __construct($params)
    {
    }
    /**
     * renvoie une alerte
     * @return string
     */
    public function alert()
    {
        EC::set_error_code(501);
        EC::add("Page par défaut.");
        return false;
    }
}
?>
