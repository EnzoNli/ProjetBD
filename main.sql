.open zoo.db
pragma foreign_keys = true;
.headers on
.mode column


create table TypeEnclos(
	id_type_enclos		char(2)		primary key,
	description_type	varchar(50)
);

create table CategorieNourriture(
	id_categorie	char(1)		primary key,
	description_cat	varchar(50)
);

create table Espece(
	race	varchar(30)	primary key,
	nb_dans_zoo	int		check(nb_dans_zoo>=0),
	espe_vie	varchar(30)		not null,
	espe_poids_adulte	varchar(30)		not null,
	dangerosite	int		check(0<=dangerosite and dangerosite<=5)	not null,
	menace_extinction	int		check(0<=menace_extinction and menace_extinction<=5)	not null,
	habitat_nat		varchar(30),
	id_categorie	char(1)		references CategorieNourriture(id_categorie),
	id_type_enclos	char(2)		references TypeEnclos(id_type_enclos)
);

create table Enclos(
	id_enclos	integer		primary key		autoincrement,
	nb_actuel	int 	check(nb_actuel >= 0 and nb_actuel<=nb_max) default 0,
	nb_max		int		check(nb_max>0),
	taille		int		not null,
	id_type_enclos		char(2)		references TypeEnclos(id_type_enclos)
);

create table Animal(
	nom		varchar(30)		primary key,
	date_naissance_anim		date  	not null,
	genre	varchar(7)	check(genre in ('Male','Femelle'))  not null,
	poids	float		check(poids>0)	not null,
	origine	varchar(30),
	race 	varchar(30)		references Espece(race),
	id_soign 	int 	references Soigneur(id_soign),
	id_enclos	int		references Enclos(id_enclos),
	date_arrivee_zoo	date 	default(date('now'))
);

create table Nourriture(
	id_plat		integer		primary key		autoincrement,
	description_plat		varchar(50)
);

create table Soigneur(
	id_soign		integer		primary key		autoincrement,
	date_naissance_soign	date,	--check avant aujourdhui moins 18 ans ?
	nom_soign	 	varchar(30)		not null,
	prenom_soign	varchar(30)		not null,
	sexe_soign		char(1)			check(sexe_soign in ('M', 'F'))
);

create table Animation(
	id_anim		integer		primary key		autoincrement,
	duree		int		check(duree > 20)	not null,
	description_anim	varchar(50),
	id_soign	int		references Soignant(id_soign)
);

-- associations

create table AvoirParent(
	parent		varchar(30)		references Animal(nom),
	enfant		varchar(30)		references Animal(nom),
	constraint 	pkAvoirParent	primary key (parent, enfant)
);

create table Convenir(
	id_plat		int 	references Nourriture(id_plat),
	id_categorie	char(1)		references CategorieNourriture(id_categorie),
	constraint 	pkConvenir	primary key (id_plat, id_categorie)
);

create table AvoirLieu(
	id_anim 	int 	references Animation(id_anim),
	id_enclos 	int 	references Enclos(id_enclos),
	date_anim	date, --check?
	heure_anim	time, --check??
	constraint	pkAvoirLieu	primary key (id_anim, id_enclos)
);

-- view
create view NombreAnimauxParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from TypeEnclos natural join Enclos natural join Animal
	group by id_type_enclos
;

create view NombreAnimauxParEspece as
	select race, count(1) as nombre
	from Espece natural join Animal
	group by race
;

create view EnclosVide as
	select id_enclos
	from Enclos
	where nb_actuel = 0
;
create view EnclosNonVide as
	select id_enclos
	from Enclos
	where nb_actuel > 0
;
create view EnclosPlein as
	select id_enclos
	from Enclos
	where nb_actuel = nb_max
;

create view ListePlatParCategorie as
	select id_categorie, description_plat
	from CategorieNourriture natural join Convenir natural join Nourriture
;
create view ListeNourritureParRace as
	select race, description_plat
	from Espece natural join ListePlatParCategorie
;

create view ListeAnimalPourSoigneur as
	select nom_soign, prenom_soign, nom
	from Soigneur natural join Animal
;

create view AnimationAujourdhui as
	select id_anim
	from Animation
	where date_anim = DATE('nom')
;

create view EnfantsDuZoo as
	select distinct enfant as noms
	from AvoirParent
;

create view TypeEnclosParRace as
    select race, id_type_enclos
    from Espece natural join TypeEnclos
;

create view RaceParEnclos as
    select distinct id_enclos, race
    from Enclos natural join Animal
;

create view AnimauxParSoigneur as 
	select nom, prenom_soign, nom_soign
	from Animal natural join Soigneur
;



-- triggers

create trigger IncrementeEspeceEtEnclos
after insert on Animal
begin
	update Espece set nb_dans_zoo = nb_dans_zoo + 1 where race = new.race;

	update Enclos set nb_actuel = nb_actuel + 1 where id_enclos = new.id_enclos;
end;

create trigger EmpecheAjoutAnimal
before insert on Animal
begin
	select
		case 
			when ( new.id_enclos in EnclosPlein ) 
			then raise(abort, 'ERREUR : cet enclos est plein !')

            when 	(select id_type_enclos 
					from Animal natural join Espece natural join TypeEnclos
					where new.race = race) <> (select id_type_enclos 
												from Enclos natural join TypeEnclos
												where new.id_enclos = id_enclos)
			then raise(abort, 'ERREUR : cet animal ne peut pas vivre dans ce type d enclos !')
		
			when (new.race <> (select race
								from RaceParEnclos
								where id_enclos = new.id_enclos) )
			then raise(abort, 'ERREUR : une autre espèce habite déjà ici !')
		end;
end;







-- insertions

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
    ("Eric", '2003-07-08', 'Male', 345.0, null, "Herisson du désert", 2, 10, date('now')),
    ("Moussa", '1985-04-16', 'Male', 5654.5, null, "Elephant de foret d'Afrique", 1, 9, '2000-01-05'),
    ("Camila", '1988-07-21', 'Femelle', 4378.9, null, "Elephant de foret d'Afrique", 1, 9, '2000-01-05'),
    ("Gaby", '2008-03-04', 'Male', 3452.7, "né dans le zoo", "Elephant de foret d'Afrique", 1, 9, '2008-03-04')
;

insert into AvoirParent values
    ("Moussa","Gaby"),
    ("Camila","Gaby")
;


/*
insert into Animation values
    (
;
insert into AvoirLieu values
	(
;
*/


--TESTS ERREURS ! 
-- vérif l'incrémentation
-- enclos plein
insert into Animal values ("Test1", '1988-07-21', 'Femelle', 4378.9, null, "Elephant de foret d'Afrique", 1, 9, '2000-01-05');
-- mauvais type d'enclos
insert into Animal values ("Test2", '1988-07-21', 'Femelle', 4378.9, null, "Elephant de foret d'Afrique", 1, 1, '2000-01-05');
-- autre espece y habite deja
insert into Animal values ("Test3", '1988-07-21', 'Femelle', 4378.9, null, "Elephant de foret d'Afrique", 1, 10, '2000-01-05');
