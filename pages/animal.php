<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../css/animal.css">
    <link rel="icon" type="image/png" href="../img/logo.png"/>
    <title>Zouzoo - <?php echo $_GET['nom'] ?></title>
</head>
<body>
    <?php 
        include_once("../includes/pourchaquepage.php");
        $q = $db->prepare("SELECT * FROM Animal WHERE nom = :get");
        $q->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
        $res = $q->execute()->fetchArray();

        $requete = $db->prepare("SELECT * FROM Espece WHERE race = :get");
        $requete->bindValue(':get', $res['race'], SQLITE3_TEXT);
        $res2 = $requete->execute()->fetchArray();

        $requete2 = $db->prepare("SELECT * FROM Soigneur WHERE id_soign = :get");
        $requete2->bindValue(':get', $res['id_soign'], SQLITE3_TEXT);
        $res3 = $requete2->execute()->fetchArray();
    ?>
    <div id="presentation">
        <hr id="ligne">
        <p id="nom_animal"><?php echo $_GET['nom'] ?></p>
        <p id="espece"><?php echo $res['race']?></p>
    </div>

    <div id="infos">
        <p class="info" id="espe_vie">Date de naissance : <?php echo $res['date_naissance_animal'] ?></p>
        <p class="info" id="espe_poids">Genre : <?php echo $res['genre'] ?></p>
        <p class="info" id="poids_moyen">Poids : <?php echo $res['poids'] ?> kg</p>
        <p class="info" id="habitat_nat">Origine : <?php echo $res['origine'] ?></p>
        <p class="info" id="nom_soigneur">Soigneur : <?php echo $res3['prenom_soign'] . " " . $res3['nom_soign']; ?></p>
    </div>

    <img id="photo" src="../img/img_zoo/<?php echo $res2['photo'] ?>">
    
    

    

    

    


</body>
</html>