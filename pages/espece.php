<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../css/espece.css">
    <link rel="icon" type="image/png" href="../img/logo.png"/>
    
    <title>Zouzoo - <?php echo $_GET['nom'] ?></title>
</head>
<body>
    <?php 
        include_once("../includes/pourchaquepage.php");
        $q = $db->prepare("SELECT * FROM Espece WHERE race = :get");
        $q->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
        $res = $q->execute()->fetchArray();

        $mangeur = $db->prepare("SELECT * FROM CategorieNourriture WHERE id_categorie = :get");
        $mangeur->bindValue(':get', $res['id_categorie'], SQLITE3_TEXT);
        $cat = $mangeur->execute()->fetchArray();
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
        <p class="info" id="alimentation">Alimentation : <?php echo $cat['description_cat'] ?></p>
    </div>

    <img id="ext" src="../img/extinction/ext<?php echo $res['menace_extinction'] ?>.svg">
    <img id="photo" src="../img/img_zoo/<?php echo $res['photo'] ?>">
    <p id="txt_dang">Dangerosité : </p>
    <img id="dang" src="../img/dang/nv<?php echo $res['dangerosite'] ?>.png">
    

    <hr id="sep">
    <div id="animaux">
        <h1 class="nom_cat">Animaux de cette espèce dans le zoo : </h1>  
    <?php
        $race = $_GET['nom'];
        $requete = $db->prepare("SELECT * FROM Animal WHERE race = :get");
        $requete->bindValue(':get', $race, SQLITE3_TEXT);
        $res2 = $requete->execute();
        while($ligne = $res2->fetchArray()){
        ?>
        <a href="../pages/animal.php?nom=<?php echo $ligne[0] ?>"><?php echo $ligne[0] ?></a>
        <br>

        <?php
        }
        ?>
    </div>

    
    <hr id="sep2">

    <div id="nourriture">
        <h1 class="nom_cat">Nourriture : </h1>
        <?php
        $race = $_GET['nom'];
        $requete = $db->prepare("SELECT * FROM Manger WHERE race = :get");
        $requete->bindValue(':get', $race, SQLITE3_TEXT);
        $res2 = $requete->execute();
        while($ligne = $res2->fetchArray()){
        ?>
        <p class="nou"><?php echo $ligne[1]?></p>

        <?php
        }
        ?>
    </div>
    

    


</body>
</html>