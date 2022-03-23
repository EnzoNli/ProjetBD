<!DOCTYPE html>
<html>
  
<head>
    <title>Zouzoo - Modification de la base</title>
</head>
  
<body>  
        <?php

        include_once("../includes/pourchaquepage.php");

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
          
        if($db->exec($sql)){
            echo "<h3>La modification a été effectuée !</h3>";
  
            echo nl2br("\n$nom\n $race\n "
                . "$poids\n $origine\n $genre\n $naissance\n $id_soigneur\n $id_enclos");
        } else{
            echo "Erreur: " 
                . $db->lastErrorMsg()
                . $sql;
        }

        $db->close();
          
        ?>
</body>
  
</html>