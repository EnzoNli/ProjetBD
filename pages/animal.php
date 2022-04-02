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

        $requete3 = $db->prepare("SELECT * FROM EnfantsDuZoo WHERE noms = :get");
        $requete3->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
        $res4 = $requete3->execute()->fetchArray();

        $requete4 = $db->prepare("SELECT * FROM ParentsDuZoo WHERE noms = :get");
        $requete4->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
        $res5 = $requete4->execute()->fetchArray();

        $ori =  $res['origine'] == null ? "extérieure au zoo" : $res['origine'];
    ?>
    <div id="presentation">
        <hr id="ligne">
        <p id="nom_animal"><?php echo $_GET['nom'] ?></p>
        <a href="espece.php?nom=<?php echo $res['race']?>" id="espece"><?php echo $res['race']?></a>
    </div>

    <div id="infos">
        <p class="info" id="date">Date de naissance : <?php echo $res['date_naissance_animal'] ?></p>
        <p class="info" id="genre">Genre : <?php echo $res['genre'] ?></p>
        <p class="info" id="poids">Poids : <?php echo $res['poids'] ?> kg</p>
        <p class="info" id="ori">Origine : <?php echo $ori ?></p>
        <p class="info" id="nom_soigneur">Soigneur : <?php echo $res3['prenom_soign'] . " " . $res3['nom_soign']; ?></p>
        <?php
        if($res4){
            $nouvrequete = $db->prepare("SELECT parent FROM AvoirParent WHERE enfant = :get");
            $nouvrequete->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
            $req = $nouvrequete->execute();
        ?>
            <p class="info" id="parents">Parent(s) connu(s) :
                <?php
                while($ligne = $req->fetchArray()){
                ?>

                <a href="animal.php?nom=<?php echo $ligne[0] ?>"><?php echo $ligne[0] ?></a>

                <?php
                }
                ?>
                
            </p>
        <?php
        }
        ?>


        <?php
        if($res5){
            $nouvrequete2 = $db->prepare("SELECT enfant FROM AvoirParent WHERE parent = :get");
            $nouvrequete2->bindValue(':get', $_GET['nom'], SQLITE3_TEXT);
            $req2 = $nouvrequete2->execute();
        ?>
            <p class="info" id="enfants">Enfant(s) connu(s) :
                <?php
                while($ligne = $req2->fetchArray()){
                ?>

                <a href="animal.php?nom=<?php echo $ligne[0] ?>"><?php echo $ligne[0] ?></a>

                <?php
                }
                ?>
                
            </p>
        <?php
        }
        ?>
    </div>

    <img id="photo" src="../img/img_zoo/<?php echo $res2['photo'] ?>">
    
    

    

    

    


</body>
</html>