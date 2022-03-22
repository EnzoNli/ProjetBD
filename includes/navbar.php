<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3" crossorigin="anonymous">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-ka7Sk0Gln4gmtz2MlQnikT1wXgYsOg+OMhuP+IlRH9sENBO0LRn5q+8nbTov4+1p" crossorigin="anonymous"></script>
<link rel="stylesheet" href="../css/navbar.css">

<nav class="navbar navbar-expand-sm">
   <a class="navbar-brand" href="/index.php">
    <p id="titre">Zouzoo</p>
   </a>
   
      <div class="menugauche">
         <ul class="navbar-nav">
            <li class="nav-item hover">
               <a class="nav-link" href="/pages/animaux.php">Animaux</a>
            </li>
            <li class="nav-item hover">
               <a class="nav-link" href="#">Animations</a>
            </li>
            <li class="nav-item hover last">
               <a class="nav-link" href="#">Soigneurs</a>
            </li>
         </ul>
      </div>

    <div class="dropdown hover deroulant">
      <a class="dropdown-toggle nav-link" href="#" data-bs-toggle="dropdown">Espace administrateur</a>
      <div class="dropdown-menu">
        <a href="../pages/ajouterAnimal.php" class="dropdown-item">Ajouter un animal</a>
        <a href="#" class="dropdown-item">Supprimer un animal</a>
        <a href="#" class="dropdown-item">Modifier le poids d'un animal</a>
        <div class="dropdown-divider"></div>
        <a href="#" class="dropdown-item">Créer un type de nourriture</a>
        <a href="#" class="dropdown-item">Associer de la nourriture à un animal</a>
        <div class="dropdown-divider"></div>
        <a href="#" class="dropdown-item">Ajouter un type d'animation</a>
        <a href="#" class="dropdown-item">Planifier une animation</a>
    </div>
   </div>
</nav>