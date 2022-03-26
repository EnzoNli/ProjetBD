<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Associer un plat à une espèce</title>
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
                        <h3>Associer un plat à une espèce</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                                <select class="form-select mt-3" name="race" required>
                                      <option selected disabled value="">Race</option>
                                        <?php 
                                        $chaqueRace = $db->query("SELECT race FROM Espece");

                                        while($ligne = $chaqueRace->fetchArray()){
                                            $param = urlencode($ligne[0]);

                                        ?>

                                        <option value=<?php echo $param ?>><?php echo $ligne[0]?></option>

                                        <?php
                                        }
                                        ?>
                               </select>
                           </div>

                           <div class="col-md-12">
                                <select class="form-select mt-3" name="nourriture" required>
                                      <option selected disabled value="">Plat</option>
                                        <?php 
                                        $chaquePlat = $db->query("SELECT id_plat FROM Nourriture");

                                        while($ligne = $chaquePlat->fetchArray()){
                                            $param = urlencode($ligne[0]);

                                        ?>

                                        <option value=<?php echo $param ?>><?php echo $ligne[0]?></option>

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