<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../css/flickity.css" media="screen">
    <link rel="stylesheet" href="../css/animaux.css">
    <title>Zouzoo - Espèces</title>
</head>
<body>
    <script src="../js/flickity.pkgd.min.js"></script>

    
    <?php include_once("../includes/pourchaquepage.php");

    $nomTypeEnclos = $db->query("SELECT id_type_enclos, titre FROM TypeEnclos");

    while($ligne = $nomTypeEnclos->fetchArray()){
        $getImage = $db->query("SELECT race, photo FROM Espece NATURAL JOIN TypeEnclos WHERE nb_dans_zoo > 0 AND id_type_enclos = '$ligne[0]'");
        $nbEspeceTypeEnclos = $db->querySingle("SELECT nombre FROM NombreEspecesParTypeEnclos WHERE id_type_enclos = '$ligne[0]'");
        $nbEspeceTypeEnclos = ($nbEspeceTypeEnclos == 0) ? 0 : $nbEspeceTypeEnclos;
    ?>

    <p id="type"> <?php echo $ligne[1] . " - " . $nbEspeceTypeEnclos . " espèces"  ?> </p>

    <div class="carousel" data-flickity='{ "wrapAround": true }'>
        <?php
            while($ligne_race = $getImage->fetchArray()){
        ?>
                <div class="carousel-cell">
                        <a href="espece.php?nom=<?php echo $ligne_race[0] ?>">
                            <img class="carousel-img" src="../img/img_zoo/<?php echo $ligne_race[1] ?>">
                        </a>
                        
                        <p class="textcell"><?php echo $ligne_race[0] ?></p>
                </div>

        <?php
            }
        ?>
    </div>

    <?php
    } 
    ?>
</body>
</html>