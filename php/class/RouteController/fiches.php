<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Fiche;
use BDDObject\ExoFiche;
use BDDObject\Note;
use BDDObject\Exam;
use BDDObject\AssoUF;
use BDDObject\Logged;

class fiches
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

    public function fetch()
    {
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if ($uLog->isEleve())
        {
            return Fiche::getList(array("eleve"=> $uLog->getId() ));
        }
        if ($uLog->isAdmin())
        {
            return Fiche::getList();
        }
        if ($uLog->isProf())
        {
            return Fiche::getList(array("owner"=> $uLog->getId() ));
        }

        EC::set_error_code(501);
        return false;
    }

    public function fetchFullInfos()
    {
        // Renvoie :
        // - tous les exofiches du devoir (=>exercices)
        // - toutes les notes (=>faits)
        // - toutes les assocs entre le devoir et les utilisateurs (=>eleves)
        //    Remarque : Le devoir appartenant au prof, les assocs tombent donc forcément sur ses élèves
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        $id = (integer) $this->params['id'];
        $fiche=Fiche::getObject($id);
        if ($fiche === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isAdmin() ||
            $uLog->isProf() && $fiche->isOwnedBy($uLog) ||
            $uLog->isEleve() && (count($listeAssoc=AssoUF::getList(array("idFiche"=>$id, "idUser"=>$uLog->getId())))>0))
        {
            if ($uLog->isEleve()) {
                $idUser = $uLog->getId();
                $eleves = $listeAssoc;
                $faits = Note::getList(array(
                    "idUser"=>$idUser,
                    "idFiche"=>$id
                ));
                $exams = null;
            } else {
                $eleves = AssoUF::getList(array("idFiche"=>$id));
                $faits = Note::getList(array("idFiche"=>$id));
                $exams = Exam::getList(array("idFiche"=>$id));
            }
            $exercices = ExoFiche::getList(array("idFiche"=>$id));
            return array(
                "fiche"=>$fiche->toArray(),
                "exercices"=>$exercices,
                "eleves"=>$eleves,
                "faits"=>$faits,
                "exams"=>$exams,
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

    public function delete()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$uLog->isProf(true))
        {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $fiche=Fiche::getObject($id);
        if ($fiche === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isAdmin() || $fiche->isOwnedBy($uLog))
        {
            if ($fiche->delete())
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
        if ($uLog->isEleve()) {
            // Interdit pour élève
            EC::set_error_code(403);
            return false;
        }
        $data = json_decode(file_get_contents("php://input"),true);
        $data["idOwner"] = $uLog->getId();
        $fiche = new Fiche($data);
        $id = $fiche->insertion();
        if ($id!==null)
        {
            return $fiche->toArray();
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
        if ($uLog->isEleve()) {
            // Interdit pour élève
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $fiche=Fiche::getObject($id);
        if ($fiche === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isAdmin() || $fiche->isOwnedBy($uLog))
        {
           $data = json_decode(file_get_contents("php://input"),true);
           $modOk = $fiche->update($data);
           if ($modOk === true)
           {
               return $fiche->toArray();
           }
        }
        else
        {
            // Interdit, pas propriétaire ni admin
            EC::set_error_code(403);
            return false;
        }
        EC::set_error_code(501);
        return false;
    }

}
?>
