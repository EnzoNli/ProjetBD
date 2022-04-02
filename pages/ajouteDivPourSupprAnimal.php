<select class="form-select mt-3" name="animal" required>
    <option selected disabled value="">Animal</option>
    <?php
    $animal_select = urldecode($_POST['option_value']);
    class MyDB extends SQLite3
    {
        function __construct()
        {
            $this->open('../zoo.db');
        }
    }
    $db = new MyDB();

    $q = $db->prepare("SELECT nom FROM Animal WHERE race = :option_value");
    $q->bindValue(":option_value", $animal_select, SQLITE3_TEXT);
    $chaqueNom = $q->execute();

    while($ligne = $chaqueNom->fetchArray()){
        $param = urlencode($ligne[0]);

    ?>

    <option value=<?php echo $param ?>><?php echo $ligne[0]?></option>

    <?php
    }
    ?>
</select>