<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Planifier une animation</title>
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
                        <h3>Planifier une animation</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                                <select class="form-select mt-3" name="anim" required>
                                      <option selected disabled value="">Animation</option>
                                        <?php 
                                        $chaqueAnim = $db->query("SELECT id_anim, description_anim FROM Animation");

                                        while($ligne = $chaqueAnim->fetchArray()){
                                            $param = urlencode($ligne[0]);

                                        ?>

                                        <option value=<?php echo $param ?>><?php echo $ligne[1]?></option>

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

                           <br/>

                            <div class="col-md-12">
                                <label for="naissance">Date de l'animation :</label>
                                <input class="form-control" id="naissance" type="date" name="date" value="<?php echo date('Y-m-d'); ?>" required>
                            </div>

                            <br/>

                            <div class="col-md-12">
                                <label for="appt">Heure :</label>
                                <input type="time" id="appt" name="heure" 
                                min="09:00" max="18:00" required>
                            </div>
                           
                            <br/>

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