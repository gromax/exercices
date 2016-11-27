<?php

use ErrorController as EC;
use SessionController as SC;
use BDDObject\User;
use BDDObject\Classe;
use BDDObject\Logged;
use BDDObject\Fiche;
use BDDObject\Exam;
use BDDObject\ExoFiche;
use BDDObject\Note;
use BDDObject\AssoUF;
use BDDObject\Conx;

class Action
{
	public function output()
	{
		$action = getPost("action");
		if ($action === null) $action = getGet("action");
		if (method_exists($this,$action)) return $this->$action();
		else return array("error"=>true);
	}

	protected function logged()
	{
		if ($uLog === null) $uLog = Logged::getConnectedUser();
		# On teste seulement si l'utilisateur est connecté
		# sans remettre à jour son time
		return array( "logged"=>$uLog->connexionOk());
	}

	protected function reinitMDP()
	{
		$key = getPost('key');
		if ($key!==null) Logged::tryConnexionOnInitMDP($key);
		$uLog = Logged::getConnectedUser();
		$success = $uLog->connexionOk();
		if ($success) $data = $this->getData($uLog);
		else $data = array();
		return array_merge( array("success"=>$success, "logged"=>$uLog->toArray(), "messages"=>EC::messages()), $data);
	}

	protected function forgotten()
	{
		$identifiant = getPost('identifiant');
		$id = User::identifiantExists($identifiant);
		if ($id!==false) {
			$key = User::initKey($id);
			if ($key!==null) {
				send_html_mail($identifiant,"Mot de passe oublié","<b>".NOM_SITE.".</b> Vous avez oublié votre mot de passe. Suivez ce lien pour pour modifier votre mot de passe : <a href='".PATH_TO_SITE."/#reinit:$key'>Réinitialisation du mot de passe</a>.");
				return array("found"=>true);
			}
			else return array("found"=>true, "error"=>true);
		}
		return array("found"=>false);
	}

	protected function connexion()
	{
		$identifiant=getPost('identifiant');
		$pwd=getPost('pwd','');
		$dataFetch = getPost("dataFetch","true");
		if ($identifiant !== null) Logged::tryConnexion($identifiant, $pwd);
		$uLog = Logged::getConnectedUser();
		$success = $uLog->connexionOk();
		if ($success && ($dataFetch=="true")) $data = $this->getData($uLog);
		else $data = array();
		return array_merge( array("success"=>$success, "logged"=>$uLog->toArray(), "messages"=>EC::messages()), $data);
	}

	public function getData($uLog = null)
	{
		if ($uLog === null) $uLog = Logged::getConnectedUser();
		if ($uLog->connexionOk()) {
			if($uLog->isRoot()) {
				return array(
					"uLog"=>$uLog->toArray(),
					"users" => User::getList(array('ranks'=>array(User::RANK_ADMIN, User::RANK_ELEVE, User::RANK_PROF))),
					"classes" => Classe::getList(),
					"fiches" => Fiche::getList(),
					"messages"=>EC::messages()
				);
			} elseif ($uLog->isAdmin()) {
				return array(
					"uLog"=>$uLog->toArray(),
					"users" => User::getList(array('ranks'=>array(User::RANK_ELEVE, User::RANK_PROF))),
					"classes" => Classe::getList(),
					"fiches" => Fiche::getList(),
					"messages"=>EC::messages()
				);
			} elseif ($uLog->isProf()) {
				return array(
					"uLog"=>$uLog->toArray(),
					"users" => User::getList(array('classes'=>array_keys( $uLog->ownerOf() ))),
					"classes" => Classe::getList(array('ownerIs'=> $uLog->getId() )),
					"fiches" => Fiche::getList(array("owner"=> $uLog->getId() )),
					"messages"=>EC::messages()
				);
			} else {
				return array(
					"uLog"=>$uLog->toArray(),
					"users" => array(),
					"classes" => Classe::getList(array('forEleve'=> $uLog->getId() )),
					"fiches" => Fiche::getList(array("eleve"=> $uLog->getId() )),
					// Dans le cas d'un élève, on charge d'emblée l'ensemble des notes
					// et la structure des fiches
					"exosfiches" => ExoFiche::getList(array("idUser"=>$uLog->getId())),
					"faits" => Note::getList(array("idUser"=>$uLog->getId())),
					"fichesAssoc" => $uLog->fichesAssoc(),
					"messages"=>EC::messages()
				);
			}
		}
		return array(
			"uLog"=>$uLog->toArray(),
			"users" => array(),
			"classes" => Classe::getList(array('forJoin'=> true )),
			"fiches" => array(),
			"messages"=>EC::messages()
		);
	}

