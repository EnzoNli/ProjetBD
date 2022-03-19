<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link rel="stylesheet" href="../css/flickity.css" media="screen">
    <link rel="stylesheet" href="../css/animaux.css">
    <title>Zouzoo - Espèces</title>
</head>
<body>
    <script src="../js/flickity.pkgd.min.js"></script>

    
    <?php include_once("../includes/pourchaquepage.php");

    $nomTypeEnclos = $db->query("SELECT id_type_enclos, titre FROM TypeEnclos");

    while($ligne = $nomTypeEnclos->fetchArray()){
        $getImage = $db->query("SELECT race, photo FROM Espece NATURAL JOIN TypeEnclos WHERE id_type_enclos = '$ligne[0]'");
    ?>

    <p id="type"> <?php echo $ligne[1] ?> </p>

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