<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Zouzoo - Créer une nourriture</title>
    <link rel="icon" type="image/png" href="../img/logo.png"/>
    <script src="../js/jquery.js"></script>
</head>
<body>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#submit').click(function() {
            checked = $("input[type=checkbox]:checked").length;

            if(!checked) {
                alert("Vous devez selectionner au moins une catégorie !");
                return false;
            }

            });
        });
    </script>

    <?php include_once("../includes/pourchaquepage.php")
    ?>
    <link rel="stylesheet" href="../css/form.css">
    <div class="form-body">
        <div class="row">
            <div class="form-holder">
                <div class="form-content">
                    <div class="form-items">
                        <h3>Créer une nourriture</h3>
                        <p>Veuillez remplir les informations ci-dessous.</p>
                        <form class="requires-validation" method="POST" action="modification_bd.php">

                            <div class="col-md-12">
                               <input class="form-control" type="text" name="nom" placeholder="Nom de la nourriture" required>
                            </div>
                            <br>

                            <?php
                            $q = $db->query("SELECT id_categorie, titre_categorie FROM CategorieNourriture");

                            while($ligne = $q->fetchArray()){
                            ?>

                            <div class="col-md-12">
                               <input type="checkbox" id="<?php echo $ligne[1] ?>" name="checkbox[]" value="<?php echo $ligne[0] ?>">
                               <label for="<?php echo $ligne[1] ?>"><?php echo $ligne[1] ?></label>
                            </div>

                            <?php
                            }
                            ?>
                            

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