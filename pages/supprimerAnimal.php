<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Supprimer un animal</title>
    <script src="../js/jquery.js"></script>
    <script>
        function load_new_content(){
            var selected_option_value=$("#select1 option:selected").val();

            $.post("ajouteDivPourSupprAnimal.php", {option_value: selected_option_value},
                function(data){
                    $("#div_animal").html(data);
                }
            );
        }


    </script>
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
                                <select class="form-select mt-3" id="select1" name="race" onchange='load_new_content()' required>
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

                           <div class="col-md-12" id="div_animal">
                                
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