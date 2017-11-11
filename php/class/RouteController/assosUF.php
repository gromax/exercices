<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Fiche;
use BDDObject\User;
use BDDObject\AssoUF;
use BDDObject\Logged;

class assosUF
{
    /**
     * paramères de la requète
     * @array
     */
    private $params;
    /**
     * Constructeur
     */
    public function __construct($params)
    {
        $this->params = $params;
    }
    /**
     * renvoie les infos sur l'objet d'identifiant id
     * @return array
     */

    public function delete()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if ($uLog->isEleve())
        {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $oUF=AssoUF::getObject($id);
        if ($oUF === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ( $uLog->isAdmin() || $uLog->isProf() && ($oUF->isOwnedBy($uLog) || $oUF->isMyTeacher($uLog)) )
        {
            if ($oUF->delete())
                return array( "message" => "Model successfully destroyed!");
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }

        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if ($uLog->isEleve())
        {
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);
        $idFiche = (integer) $data['idFiche'];
        $idUser = (integer) $data['idUser'];
        if ((($fiche = Fiche::getObject($idFiche))===null) || (($user = User::getObject($idUser))===null))
        {
            EC::set_error_code(404);
            return false;
        }

        if ($uLog->isAdmin() || ($fiche->isOwnedBy($uLog) && $user->isMyTeacher($uLog) ))
        {
            $oUF = new AssoUF($data);
            $id = $oUF->insertion();
            if ($id!==null){
                return $oUF->toArray();
            }
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }

        EC::set_error_code(501);
        return false;
    }

    public function update()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        $id = (integer) $this->params['id'];
        $oUF = AssoUF::getObject($id);
        if ($oUF === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ( $uLog->isAdmin() || $uLog->isProf() && ($oUF->isOwnedBy($uLog) || $oUF->isMyTeacher($uLog)) )
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $modOk = $oUF->update($data);
            if ($modOk === true)
            {
                return $oUF->toArray();
            }
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
        EC::set_error_code(501);
        return false;
    }

}
?>
