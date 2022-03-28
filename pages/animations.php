<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <script src="../js/jquery.js"></script>
    <link rel="stylesheet" href="../css/animations.css">
    <title>Zouzoo - Animations</title>
</head>
<body>
    <?php include_once("../includes/pourchaquepage.php");
    $jour = $db->query("SELECT DISTINCT date_anim FROM Planning ORDER BY date_anim");

    while($ligne = $jour->fetchArray()){
    ?>
    <table class="tableau">
            <thead><tr class="dates"><th colspan = "4" id="<?php echo $ligne[0]?>">
            <script>
        var d = new Date("<?php echo $ligne[0]?>")
        var ye = new Intl.DateTimeFormat('fr', { year: 'numeric' }).format(d)
        var mo = new Intl.DateTimeFormat('fr', { month: 'long' }).format(d)
        var da = new Intl.DateTimeFormat('fr', { day: 'numeric' }).format(d)

        $("#<?php echo $ligne[0]?>").append(`${da} ${mo} ${ye}`);
        
            </script></th></tr>
            
        </thead>

            <tr>
                <th>Heure</th>
                <th>Animation</th>
                <th>Enclos</th>
                <th>Soigneur</th>

            </tr>
            
            <?php
            $id = $db->query("SELECT id_planning FROM Planning WHERE date_anim = '$ligne[0]' ORDER BY heure_debut");
            while($ligne_id = $id->fetchArray()){
            ?>

            <tr>
                <td class="heure"> <?php 
                $heure_anim = $db->querySingle("SELECT heure_debut FROM Planning 
                WHERE id_planning = '$ligne_id[0]'");
                echo $heure_anim; ?> </td>

                <td class="anim"> <?php 
                $id_anim = $db->querySingle("SELECT description_anim FROM Planning 
                NATURAL JOIN Animation WHERE id_planning = '$ligne_id[0]'");
                echo $id_anim; ?> </td>

                <td class="enclos"> <?php 
                $enclos = $db->querySingle("SELECT id_enclos FROM Planning 
                NATURAL JOIN Animation WHERE id_planning = '$ligne_id[0]'");
                echo $enclos; 
                ?> ( <?php 
                $typeenclos = $db->querySingle("SELECT titre FROM TypeEnclos
                NATURAL JOIN Enclos NATURAL JOIN Planning WHERE id_planning = '$ligne_id[0]'");
                echo $typeenclos; 
                ?> )
                </td>

                <td class="soigneur"> <?php 
                $nom = $db->querySingle("SELECT prenom_soign FROM Planning 
                NATURAL JOIN Animation NATURAL JOIN Soigneur WHERE id_planning = '$ligne_id[0]'");
                echo $nom; ?>
                <?php 
                $nom = $db->querySingle("SELECT nom_soign FROM Planning 
                NATURAL JOIN Animation NATURAL JOIN Soigneur WHERE id_planning = '$ligne_id[0]'");
                echo $nom; ?> </td>


            </tr>

            <?php
                }
            ?>
            <br/>

    <?php
    } 
    ?>
</body>
</html>