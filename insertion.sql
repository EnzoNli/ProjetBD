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
    ("Lion de mer de Steller", "25 ans", "300 à 1 100 kg", 1, 1, "Nord de l'océan Pacifique", 'p'),
    ("Ouistiti à tête jaune", "10 à 16 ans", "230 à 450 g", 1, 4, "Forêt Atlanque", 'o'),
    ("Chouette forestiere", "jusqu'à 16 ans", "160 à 180 g", 0, 3, "Plaines et de collines du sous-continent indien", 'c'),
    ("Panthere des neiges", "16 à 18 ans", "40 à 55 kg", 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o'),

    





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