<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Note;
use BDDObject\ExoFiche;
use BDDObject\AssoUF;
use BDDObject\User;
use BDDObject\Logged;

class notes
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

    public function fetchUserNotes()
    {
        $uLog =Logged::getConnectedUser();
        // Attention, dans ce cas il s'agit de l'id du User !
        $id = (integer) $this->params['id'];
        // Dans ce cas la connexion est impérative
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        $user = User::getObject($id);
        if ($user===null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isAdmin() || $user->isMyTeacher($uLog))
        {
            $exosFiches = ExoFiche::getList(array("idUser"=>$id));
            $faits = Note::getList(array("idUser"=>$id));
            $fichesAssoc = $user->fichesAssoc();
            return array(
                'exosfiches' => $exosFiches,
                'faits' => $faits,
                'fichesAssoc' => $fichesAssoc
            );
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
        EC::set_error_code(501);
        return false;
    }

    /*public function fetchListUserNotes()
    {
        // Ne sert pas !!!!
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
        if (isset($_GET['liste']))
        {
            $strListe = $_GET_['liste'];
        }
        else
        {
            $strListe="";
        }
        $arrListe = explode(";",getGET("strListe"));
        $idUs = array();
        foreach ($arrListe as $idUser) {
            $user = User::getObject($idUser);
            if ($user===null) {
                EC::addError("Élève ($idUser) introuvable.");
            } elseif (!$user->isEleve()) {
                EC::addError("L'utilisateur ($idUser)'est pas un élève.");
            } elseif ($uLog->isAdmin() || $user->isMyTeacher($uLog)) {
                $idUs[] = (integer) $idU;
            } else {
                EC::addError("Vous n'êtes pas autorisé à voir les notes de ($idUser).");
            }
        }
        if (count($idUs)>0)
        {
            return Note::getList(array("usersList"=>$idUs));
        }
        else
        {
            return array();
        }
    }*/

    public function delete()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        $id = (integer) $this->params['id'];
        $note=Note::getObject($id);
        if ($note === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isProf(true) && $note->writeAllowed($uLog))
        {
            if ($note->delete())
            {
                return array( "message" => "Model successfully destroyed!");
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

    public function insert()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);
        $aEF = (integer) $data['aEF'];
        $aUF = (integer) $data['aUF'];
        $exoFiche = ExoFiche::getObject($aEF);

        // Recherche des items parents
        if (($exoFiche === null) || (($fiche = $exoFiche->getFiche()) === null) || (($oUF = AssoUF::getObject($aUF)) === null))
        {
            EC::set_error_code(404);
            return false;
        }

        // Vérification de la cohérence
        if ( $oUF->getIdFiche() !== $fiche->getId() )
        {
            // Situation incohérente
            EC::set_error_code(501);
            return false;
        }

        // Vérification des autorisations
        if (
            ($uLog->isAdmin()) ||
            ($uLog->isProf() && $fiche->isOwnedBy($uLog)) ||
            ( $uLog->isEleve() && ($oUF->getIdUser()==$uLog->getId()) )
        )
        {
            $data['idUser'] = $uLog->getId();
            $note = new Note($data);
            $id = $note->insertion();
            if ($id!==null)
            {
                return $note->toArray();
            }
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
        // Si on en arrive là, erreur
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
        $note=Note::getObject($id);
        if ($note === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($note->writeAllowed($uLog))
        {
            $data = json_decode(file_get_contents("php://input"),true);
            if ($note->update($data))
            {
                return $note->toArray();
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
