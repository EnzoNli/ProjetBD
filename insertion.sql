pragma foreign_keys = true;

insert into CategorieNourriture values 
    ('o',"omnivore : mange des aliments d'origines végétale et animale"),
    ('h',"herbivore : se nourrit d'herbes et de plantes basses"),
    ('c',"carnivore : son régime alimentaire est principalement basé sur la consommation de chairs ou de tissus d'animaux vivants ou morts"),
    ('i',"insectivore : se nourrit d'insectes ou d'autres arthropodes."),
    ('p',"piscivore : se nourrit de poissons.")
;

insert into TypeEnclos values
    ('aq', "Un aquarium est un réservoir rempli d'eau dans lequel vivent des animaux et/ou des plantes aquatiques"),
    ('ex',"blabla extérieur"),
    ('cg', "Une cage est un contenant ajouré, le plus souvent grillagé ou à barreaux, destiné à contenir un animal."),
    ('vl', "Une volière est un enclos assez vaste ordinairement grillagé, généralement une grande cage, où l'on conserve, élève et nourrit des oiseaux d'ornement."),
    ('tr', "Un terrarium est un milieu confiné imitant le biotope de certaines espèces animales et/ou végétales. Il est l'équivalent d'un aquarium dont l'eau serait remplacée par un substrat de quelques centimètres d'épaisseur disposé sur le fond.")
;

insert into Espece values
    ("Panda geant", 0, "20 à 25 ans", "70 à 120 kg", 3, 2, "Forets de bambous", 'h', 'ex'),
    ("Herisson du désert", 0, "3 à 5 ans", "280 à 510 g", 1, 0, "Deserts", 'i', 'ex'),
    ("Girafe", 0, "10 à 15 ans", "550 à 1 200 kg", 0, 2, "Savanes", 'h', 'ex'),
    ("Lion de mer de Steller", 0, "25 ans", "300 à 1 100 kg", 1, 1, "Nord de l'océan Pacifique", 'p', 'aq'),
    ("Ouistiti à tête jaune", 0, "10 à 16 ans", "230 à 450 g", 1, 4, "Forêt Atlanque", 'o', 'cg'),
    ("Chouette forestiere", 0, "jusqu'à 16 ans", "160 à 180 g", 0, 3, "Plaines et de collines du sous-continent indien", 'c', 'vl'),
    ("Panthere des neiges", 0, "16 à 18 ans", "40 à 55 kg", 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg'),
    ("Elephant de foret d'Afrique", 0, "60 à 70 ans", "2 700 à 6 000 kg", 1, 4, "Forêt dense d'Afrique centrale et d'Afrique de l'Ouest", 'h', 'ex'),
    ("Beluga", 0, "35 à 50 ans", "Environ 1 400 kg", 0, 0, "Eaux arctiques et subarctiques", 'p','aq'),
    ("Panda roux", 0, "8 à 18 ans", "3 à 6 kg", 3, 3, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex'),
    ("Python royal", 0, "Environ 30 ans", "1 à 2 kg", 2, 1, "Territoire allant du Sénégal jusqu'à l'ouest de l'Ouganda et au nord de la République démocratique du Congo.", 'c','tr'),
    ("Rainette jaguar", 0, "5 à 10 ans", "3g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude", 'i','tr')
;
    
insert into Nourriture (description_plat) values
    ('Boeuf'),
    ('Volaille'),

    ('Bambou'),
    ('Branchages'),
    ('Pomme'),
    ('Poire'),
    ('Carotte'),
    ('Ecorces'),
    ('Herbes'),

    ('Insectes'),
    ('Sardines'),
    ('Maquereaux')
;

insert into Convenir values 
    (1,'c'),(1,'o'),
    (2,'c'),(2,'o'),

    (3,'h'),(3,'o'),
    (4,'h'),(4,'o'),
    (5,'h'),(5,'o'),
    (6,'h'),(6,'o'),
    (7,'h'),(7,'o'),
    (8,'h'),(8,'o'),
    (9,'h'),(9,'o')
;

insert into Soigneur (date_naissance_soign, nom_soign, prenom_soign, sexe_soign) values 
    ('2002-10-16','Nulli','Enzo','M'),
    ('2001-09-03','Marquis','Zoé','F')
;

insert into Enclos (nb_max, taille, id_type_enclos) values 
    (5, 6, 'aq'),
    (3, 8, 'aq'),
    (2, 10,'vl'),
    (1, 9,'vl'),
    (2, 6, 'tr'),
    (1, 8, 'tr'),
    (2, 10,'cg'),
    (4, 20,'cg'),
    (3, 100,'ex'),
    (4, 200,'ex')
;

insert into Animal values 
    ("Eric", '2003-07-08', 'Male', '345.0', null, "Herisson du désert", 2),

    ("Moussa", '1985-04-16', 'Male', '5654.5', null, "Elephant de foret d'Afrique", 1),
    ("Camila", '1988-07-21', 'Femelle', '4378.9', null, "Elephant de foret d'Afrique", 1),
    ("Gaby", '2008-03-04', 'Male', '3452.7', "né dans le zoo", "Elephant de foret d'Afrique", 1)
;

insert into AvoirParent values 
    ("Moussa","Gaby"),
    ("Camila","Gaby")
;

insert into Occuper values 
    ("Moussa", 9, '2000-01-05', null),
    ("Camila", 9, '2000-01-05', null),
    ("Gaby", 9, '2008-03-04', null)
;

/*
insert into Animation values
    (
;
*/
