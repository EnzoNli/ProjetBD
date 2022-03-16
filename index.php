<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zoo</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <?php
    include_once("includes/navbar.php");
    /*
    unlink("zoo.db");
    $compteur = 0;
    
    $db = new SQLite3("zoo.db");
    $creation = file_get_contents("main.sql");
    $db->exec($creation);
    $q = $db->query("SELECT * FROM animal");
    while($ligne = $q->fetchArray()){
        echo $ligne['nom'] . " ";
        $compteur++;
    }
    */
    
    ?>

    <div class="jumbotron banniere">
        <h1 class="display-2">Test</h1>
        <p class="lead">Bienvenue dans notre Zoo ! Il y a actuellement <?php echo $compteur ?> animaux dans le zoo</p>
        <img class="panda-banniere" src="img/panda.png">
    </div>
    
</body>
</html>