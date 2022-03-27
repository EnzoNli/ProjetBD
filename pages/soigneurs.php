<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="../css/soigneurs.css">
    <script src="../js/jquery.js"></script>
    <title>Zouzoo - Soigneurs</title>
    <script>
        $(document).ready(function() {
            $("#sep").hide();
            $("#titre_animaux").hide();
            $(".liste").on("click", function() {
                load_new_content(jQuery(this).text());
            });
        });

        function load_new_content(texte){

            $.post("changeSoigneur.php", {option_value: texte},
                function(data){
                    $("head").append(data);
                }
            );
        }
    </script>
    
</head>
<body>
    <?php 
        include_once("../includes/pourchaquepage.php");
        
    ?>

    <div class="gauche">
        <h1 id="titre_soigneur">Choissisez le soigneur que vous souhaitez :</h1>
            <br>
            <div class="soigneurs">
                <?php
                $q = $db->query("SELECT prenom_soign, nom_soign, date_naissance_soign FROM Soigneur");
                while($ligne = $q->fetchArray()){
                ?>
                <a href="#" class="liste"><?php echo $ligne[0] . " " . $ligne[1]?></a>
                <br>

                <?php
                }
                ?>
            </div>
    </div>
    
    <div class="separation"></div>


    <div class="droite">
        <h1 id="nomcomp"></h1>
        <p id="genre"></p>
        <h3 id="naissance"></h3>
        <hr id="sep">
        <h1 id="titre_animaux">Animaux soignés :</h1>
        <br>
        <div id="animaux">
            
        </div>

    </div>
    

    

    

    


</body>
</html>