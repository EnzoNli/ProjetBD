<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Ajouter une animation</title>
</head>
<body>
    <?php include_once("../includes/pourchaquepage.php")
    ?>
    <link rel="stylesheet" href="../css/form.css">
    <div class="form-body">
        <div class="row">
            <div class="form-holder">
                <div class="form-content">
                    <div class="form-items">
                        <h3>Ajouter une animation dans le zoo</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                               <input class="form-control" type="text" name="descr" placeholder="Description de l'animation" required>
                            </div>

                            <div class="col-md-12">
                               <input class="form-control" type="text" name="duree" placeholder="Durée en minutes" required>
                            </div>

                            <div class="col-md-12">
                                <select class="form-select mt-3" name="Soigneur" required>
                                      <option selected disabled value="">Soigneur</option>
                                        <?php 
                                        $chaqueSoigneur = $db->query("SELECT nom_soign,prenom_soign,id_soign FROM Soigneur");

                                        while($ligne = $chaqueSoigneur->fetchArray()){
                                        ?>

                                        <option value=<?php echo $ligne[2] ?>><?php echo $ligne[0]." ".$ligne[1]?></option>

                                        <?php
                                        }
                                        ?>
                               </select>
                           </div>

                            <div class="form-button mt-3">
                                <button id="submit" type="submit" class="btn btn-primary">Enregistrer</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>