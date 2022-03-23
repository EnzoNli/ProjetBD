<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Supprimer un animal</title>
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
                        <h3>Supprimer un animal dans le zoo</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                               <input class="form-control" type="text" name="nom" placeholder="Nom de l'animal" required>
                            </div>

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
                                <input class="form-control" type="text" name="poids" placeholder="Poids" required>
                            </div>

                            <div class="col-md-12">
                                <input class="form-control" type="text" name="origine" placeholder="Origine" required>
                            </div>

                            <div class="col-md-12">
                                <label for="naissance">Date de naissance :</label>
                                <input class="form-control" id="naissance" type="date" name="naissance" value="<?php echo date('Y-m-d'); ?>" required>
                            </div>

                           <div class="col-md-12 mt-3">
                            <label class="mb-3 mr-1" for="genre">Genre: </label>

                            <input type="radio" class="btn-check" name="genre" id="male" autocomplete="off" value="Male" required>
                            <label class="btn btn-sm btn-outline-secondary" for="male" value="Male">Male</label>

                            <input type="radio" class="btn-check" name="genre" id="femelle" autocomplete="off" value="Femelle" required>
                            <label class="btn btn-sm btn-outline-secondary" for="femelle" value="Femelle">Femelle</label>

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

                           <div class="col-md-12">
                                <select class="form-select mt-3" name="Enclos" required>
                                      <option selected disabled value="">Enclos</option>
                                        <?php 
                                        $chaqueEnclos = $db->query("SELECT titre,id_enclos FROM Enclos natural join TypeEnclos");

                                        while($ligne = $chaqueEnclos->fetchArray()){
                                        ?>

                                        <option value=<?php echo $ligne[1] ?>><?php echo $ligne[0]." - ".$ligne[1]?></option>

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