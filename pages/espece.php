<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../css/flickity.css" media="screen">
    <link rel="stylesheet" href="../css/espece.css">
    
    <title>Zouzoo - <?php echo $_GET['nom'] ?></title>
</head>
<body>
    <?php 
        include_once("../includes/pourchaquepage.php");
        $q = $db->prepare("SELECT * FROM Espece WHERE race = :get");
        $q->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
        $res = $q->execute()->fetchArray();
    ?>
    <div id="presentation">
        <hr id="ligne">
        <p id="race"><?php echo $_GET['nom'] ?></p>
        <p id="nbzoo">Il y a actuellement <?php echo $res['nb_dans_zoo'] . " " . $_GET['nom']  ?> dans le zoo</p>
    </div>

    <div id="infos">
        <p class="info" id="espe_vie">Espérance de vie : <?php echo $res['espe_vie'] ?></p>
        <p class="info" id="espe_poids">Espérance de poids : <?php echo $res['espe_poids_adulte'] ?></p>
        <p class="info" id="poids_moyen">Poids moyen dans le zoo : <?php echo $res['poids_moyen_zoo'] ?> kg</p>
        <p class="info" id="habitat_nat">Habitat naturel : <?php echo $res['habitat_nat'] ?></p>
    </div>

    <img id="ext" src="../img/extinction/ext<?php echo $res['menace_extinction'] ?>.svg">
    <img id="photo" src="../img/img_zoo/<?php echo $res['photo'] ?>">
    

    

    

    


</body>
</html>