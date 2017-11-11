<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\User;
use BDDObject\Logged;

class users
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

    public function fetch()
    {
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        $id = (integer) $this->params['id'];
        $user = User::getObject($id);
        if ($user===null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ( ($uLog->isAdmin() && $uLog->isStronger($user)) || ($uLog->isProf() && $user->isMyTeacher($uLog)) || ($user->getId() === $uLog->getId()) )
        {
            return $user->toArray();
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }
    }

    public function fetchList()
    {
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($uLog->isRoot()) return User::getList(array('ranks'=>array(User::RANK_ADMIN, User::RANK_ELEVE, User::RANK_PROF)));
        if ($uLog->isAdmin()) return User::getList(array('ranks'=>array(User::RANK_ELEVE, User::RANK_PROF)));
        if ($uLog->isProf()) return User::getList(array('classes'=>array_keys( $uLog->ownerOf() )));
        EC::set_error_code(403);
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
        elseif ($uLog->isEleve())
        {
            EC::set_error_code(403);
            return false;
        }
        else
        {
            $id = (integer) $this->params['id'];
            $user=User::getObject($id);
            if ($user === null)
            {
                EC::set_error_code(404);
                return false;
            }
            elseif( ($uLog->isAdmin() && $uLog->isStronger($user)) || $user->isMyTeacher($uLog) )
            {
                if ($user->delete())
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
        if ($uLog->isAdmin()) {
            $data = json_decode(file_get_contents("php://input"),true);
            $userAdd = new User($data);
            if ($userAdd->isEleve())
            {
                // Les élèves doivent s'inscrire eux-mêmes
                EC::set_error_code(403);
                return false;
            }
            elseif (!$uLog->isStronger($userAdd))
            {
                // rang trop élevé
                EC::set_error_code(403);
                return false;
            }
            else
            {
                $validation = $userAdd->insertion_validation();
                if ($validation === true)
                {
                    $id = $userAdd->insertion(true);
                    if ($id!==null)
                        return $userAdd->toArray();
                    else
                    {
                        EC::set_error_code(501);
                        return false;
                    }
                }
                else
                {
                    EC::set_error_code(422);
                    return array('errors'=>$validation);
                }
            }
        }
        else
        {
            // Seuls admin et root peuvent créer des utilisateurs
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
        if ($uLog->getId() == $id){
            // On modifie l'utilisateur connecté
            $userToMod=$uLog;
        }
        elseif ($uLog->isProf(true))
        {
            $userToMod=User::getObject($id);
            if ($userToMod === null)
            {
                EC::set_error_code(404);
                return false;
            }
            elseif( !($uLog->isAdmin() && $uLog->isStronger($userToMod)) && !$userToMod->isMyTeacher($uLog) ) {
                EC::set_error_code(403);
                return false;
            }
        }
        else
        {
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);
        $validation = $userToMod->update_validation($data);
        if ($validation === true)
        {
            $modOk=$userToMod->update($data);
            if ($modOk === true)
            {
                return $userToMod->toArray();
            }
            else
            {
                EC::set_error_code(501);
                return false;
            }
        }
        else
        {
            EC::set_error_code(422);
            return array('errors' => $validation);
        }
    }

    public function forgottenWithEmail()
    {
        $data = json_decode(file_get_contents("php://input"),true);
        if (isset($data['identifiant']))
        {
            $identifiant = $data['identifiant'];
            $id = User::emailExists($identifiant);

            if ($id!==false) {
                return $this->forgotten(User::getObject($id));
            }
            else
            {
                EC::set_error_code(404);
                return false;
            }
        }
    }

    public function forgottenWithId()
    {
        $id = (integer) $this->params['id'];
        $user = User::getObject($id);
        if ($user!==null)
        {
            return $this->forgotten($user);
        }
        else
        {
            EC::set_error_code(404);
            return false;
        }
    }


    private function forgotten($user)
    {
        $key = $user->initKey();
        if ($key!==null)
        {
            $params = $user->toArray();
            send_html_mail($params['email'],"Mot de passe oublié","<b>".NOM_SITE.".</b> Vous avez oublié votre mot de passe. Suivez ce lien pour pour modifier votre mot de passe : <a href='".PATH_TO_SITE."/#reinit:$key'>Réinitialisation du mot de passe</a>.");
            return array("message"=>"Email envoyé.");
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }
    }

}
?>
