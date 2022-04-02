<?php
    class MyDB extends SQLite3
    {
        function __construct()
        {
            $this->open('../zoo.db');
        }
    }
    $db = new MyDB();
    $soigneur_select = $_POST['option_value'];
    function after ($chaine, $inthat)
    {
        if (!is_bool(strpos($inthat, $chaine)))
        return substr($inthat, strpos($inthat,$chaine)+strlen($chaine));
    };

    function before ($chaine, $inthat)
    {
        return substr($inthat, 0, strpos($inthat, $chaine));
    };

    $prenom = before(" ", $soigneur_select);
    $nom = after(" ", $soigneur_select);

    $q = $db->query("SELECT * FROM Soigneur WHERE nom_soign = '$nom' AND prenom_soign = '$prenom'");
    $res = $q->fetchArray();
?>

<script>
    $("#nomcomp").html("<?php echo $soigneur_select?>");
    $("#genre").html("<?php echo "Genre : " . $res[4]?>");


    var d = new Date("<?php echo $res[1]?>")
    var ye = new Intl.DateTimeFormat('fr', { year: 'numeric' }).format(d)
    var mo = new Intl.DateTimeFormat('fr', { month: 'long' }).format(d)
    var da = new Intl.DateTimeFormat('fr', { day: 'numeric' }).format(d)

    $("#naissance").html(`Date de naissance : ${da} ${mo} ${ye}`);
    $("#sep").show();
    $("#titre_animaux").show();
    $("#animaux").html("");
    $("#animations").html("");
    $(".sepanimation").show();
    $("#titre_animations").show();

    <?php
    $nouvreq = $db->query("SELECT * FROM ListeAnimationPourSoigneur WHERE id_soign = $res[0]");
    while($lig = $nouvreq->fetchArray()){
    ?>
    $("#animations").append('<p><?php echo $lig[1] ?></p>');
    <?php
    }

    $requete = $db->query("SELECT nom FROM ListeAnimalPourSoigneur WHERE id_soign = $res[0]");
    while($ligne = $requete->fetchArray()){
    ?>
    $("#animaux").append('<a href="../pages/animal.php?nom=<?php echo $ligne[0] ?>"><?php echo $ligne[0] ?></a><br>');

    <?php
    }
    ?>
    
</script>