<!DOCTYPE html>
<html>
  
<head>
    <title>Zouzoo - Modification de la base</title>
</head>
  
<body>  
        <?php

        include_once("../includes/pourchaquepage.php");

        if(str_contains($_SERVER['HTTP_REFERER'], "ajouterAnimal.php")){
            $nom =  $_REQUEST['nom'];
            $race = urldecode($_REQUEST['race']);
            $poids =  $_REQUEST['poids'];
            $origine = $_REQUEST['origine'];
            $genre = $_REQUEST['genre'];
            $naissance = $_REQUEST['naissance'];
            $id_soigneur = $_REQUEST['Soigneur'];
            $id_enclos = $_REQUEST['Enclos'];
            
            $sql = "INSERT INTO Animal VALUES ('$nom', 
            '$race','$id_enclos','$naissance','$genre','$poids',
            '$origine','$id_soigneur')";

        }elseif(str_contains($_SERVER['HTTP_REFERER'], "supprimerAnimal.php")){
            $nom = urldecode($_REQUEST['animal']);
            
            $sql = "DELETE FROM Animal WHERE nom = '$nom'";

        }elseif(str_contains($_SERVER['HTTP_REFERER'], "ajouterAnimation.php")){
            $description_anim = $_REQUEST['descr'];
            $duree = $_REQUEST['duree'];
            $id_soigneur = $_REQUEST['Soigneur'];

            $sql = "INSERT INTO Animation (duree, description_anim, id_soign)VALUES('$duree',
            '$description_anim','$id_soigneur')";

        }
        
          
        if($db->exec($sql)){
            echo "<h3>La modification a été effectuée !</h3>";
        } else{
            echo "Erreur: " 
                . $db->lastErrorMsg()
                . $sql;
        }

        $db->close();
          
        ?>
</body>
  
</html>