	protected function deconnexion()
	{
		SC::get()->destroy();
		$data = $this->getData(null);
		return array_merge( array( "logged"=>Logged::getConnectedUser()->toArray() ), $data);
	}


	protected function testMDP()
	{
		$id = getPost("id");
		$pwd = getPost("pwd");
		$error = true;
		if (($id !== null) && ($pwd !== null)) {
			$classe = Classe::getObject($id);
			if ($classe === null) EC::addError("La classe n'existe pas");
			elseif ($classe->testPwd($pwd)) $error=false;
			else EC::addError("Mot de passe invalide.");
		} else EC::addError("Il faut fournir une classe et un mot de passe");
		return array("error"=>$error, "messages"=>EC::messages());
	}

	protected function join()
	{
		$idClasse = getPost("idClasse");
		$pwdClasse = getPost("pwdClasse");
		$user = extractFromPost(array('nom'=>'', 'prenom'=>'', 'email'=>null, 'pwd'=>''));
		if (($idClasse === null) || ($pwdClasse === null)) EC::addError("Paramètres manquants.");
		else {
			$user=new Logged(array(
				'pwd'=>$user['pwd'],
				'email'=>$user['email'],
				'nom'=>$user['nom'],
				'prenom'=>$user['prenom'],
				'rank'=>User::RANK_ELEVE,
				'idClasse'=>$idClasse
				));

			$classe = Classe::getObject($idClasse);
			if ($classe === null) EC::addError("La classe n'existe pas.");
			else {
				if (!$classe->testPwd($pwdClasse)) EC::addError("Mot de passe invalide.");
				else {
					// Le mot de passe est validé on peut procéder à l'inscription
					// Il faut créer le compte
					$tryUserInsertion = $user->insertion();
					if ($tryUserInsertion !== null){
						// La création de l'utilisateur a bien eu lieu, il devient un utilisateur connecté
						$user->setConnectedUser();
						$data = $this->getData($user);
						return array_merge( array("success"=>true, "user"=>$user->toArray(false), "messages"=>EC::messages()), $data);
					}
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages());
	}

//-----------------get object----------------------

	protected function getUser()
	{
		$uLog =Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getGet("id");
			if ($id===null) EC::addError("Paramètre manquant.");
			else {
				$user = User::getObject($id);
				if ($user===null) EC::addError("Utilisateur introuvable.");
				elseif ( ($uLog->isAdmin() && $uLog->isStronger($user)) || ($uLog->isProf() && $user->isMyTeacher($uLog)) || ($user->getId() === $uLog->getId()) ) {
					return array("success"=>true, "user"=>$user->toArray(false), "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		}
		return array( "error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function getClasse()
	{
		$uLog =Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getGet("id");
			if ($id===null) EC::addError("Paramètre manquant.");
			else {
				$classe = Classe::getObject($id);
				if ($classe===null) EC::addError("Classe introuvable.");
				elseif  ( $uLog->isAdmin() || $classe->isOwnedBy($uLog) ) {
					return array("success"=>true, "classe"=>$classe->toArray(), "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		}
		return array( "error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

//-----------------List objects--------------------

	protected function usersList()
	{
		$uLog =Logged::getConnectedUser();
		if (!$uLog->connexionOk()) return array( "error"=>true);
		if ($uLog->isRoot()) return User::getList(array('ranks'=>array(User::RANK_ADMIN, User::RANK_ELEVE, User::RANK_PROF)));
		if ($uLog->isAdmin()) return User::getList(array('ranks'=>array(User::RANK_ELEVE, User::RANK_PROF)));
		if ($uLog->isProf()) return User::getList(array('classes'=>array_keys( $uLog->ownerOf() )));
		return array( "error"=>true);
	}

	protected function fichesList()
	{
		$uLog =Logged::getConnectedUser();
		if (!$uLog->connexionOk()) return array( "error"=>true);
		if ($uLog->isEleve()) return Fiche::getList(array("eleve"=> $uLog->getId() ));
		if ($uLog->isAdmin()) return Fiche::getList();
		if ($uLog->isProf()) return Fiche::getList(array("owner"=> $uLog->getId() ));
		return array();
	}

	protected function classesList()
	{
		$uLog =Logged::getConnectedUser();
		if (!$uLog->connexionOk()) return Classe::getList(array('forJoin'=> true ));
		if ($uLog->isAdmin()) return Classe::getList();
		if ($uLog->isProf()) return Classe::getList(array('ownerIs'=> $uLog->getId() ));
		if ($uLog->isEleve()) return Classe::getList(array('forEleve'=> $uLog->getId() ));
		return Classe::getList(array('forJoin'=> true ));
	}

	protected function consList()
	{
		$uLog =Logged::getConnectedUser();
		if ($uLog->isAdmin()) return Conx::getList();
		return array( "error"=>true);
	}

//-----------------Save objects--------------------

	protected function userSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost('id');
			if ($id===null) {
				if ($uLog->isAdmin()) {
					$data = extractFromPost(array('pseudo'=>null, 'nom'=>null, 'prenom'=>null, 'email'=>null, 'pwd'=>null, 'rank'=>null));
					$userAdd = new User($data);
					if ($userAdd->isEleve()) EC::addError("Les élèves doivent s'inscrire eux mêmes.");
					elseif (!$uLog->isStronger($userAdd)) EC::addError("Vous ne pouvez pas créer un utilisateur de ce rang.");
					else {
						$id = $userAdd->insertion();
						if ($id!==null) return array("id"=>$id, "user"=>$userAdd->toArray(false), "messages"=>EC::messages());
					}
				} else {
					EC::addError("Vous n'êtes pas autorisé à créer un utilisateur.");
				}
			} else {
				if ($uLog->getId() == $id){
					// On modifie l'utilisateur connecté
					$userToMod=$uLog;
				} elseif ($uLog->isProf(true)) {
					$userToMod=User::getObject($id);
					if ($userToMod === null) EC::addError("Utilisateur introuvable.");
					elseif( !($uLog->isAdmin() && $uLog->isStronger($userToMod)) && !$userToMod->isMyTeacher($uLog) ) {
						EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
						$userToMod = null;
					}
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				if ($userToMod!==null) {
					if ($uLog->isRoot() && !$userToMod->isRoot()) $modOk=$userToMod->update(extractFromPost(array('pseudo'=>null, 'nom'=>null, 'prenom'=>null, 'email'=>null, 'pwd'=>null, 'locked'=>null, 'trash'=>null)));
					elseif ($uLog->isProf(true)) $modOk=$userToMod->update(extractFromPost(array('nom'=>null, 'prenom'=>null, 'email'=>null, 'pwd'=>null, 'locked'=>null, 'trash'=>null)));
					else $modOk=$userToMod->update(extractFromPost(array('nom'=>null, 'prenom'=>null, 'email'=>null, 'pwd'=>null)));
					if ($modOk!==false) return array("user"=>$userToMod->toArray(false), "messages"=>EC::messages());
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function classeSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isEleve() ) return EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		else {
			$id = getPost("id");
			if ($id===null) {
				$data = extractFromPost(array('nom'=>null, 'description'=>null, 'ouverte'=>null, 'pwd'=>null));
				$data["owner"] = $uLog;
				$classe = new Classe($data);
				$id = $classe->insertion();
				if ($id!==null) return array("id"=>$id, "classe"=>$classe->toArray(), "messages"=>EC::messages());
			} else {
				$classe=Classe::getObject($id);
				if ($classe === null) EC::addError("Classe introuvable.");
				elseif ($uLog->isAdmin() || $classe->isOwnedBy($uLog)) {
					$classe->update(extractFromPost(array('nom'=>null, 'description'=>null, 'ouverte'=>0, 'pwd'=>null)));
					return array("classe"=>$classe->toArray(), "messages"=>EC::messages());
				} else  EC::addError("Votre rang ne vous permet pas de faire cette modification.");
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function ficheSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost("id");
			if ($id===null) {
				// Création d'une fiche
				if ($uLog->isProf(true)) {
					$fiche = new Fiche(extractFromPost(array('nom'=>null, 'description'=>null, "idOwner"=>$uLog->getId(), 'visible'=>null, 'actif'=>null )));
					$id = $fiche->insertion();
					if ($id !== null) return array("success"=>true, "fiche"=>$fiche->toArray(), "id"=>$id, "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			} else {
				$fiche = Fiche::getObject($id);
				if (($fiche !== null) && ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) ) {
					$fiche->update(extractFromPost(array('nom'=>null, 'description'=>null, 'visible'=>null, 'actif'=>null)));
					return array("success"=>true, "fiche"=>$fiche->toArray(), "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function exoficheSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif (!$uLog->isProf(true)) EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		else {
			$id = getPost("id");
			if ($id===null) {
				// Création d'une assoc exo-fiche
				// Il faut s'assurer que la fiche parente est autorisée
				$idFiche = getPost("idFiche");
				$fiche = Fiche::getObject($idFiche);
				if ($fiche===null) EC::addError("Devoir introuvable.");
				elseif ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) {
					$exofiche = new ExoFiche(extractFromPost(array("options"=>null,"num"=>null, "coeff"=>null, "idFiche"=>null, "idE"=>null )));
					$id = $exofiche->insertion();
					if ($id !== null) return array("success"=>true, "exofiche"=>$exofiche->toArray(), "id"=>$id, "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			} else {
				$exofiche = ExoFiche::getObject($id);
				if ($exofiche === null) EC::addError("Exercice introuvable.");
				else {
					$fiche = $exofiche->getFiche();
					if ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) {
						$exofiche->update(extractFromPost(array('num'=>null, 'coeff'=>null, "options"=>null)));
						return array("success"=>true, "exofiche"=>$exofiche->toArray(), "messages"=>EC::messages());
					} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function examSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif (!$uLog->isProf(true)) EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		else {
			$id = getPost("id");
			if ($id===null) {
				// Création d'un exam
				// Il faut s'assurer que la fiche parente est autorisée
				$idFiche = getPost("idFiche");
				$fiche = Fiche::getObject($idFiche);
				if ($fiche===null) EC::addError("Devoir introuvable.");
				elseif ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) {
					$exam = new Exam(extractFromPost(array("data"=>null, "nom"=>null, "idFiche"=>null )));
					$id = $exam->insertion();
					if ($id !== null) return array("success"=>true, "exam"=>$exam->toArray(), "id"=>$id, "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			} else {
				$exam = Exam::getObject($id);
				if ($exam === null) EC::addError("Examen introuvable.");
				else {
					$fiche = $exam->getFiche();
					if ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) {
						$exam->update(extractFromPost(array('data'=>null, 'nom'=>null, 'locked'=>null)));
						return array("success"=>true, "exam"=>$exam->toArray(), "messages"=>EC::messages());
					} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function noteSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost("id");
			if ($id!==null) {
				$note = Note::getObject($id);
				if ($note===null) EC::addError("Note introuvable.");
				elseif ($note->writeAllowed($uLog)) {
					$note->update(extractFromPost(array('note'=>null, 'inputs'=>null, "answers"=>null, "finished"=>null)));
					return array("success"=>true, "note"=>$note->toArray(), "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			} else {
				$aEF = getPost("aEF");
				$aUF = getPost("aUF");
				// Il faut vérifier la cohérence de la demande et l'autorisation
				if (($aEF === null)||($aUF === null)) EC::addError("Paramètre(s) manquant(s).");
				else {
					if ( ( ($exoFiche=ExoFiche::getObject($aEF)) ===null ) || ( ($fiche=$exoFiche->getFiche()) ===null ) || ( ($oUF=AssoUF::getObject($aUF)) ===null ) ) EC::addError("Objet introuvable.");
					elseif ( $oUF->getIdFiche() !== $fiche->getId() ) EC::addError("Incohérence dans les informations transmises.");
					elseif (
						($uLog->isAdmin()) ||
						($uLog->isProf() && $fiche->isOwnedBy($uLog)) ||
						( $uLog->isEleve() && ($oUF->getIdUser()==$uLog->getId()) )
						)
					{
						$note = new Note(extractFromPost(array('aEF'=>$aEF, 'aUF'=>$aUF, 'note'=>null, 'inputs'=>null, "answers"=>null, "finished"=>null, "idUser"=>$uLog->getId() )));
						$id = $note->insertion();
						if ($id !== null) return array("success"=>true, "note"=>$note->toArray(), "id"=>$id, "messages"=>EC::messages());
					} else {
						EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
					}
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function assoUFSave()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost("id");
			if ($id===null) {
				// Création d'une assoUF
				if ($uLog->isProf(true)) {
					$idFiche = getPost("idFiche");
					$idUser = getPost("idUser");
					if (($idFiche===null)||($idUser===null)) EC::addError("Paramètres manquants.");
					else {
						$fiche = Fiche::getObject($idFiche);
						$user = User::getObject($idUser);
						if ($fiche===null) EC::addError("Objet fiche introuvable.");
						elseif ($user===null) EC::addError("Objet utilisateur introuvable.");
						elseif (($fiche!==null) && ($user!==null) &&  ($uLog->isAdmin() || ($fiche->isOwnedBy($uLog) && $user->isMyTeacher($uLog) ))) {
							$oUF = new AssoUF(extractFromPost(array('idUser'=>$idUser, 'idFiche'=>$idFiche, "date"=>null, 'actif'=>null )));
							$id = $oUF->insertion();
							if ($id !== null) return array("success"=>true, "oUF"=>$oUF->toArray(), "id"=>$id, "messages"=>EC::messages());
						} else {
							EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
						}
					}
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			} else {
				// Modification d'une fiche
				$oUF = AssoUF::getObject($id);
				if ($oUF===null) {
					EC::addError("Objet introuvable.");
				} elseif ( $uLog->isAdmin() || $uLog->isProf() && ($oUF->isOwnedBy($uLog) || $oUF->isMyTeacher($uLog)) ) {
					$oUF->update(extractFromPost(array('actif'=>null)));
					return array("success"=>true, "oUF"=>$oUF->toArray(), "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

//-----------------deleteObjects------------

	protected function userDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isEleve()) EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		else {
			$id = getPost('id');
			if ($id!==null) {
				$user=User::getObject($id);
				if ($user === null) EC::addError("Utilisateur introuvable.");
				elseif( ($uLog->isAdmin() && $uLog->isStronger($user)) || $user->isMyTeacher($uLog) ) {
					if ($user->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function classeDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isEleve()) EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		else {
			$id = getPost("id");
			if ($id!==null) {
				$classe=Classe::getObject($id);
				if ($classe === null) EC::addError("Classe introuvable.");
				elseif ($uLog->isAdmin() || $classe->isOwnedBy($uLog)) {
					if ($classe->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else  EC::addError("Votre rang ne vous permet pas de faire cette modification.");
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function ficheDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isProf(true)) {
			$id = getPost("id");
			if ($id!==null) {
				$fiche = Fiche::getObject($id);
				if ($fiche===null) EC::addError("Devoir introuvable.");
				elseif ($uLog->isAdmin() || $fiche->isOwnedBy($uLog)) {
					if ($fiche->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function exoficheDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isProf(true)) {
			$id = getPost("id");
			if ($id!==null) {
				$exofiche = ExoFiche::getObject($id);
				if ($exofiche === null) EC::addError("Exercice introuvable.");
				elseif ($uLog->isAdmin() || $exofiche->getFiche()->isOwnedBy($uLog)) {
					if ($exofiche->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function examDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isProf(true)) {
			$id = getPost("id");
			if ($id!==null) {
				$exam = Exam::getObject($id);
				if ($exam === null) EC::addError("Exam introuvable.");
				elseif ($uLog->isAdmin() || $exam->getFiche()->isOwnedBy($uLog)) {
					if ($exam->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		} else EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function noteDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost("id");
			if ($id!==null) {
				$note = Note::getObject($id);
				if ($note===null) EC::addError("Note introuvable.");
				elseif ($uLog->isProf(true) && $note->writeAllowed($uLog)) {
					if ($note->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function assoUFDelete()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		else {
			$id = getPost("id");
			if ($id===null) EC::addError("Paramètres manquants.");
			else {
				$oUF = AssoUF::getObject($id);
				if ($oUF===null) {
					EC::addError("Objet introuvable.");
				} elseif ( $uLog->isAdmin() || $uLog->isProf() && ($oUF->isOwnedBy($uLog) || $oUF->isMyTeacher($uLog)) ) {
					if ($oUF->delete()) return array("success"=>true, "messages"=>EC::messages());
				} else {
					EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function conDelete()
	{
		$uLog=Logged::getConnectedUser();
		if (($unlogged = !$uLog->connexionOk()) || !$uLog->isAdmin()) EC::addError("Connexion admin requise.");
		else {
			$id = getPost("id");
			if ($id===null) EC::addError("Paramètres manquants.");
			else {
				$oCon = Conx::getObject($id);
				if ($oCon===null) {
					EC::addError("Objet introuvable.");
				} else {
					if ($oCon->delete()) return array("success"=>true, "messages"=>EC::messages());
				}
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

//-----------------Divers--------------------


	protected function getFullFicheInfos()
	{
		// Renvoie :
		// - tous les exofiches du devoir (=>exercices)
		// - toutes les notes (=>faits)
		// - toutes les assocs entre le devoir et les utilisateurs (=>eleves)
		//    Remarque : Le devoir appartenant au prof, les assocs tombent donc forcément sur ses élèves

		$id = getPost("id");
		$unlogged=false;
		if ($id===null) EC::addError("Paramètre(s) manquant(s).");
		else {
			$uLog=Logged::getConnectedUser();
			if ($unlogged=!$uLog->connexionOk()) EC::addError("Vous devez vous connecter.");
			if(($fiche=Fiche::getObject($id))===null) EC::addError("Fiche introuvable.");
			elseif ($uLog->isAdmin() ||
				$uLog->isProf() && $fiche->isOwnedBy($uLog) ||
				$uLog->isEleve() && (count($listeAssoc=AssoUF::getList(array("idFiche"=>$id, "idUser"=>$uLog->getId())))>0))
			{
				if ($uLog->isEleve()) {
					$eleves = $listeAssoc;
					$faits = Note::getList(array("idUser"=>$uLog->getId(), "idFiche"=>$id));
					$exams = null;
				} else {
					$eleves = AssoUF::getList(array("idFiche"=>$id));
					$faits = Note::getList(array("idFiche"=>$id));
					$exams = Exam::getList(array("idFiche"=>$id));
				}
				return array("fiche"=>$fiche->toArray(), "exercices"=>ExoFiche::getList(array("idFiche"=>$id)), "eleves"=>$eleves, "faits"=>$faits, "exams"=>$exams, "messages"=>EC::messages());
			} else {
				EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function getUserNotes()
	{
		// Renvoie :
		// - tous les exofiches des devoirs auxquels l'utilisateur est lié (=>exosfiches)
		// - toutes les notes (=>faits)
		// - toutes les assocs entre l'utilisateur et les devoirs (=>fichesAssoc)
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isEleve()){
			EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		} else {
			$user = User::getObject(getPost('id'));
			if ($user===null) {
				EC::addError("Élève introuvable.");
			} elseif (!$user->isEleve()) {
				EC::addError("L'utilisateur n'est pas un élève.");
			} elseif ($uLog->isAdmin() || $user->isMyTeacher($uLog)) {
				$output = array( "success"=>true, "messages"=>EC::messages() );
				$output['exosfiches'] = ExoFiche::getList(array("idUser"=>$user->getId()));
				$output['faits'] = Note::getList(array("idUser"=>$user->getId()));
				$output['fichesAssoc'] = $user->fichesAssoc();
				return $output;
			} else {
				EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
			}
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function UFNlist()
	{
		$uLog=Logged::getConnectedUser();
		if ($unlogged = !$uLog->connexionOk()) EC::addError("Connexion requise.");
		elseif ($uLog->isEleve()){
			EC::addError("Vous n'êtes pas autorisé à effectuer cette action.");
		} else {
			$liste = explode(";",getGET("liste"));
			$i=0;
			while ($i<count($liste)) {
				$idUser = $liste[$i];
				$user = User::getObject($idUser);
				if ($user===null) {
					EC::addError("Élève ($idUser) introuvable.");
					array_splice($liste,$i,1);
				} elseif (!$user->isEleve()) {
					EC::addError("L'utilisateur ($idUser)'est pas un élève.");
					array_splice($liste,$i,1);
				} elseif ($uLog->isAdmin() || $user->isMyTeacher($uLog)) {
					$liste[$i] = $user->getId();
					$i++;
				} else {
					EC::addError("Vous n'êtes pas autorisé à voir les notes de ($idUser).");
					array_splice($liste,$i,1);
				}
			}
			$output = array( "success"=>true, "messages"=>EC::messages() );
			if (count($liste)>0) $output['faits'] = Note::getList(array("usersList"=>$liste));
			else $output['faits'] = array();
			return $output;
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}

	protected function ConxPurge()
	{
		$uLog=Logged::getConnectedUser();
		if (($unlogged = !$uLog->connexionOk()) && !$uLog->isAdmin()) EC::addError("Connexion admin requise.");
		else {
			$success = Conx::purge();
			if ($success) return array("success"=>true, "messages"=>EC::messages());
		}
		return array("error"=>true, "messages"=>EC::messages(), "unlogged"=>$unlogged);
	}
}

?>

