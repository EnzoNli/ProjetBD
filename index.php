<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Accueil</title>
    <link rel="stylesheet" href="css/flickity.css" media="screen">
    <link rel="stylesheet" href="css/index.css">
</head>
<body>

    <?php
    include_once("includes/navbar.php");
    if(file_exists("zoo.db")){
        unlink("zoo.db");
    }
    
    $compteur = 0;
    
    $db = new SQLite3("zoo.db");
    $creation = file_get_contents("main.sql");
    $db->exec($creation);
    
    $q = $db->query("SELECT * FROM nombretotalanimauxzoo");
    $ligne = $q->fetchArray();
    
    ?>
    <script src="js/flickity.pkgd.min.js"></script>

    <div class="main-gallery js-flickity"
  data-flickity-options='{ "cellAlign": "left", "contain": true, "pageDots": false , "wrapAround": true, 
    "autoPlay": 5000, "pauseAutoPlayOnHover": false, "prevNextButtons": false, "selectedAttraction": 0.01, "friction": 0.30, "draggable": false }'>
        <div class="gallery-cell">
            <hr id="ligne1">
            <p class="msg">BIENVENUE CHEZ ZOUZOO</p>
            <img class="banniere" src="img/banniere.jpg" alt="Banniere">
        </div>
        <div class="gallery-cell">
            <hr id="ligne2">
            <p class="msg" id="msg2">IL Y A ACTUELLEMENT<br><?php echo $ligne[0] ?> ANIMAUX<br>DANS LE ZOO</p>
            <img class="banniere" src="img/banniere2.jpg" alt="Banniere">
        </div>
    </div>

    
</body>
</html>