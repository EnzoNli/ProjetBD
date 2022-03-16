insert into CategorieNourriture
values 
    ('o',"omnivore : mange des aliments d'origines végétale et animale"),
    ('h',"herbivore : se nourrit d'herbes et de plantes basses"),
    ('c',"carnivore : son régime alimentaire est principalement basé sur la consommation de chairs ou de tissus d'animaux vivants ou morts"),
    ('i',"insectivore : se nourrit d'insectes ou d'autres arthropodes."),
    ('p',"piscivore : se nourrit de poissons.")
;

insert into TypeEnclos
values
    ('aq', "Un aquarium est un réservoir rempli d'eau dans lequel vivent des animaux et/ou des plantes aquatiques"),
    ('cg', "Une cage est un contenant ajouré, le plus souvent grillagé ou à barreaux, destiné à contenir un animal."),
    ('vl', "Une volière est un enclos assez vaste ordinairement grillagé, généralement une grande cage, où l'on conserve, élève et nourrit des oiseaux d'ornement."),
    ('tr', "Un terrarium est un milieu confiné imitant le biotope de certaines espèces animales et/ou végétales. Il est l'équivalent d'un aquarium dont l'eau serait remplacée par un substrat de quelques centimètres d'épaisseur disposé sur le fond.")
;

insert into Espece
values
    ("Panda geant", 0, "20 à 25 ans", "70 à 120 kg", 3, 2, "Forets de bambous", 'h'),
    ("Herisson du désert", 0, "3 à 5 ans", "280 à 510 g", 1, 0, "Deserts", 'i'),
    ("Girafe", 0, "10 à 15 ans", "550 à 1 200 kg", 0, 2, "Savanes", 'h'),
    ("Lion de mer de Steller", 0, "25 ans", "300 à 1 100 kg", 1, 1, "Nord de l'océan Pacifique", 'p'),
    ("Ouistiti à tête jaune", 0, "10 à 16 ans", "230 à 450 g", 1, 4, "Forêt Atlanque", 'o'),
    ("Chouette forestiere", 0, "jusqu'à 16 ans", "160 à 180 g", 0, 3, "Plaines et de collines du sous-continent indien", 'c'),
    ("Panthere des neiges", 0, "16 à 18 ans", "40 à 55 kg", 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o'),
    ("Elephant de foret d'Afrique", 0, "60 à 70 ans", "2 700 à 6 000 kg", 1, 4, "Forêt dense d'Afrique centrale et d'Afrique de l'Ouest", 'h'),
    ("Beluga", 0, "35 à 50 ans", "Environ 1 400 kg", 0, 0, "Eaux arctiques et subarctiques", 'p'),
    ("Panda roux", 0, "8 à 18 ans", "3 à 6 kg", 3, 3, "Présent en Asie, dans la chaîne de l’Himalaya", 'o'),
    ("Python royal", 0, "Environ 30 ans", "1 à 2 kg", 2, 1, "Territoire allant du Sénégal jusqu'à l'ouest de l'Ouganda et au nord de la République démocratique du Congo.", 'c'),
    ("Rainette jaguar", 0, "5 à 10 ans", "3g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude", 'i'),
    
    

    





insert into Nourriture 
values
    ('Boeuf'),
    ('Bambou'),
    ('Branchages'),
    ('Volaille'),
    ('Pomme'),
    ('Poire'),
    ('Carotte'),
    ('Ecorces'),
    ('Herbes'),

    ('Insectes'),
    ('Sardines'),
    ('Maquereaux'),
;

insert into Convenir --inverser avec int clef primaire
values 
    ('Boeuf','c'),('Boeuf','o'),
    ('Volaille','c'),('Volaille','o'),

    ('Bambou','h'),('Bambou','o'),
    ('Branchages','h'),('Branchages','o'),
    ('Pomme','h'),('Pomme','o'),
    ('Poire','h'),('Poire','o'),
    ('Carotte','h'),('Carotte','o'),
    ('Ecorces','h'),('Ecorces','o'),
    ('Herbes','h'),('Herbes','o');


insert into Enclos
values 
    (0, 5, 6, 'aq', 4),
    (0, 3, 8, 'aq', 4),
