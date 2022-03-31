<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Ajouter un lien de parenté</title>
    <link rel="icon" type="image/png" href="../img/logo.png"/>
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
                        <h3>Ajouter un lien de parenté</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                                <select class="form-select mt-3" name="enfant" required>
                                      <option selected disabled value="">Choisissez l'enfant</option>
                                        <?php 
                                        $chaqueAnim = $db->query("SELECT nom, race FROM Animal");

                                        while($ligne = $chaqueAnim->fetchArray()){
                                            $param = urlencode($ligne[0]);

                                        ?>

                                        <option value=<?php echo $param ?>><?php echo $ligne[0]." (".$ligne[1].")" ?></option>

                                        <?php
                                        }
                                        ?>
                               </select>
                           </div>

                           <div class="col-md-12">
                                <select class="form-select mt-3" name="parent" required>
                                      <option selected disabled value="">Choisissez le parent</option>
                                        <?php 
                                        $chaqueAnim = $db->query("SELECT nom, race FROM Animal");

                                        while($ligne = $chaqueAnim->fetchArray()){
                                            $param = urlencode($ligne[0]);

                                        ?>

                                        <option value=<?php echo $param ?>><?php echo $ligne[0]." (".$ligne[1].")" ?></option>

                                        <?php
                                        }
                                        ?>
                               </select>
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