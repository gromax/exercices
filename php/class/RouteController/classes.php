<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Classe;
use BDDObject\User;
use BDDObject\Logged;

class classes
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
        if (isset($this->params['id']))
        {
            $id = (integer) $this->params['id'];
            // Dans ce cas la connexion est impérative
            if (!$uLog->connexionOk())
            {
                EC::set_error_code(401);
                return false;
            }
            else
            {
                $classe = Classe::getObject($id);
                if ($classe===null)
                {
                    EC::set_error_code(404);
                    return false;
                }
                elseif ( $uLog->isAdmin() || $classe->isOwnedBy($uLog) )
                {
                    return $classe->toArray();
                }
                else
                {
                    EC::set_error_code(403);
                    return false;
                }
            }
        }
        else
        {
            // Dans ce cas, en l'absence de connexion,
            // il faut renvoyer les classes à rejoindre
            if ($uLog->connexionOk())
            {
                if ($uLog->isAdmin()) return Classe::getList();
                if ($uLog->isProf()) return Classe::getList(array('ownerIs'=> $uLog->getId() ));
                if ($uLog->isEleve()) return Classe::getList(array('forEleve'=> $uLog->getId() ));
            }
            // Liste des classes à rejoindre
            return Classe::getList(array('forJoin'=> true ));
        }
    }

    public function delete()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        elseif ($uLog->isEleve())
        {
            EC::set_error_code(403);
            return false;
        }
        else
        {
            $id = (integer) $this->params['id'];
            $classe=Classe::getObject($id);
            if ($classe === null)
            {
                EC::set_error_code(404);
                return false;
            }
            elseif($uLog->isAdmin() || $classe->isOwnedBy($uLog))
            {
                if ($classe->delete())
                    return array( "message" => "Model successfully destroyed!");
            }
            else
            {
                EC::set_error_code(403);
                return false;
            }
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
            // nterdit pour élève
            EC::set_error_code(403);
            return false;
        }
        $data = json_decode(file_get_contents("php://input"),true);
        $data["owner"] = $uLog;
        $classe = new Classe($data);
        $validation = $classe->insertion_update_validation();
        if($validation === true)
        {
            $id = $classe->insertion();
            if ($id!==null)
            {
                return $classe->toArray();
            }
        }
        else
        {
            EC::set_error_code(422);
            return array('errors'=>$validation);
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
        $classe=Classe::getObject($id);
        if ($classe === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($uLog->isAdmin() || $classe->isOwnedBy($uLog))
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $validation = $classe->insertion_update_validation($data);
            if ($validation===true)
            {
                $modOk = $classe->update($data);
                if ($modOk === true)
                {
                    return $classe->toArray();
                }
            }
            else
            {
                EC::set_error_code(422);
                return array('errors' => $validation);
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

    public function join()
    {
        $idClasse = (integer) $this->params['id'];
        $classe = Classe::getObject($idClasse);
        if ($classe === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if (!$classe->isOpen())
        {
            EC::addError("Classe fermée.");
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);
        if (isset($data["pwdClasse"]))
        {
            $pwdClasse = $data["pwdClasse"];
        }
        else
        {
            $pwdClasse = "";
        }

        if (!$classe->testPwd($pwdClasse))
        {
            EC::addError("Mot de passe invalide.");
            EC::set_error_code(422);
            return false;
        }

        // On procède à l'inscription
        $data['idClasse'] = $idClasse;
        $data['rank'] = User::RANK_ELEVE;
        $user=new User($data);
        $validation = $user->insertion_validation();
        if ($validation === true)
        {
            $id = $user->insertion();
            if ($id!==null)
            {
                return $user->toArray();
            }
        }
        else
        {
            EC::set_error_code(422);
            return array('errors'=>$validation);
        }
        EC::set_error_code(501);
        return false;
    }

    public function testMDP()
    {
        $idClasse = (integer) $this->params['id'];
        $pwd = "";
        if (isset($_GET['pwd']))
        {
            $pwd = $_GET['pwd'];
        }

        $classe = Classe::getObject($idClasse);

        if ($classe === null)
        {
            EC::addError("La classe n'existe pas");
            EC::set_error_code(404);
            return false;
        }
        if (!$classe->testPwd($pwd))
        {
            EC::addError("Mot de passe invalide.");
            EC::set_error_code(422);
            return false;
        }
        return array("message"=>"Mot de passe correct");
    }

}
?>
