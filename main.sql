pragma foreign_keys = true;

create table TypeEnclos(
	id_type_enclos		char(2)		primary key,
	description_type	varchar(200),
	titre 				varchar(20)
);

create table CategorieNourriture(
	id_categorie	char(1)		primary key,
	description_cat	varchar(50)
);

create table Espece(
	race		varchar(30)	primary key,
	nb_dans_zoo	int		check(nb_dans_zoo>=0) default(0),
	espe_vie	varchar(30)		not null,
	espe_poids_adulte	varchar(30)		not null,
	poids_moyen_zoo 	float	check(poids_moyen_zoo>=0) default(0),
	dangerosite			int		check(0<=dangerosite and dangerosite<=5)	not null,
	menace_extinction	int		check(0<=menace_extinction and menace_extinction<=5)	not null,
	habitat_nat			varchar(100),
	id_categorie		char(1)		references CategorieNourriture(id_categorie),
	id_type_enclos		char(2)		references TypeEnclos(id_type_enclos),
	photo 				varchar(20)		default(null)
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
	race 	varchar(30)		references Espece(race),
	id_enclos	int		references Enclos(id_enclos),
	date_naissance_anim		date  	not null,
	genre	varchar(7)	check(genre in ('Male','Femelle'))  not null,
	poids	float		check(poids>0)	not null,
	origine	varchar(30),
	id_soign 	int 	references Soigneur(id_soign),
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
	genre_soign		char(1)			check(genre_soign in ('M', 'F'))
);

create table Animation(
	id_anim		integer		primary key		autoincrement,
	duree		int		check(duree > 15)	not null,
	description_anim	varchar(50),
	id_soign	int		references Soigneur(id_soign)
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
	id_avoirlieu 	integer 	primary key		autoincrement,
	id_anim 	int 	references Animation(id_anim),
	id_enclos 	int 	references Enclos(id_enclos),
	date_anim	date, --check?
	heure_debut	time, --check??
	heure_fin	time default(null)
); --logique ? ajouter date en clef primaire ? ou int en primary key 

create table Mange(
	race 	varchar(30) 	references Espece(race),
	id_plat integer 	references Nourriture(id_plat),
	constraint pkMange primary key (race, id_plat)
);

-- lier espece et nourriture
-- verif bonne categorie --> trigger

-- peuvent cohabiter ?











-- view

-- pour la page 'Animaux'
create view NombreEspecesParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from espece natural join typeenclos
	where nb_dans_zoo > 0
	group by id_type_enclos
;

-- ??
create view NombreAnimauxParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from TypeEnclos natural join Enclos natural join Animal
	group by id_type_enclos
;

-- pour la page par espece
create view NombreAnimauxParEspece as
	select race, count(1) as nombre
	from Espece natural join Animal
	group by race
;

-- ??
create view EnclosVide as
	select id_enclos
	from Enclos
	where nb_actuel = 0
;

-- ??
create view EnclosNonVide as
	select id_enclos
	from Enclos
	where nb_actuel > 0
;

-- pour trigger EmpecheAjoutAnimal
create view EnclosPlein as
	select id_enclos
	from Enclos
	where nb_actuel = nb_max
;

-- ? pour la page nourriture ?
create view ListePlatParCategorie as
	select id_categorie, description_plat
	from CategorieNourriture natural join Convenir natural join Nourriture
;

-- pour la page par espece
create view ListeNourritureParRace as
	select race, description_plat
	from Espece natural join ListePlatParCategorie
;

-- pour la page soigneur
create view ListeAnimalPourSoigneur as
	select id_soign, nom
	from Soigneur natural join Animal
;

-- pour la page animation
create view AnimationAujourdhui as
	select id_anim
	from Animation
	where date_anim = DATE('nom')
;

-- pour la page d'un animal
create view EnfantsDuZoo as
	select distinct enfant as noms
	from AvoirParent
;

-- ??
create view TypeEnclosParRace as
    select race, id_type_enclos
    from Espece natural join TypeEnclos
;

-- pour la page d'accueil
create view NombreTotalAnimauxZoo as
	select count(1) as nombre
	from Animal
;

-- pour la page 'Animaux'
create view NombreTypeEnclos as 
	select count(1) as nombre
	from TypeEnclos
;

-- pour trigger EmpecheAjoutAnimal
create view RaceParEnclos as
    select distinct id_enclos, race
    from Enclos natural join Animal
;



/*
create view DateAnimationParSoigneur as 
	select id_soign, date_anim, id_anim
	from Animation natural join AvoirLieu
;

create view SoigneurParAnimation as 
	select id_soign, id_anim
	from Animation
;

create view SoigneurParDateAnimation as 
	select id_soign, date_anim
	from Animation natural join AvoirLieu
;


create view DureeParAvoirLieu as 
	select id_anim, id_avoirlieu, duree
	from AvoirLieu natural join Animation
;
/*
create view HeuresParAvoirLieu as 
	select id_avoirlieu as id, heure_anim as heure_debut, time(heure_anim, '+' ||
	(select duree
	from DureeParAvoirLieu
	where id_avoirlieu = id)
	||' minutes') as heure_fin
	from AvoirLieu
;
*/

/*
create trigger Animmmmm
before insert on AvoirLieu
begin
	select 
		case 
			when 
*/
/*
with debut_animation as (
	select id_avoirlieu, heure_anim as heure_debut
*/
/*
create view Heures as 
	select id_avoirlieu, id_anim, heure_debut, heure_fin
	from Animation natural join AvoirLieu
;

create view copieAvoirLieu as 
	select * from AvoirLieu;

create trigger HeureFin
instead of insert on copieAvoirLieu
begin
	with heuref as (
		select 
	insert into Heures(id_avoirlieu, id_anim, heure_debut, heure_fin)
	values (new.id_avoirlieu, new.id_anim, new.heure_debut,
	time(heure_debut, '+'||
	(select duree 
	from Animation
	where id_anim = new.id_anim)
	||' minutes'));

end;

*/

-- triggers

create trigger MisAJourAjoutAnimal
after insert on Animal
begin
	-- incrémente espece et enclos
	update Espece set nb_dans_zoo = nb_dans_zoo + 1 where race = new.race;
	update Enclos set nb_actuel = nb_actuel + 1 where id_enclos = new.id_enclos;
	-- met à jour le poids moyen de l'espèce dans le zoo
	update Espece set poids_moyen_zoo = (select avg(poids) 
										from Animal natural join Espece
										where race = new.race
										group by race)	where race = new.race;
end;

create trigger MisAJourSupprAnimal
after delete on Animal
begin
	--décrémente espece et enclos
	update Espece set nb_dans_zoo = nb_dans_zoo - 1 where race = old.race;
	update Enclos set nb_actuel = nb_actuel - 1 where id_enclos = old.id_enclos;
	-- met à jour le poids moyen de l'expèce dans le zoo
	update Espece set poids_moyen_zoo = (select avg(poids) 
										from Animal natural join Espece
										where race = old.race
										group by race)	where race = old.race;
end;

create trigger MisAJourPoids
after update of poids on Animal
begin
	-- met à jour le poids moyen dans zoo
	update Espece set poids_moyen_zoo = (select avg(poids) 
										from Animal natural join Espece
										where race = old.race
										group by race)	where race = old.race;
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

create trigger EnleveLienParente
after delete on Animal
begin
	--"delete on cascade"
	delete from AvoirParent where parent = old.nom or enfant = old.nom;
end;

-- ajoute une nourriture, l'associe à un/plusieurs type(s)

-- ajoute une animation

-- ajoute à un animal une nourriture (menu déroulant) (des plats ok pour sa catégorie et qu'il n'a pas déjà, mais quand meme faire trigger (gestion d'erreur))
-- nourriture --> clef primaire ??
create trigger AjouteNourritureAUneEspece
before insert on Mange
begin
	select 
		case 
			when 	(select id_categorie
					from Espece
					where race = nex.race) 	not in  (select id_categorie 
													from Nourriture
													where id_plat = new.id_plat)
			then raise(abort, 'ERREUR : cette espèce ne peut pas manger de cette nourriture !')
		end;
end;
-- à tester !
			

-- ajout animation 
-- vérif que soigneur pas déjà occuper dans autre animation pendant
-- calcul date début + durée ?

-- ajout animation ? max 3 types d'animation par soigneur !
-- ajouter un lien de parenté

create trigger EmpecheAjoutAvoirLieu
before insert on AvoirLieu
begin
	select *
	from Animation natural join AvoirLieu
	where 
			case 	
			when 	(select id_soign
					from Animation
					where id_anim = new.id_anim)=id_soign 
					
					and new.date_anim = date_anim 
					
					and (heure_debut between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																						from Animation
																						where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'erreur au debut' )

			when 	(select id_soign
					from Animation
					where id_anim = new.id_anim)=id_soign 
					
					and new.date_anim = date_anim 

					and (heure_fin between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																						from Animation
																						where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'erreur(fin) ERREUR : le soigneur est déjà occupé sur une autre animation au moment sélectionné !')
			
	end;																				
end;
-- à tester

create trigger CalculeDateFinAvoirLieu
after insert on AvoirLieu
begin 
	update AvoirLieu set heure_fin = time(new.heure_debut, '+'||(select duree
																from Animation
																where id_anim = new.id_anim)||' minutes') 
		where new.id_avoirlieu = id_avoirlieu;
end;

-- à tester
















































-- insertions

insert into CategorieNourriture values
    ('o',"omnivore : mange des aliments d'origines végétale et animale"),
    ('h',"herbivore : se nourrit d'herbes et de plantes basses"),
    ('c',"carnivore : son régime alimentaire est principalement basé sur la consommation de chairs ou de tissus d'animaux vivants ou morts"),
    ('i',"insectivore : se nourrit d'insectes ou d'autres arthropodes."),
    ('p',"piscivore : se nourrit de poissons.")
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

insert into Soigneur (date_naissance_soign, nom_soign, prenom_soign, genre_soign) values
    ('2002-10-16','Nulli','Enzo','M'),
    ('2001-09-03','Marquis','Zoé','F')
;

insert into TypeEnclos values
    ('aq', "Un aquarium est un réservoir rempli d'eau dans lequel vivent des animaux et/ou des plantes aquatiques","Aquarium"),
    ('ex',"blabla extérieur","Enclos extérieur"),
    ('cg', "Une cage est un contenant ajouré, le plus souvent grillagé ou à barreaux, destiné à contenir un animal.","Cage"),
    ('vl', "Une volière est un enclos assez vaste ordinairement grillagé, généralement une grande cage, où l'on conserve, élève et nourrit des oiseaux d'ornement.","Volière"),
    ('tr', "Un terrarium est un milieu confiné imitant le biotope de certaines espèces animales et/ou végétales. Il est l'équivalent d'un aquarium dont l'eau serait remplacée par un substrat de quelques centimètres d'épaisseur disposé sur le fond.","Terrarium")
;

insert into Espece values
	("Lion de mer de Steller", 0, "25 ans", "300 à 1 100 kg", 0, 1, 1, "Nord de l'océan Pacifique", 'p', 'aq','beluga.jpg'),
	("Béluga", 0, "35 à 50 ans", "Environ 1 400 kg", 0, 0, 0, "Eaux arctiques et subarctiques", 'p','aq','beluga.jpg'),
		-- a completer
	("Grande raie-guitare", 0, "0", "0", 0, 0, 0, "0", 'p','aq','beluga.jpg'),
	("Méduse dorée", 0, "0", "0", 0, 0, 0, "0", 'p','aq','beluga.jpg'),
	("Boto", 0, "0", "0", 0, 0, 0, "0", 'p','aq','beluga.jpg'),


	("Python royal", 0, "Environ 30 ans", "1 à 2 kg", 0, 2, 1, "Territoire allant du Sénégal jusqu'à l'ouest de l'Ouganda et au nord de la République démocratique du Congo.", 'c','tr', 'beluga.jpg'),
    ("Rainette jaguar", 0, "5 à 10 ans", "3g en moyenne", 0, 4, 0, "Forêts tropicales humides de basse altitude", 'i','tr', 'beluga.jpg'),
		-- a completer
	("Tortue des Seychelles", 0, "0", "0", 0, 0, 0, "0", 'h','tr', 'beluga.jpg'),


    ("Panda géant", 0, "20 à 25 ans", "70 à 120 kg", 0, 3, 2, "Forets de bambous", 'h', 'ex', 'beluga.jpg'),
    ("Hérisson du désert", 0, "3 à 5 ans", "280 à 510 g", 0, 1, 0, "Deserts", 'i', 'ex', 'beluga.jpg'),
    ("Girafe", 0, "10 à 15 ans", "550 à 1 200 kg", 0, 0, 2, "Savanes", 'h', 'ex', 'beluga.jpg'),
	("Eléphant de forêt d'Afrique", 0, "60 à 70 ans", "2 700 à 6 000 kg", 0, 1, 4, "Forêt dense d'Afrique centrale et d'Afrique de l'Ouest", 'h', 'ex', 'beluga.jpg'),
    ("Panda roux", 0, "8 à 18 ans", "3 à 6 kg", 0, 3, 3, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'beluga.jpg'),
    
    ("Ouistiti à tête jaune", 0, "10 à 16 ans", "230 à 450 g", 0, 1, 4, "Forêt Atlanque", 'o', 'cg', 'beluga.jpg'),
	("Panthère des neiges", 0, "16 à 18 ans", "40 à 55 kg", 0, 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg', 'beluga.jpg'),

    ("Chouette forestière", 0, "jusqu'à 16 ans", "160 à 180 g", 0, 0, 3, "Plaines et de collines du sous-continent indien", 'c', 'vl', 'beluga.jpg')
    
;

insert into Enclos (nb_max, taille, id_type_enclos) values
    (5, 60, 'aq'), --1 ?
    (4, 400, 'aq'), --2 Boto
	(2, 150, 'aq'), --3 Raie
    (4, 200, 'aq'), --4 Lion Mer
	(6, 70, 'aq'), --5 Méduse
    (3, 300, 'aq'), --6 Beluga

	(2, 6,'tr'), --7 Python
    (2, 3,'tr'), --8 Rainette
    (3, 14,'tr'), --9 Tortue

	(6, 100,'ex'), --10 Hérisson
	(3, 150,'ex'), --11 Panda géant
	(8, 200,'ex'), --12 Panda roux 7
	(4, 300,'ex'), --13 Girafe 3
    (3, 500,'ex') --14 Eléphant 3
/*
    (2, 6, 'vl'), --10
    (1, 8, 'vl'), --11

    (2, 10,'cg'), --12
    (4, 20,'cg'), --13
*/
;

insert into Animal values
		--aquarium
	("Boto1", "Boto", 2,'2003-07-08', 'Male', 300.0, null,  2, date('now')),
	("Boto2", "Boto", 2,'2003-07-08', 'Male', 200.0, null,  2, date('now')),
	("Boto3", "Boto", 2,'2003-07-08', 'Male', 800.0, null,  2, date('now')),
	("Boto4", "Boto", 2,'2003-07-08', 'Male', 700.0, null,  2, date('now')),

	("Raie1", "Grande raie-guitare", 3, '2003-07-08', 'Male', 345.0, null,  2, date('now')),
	("Raie2", "Grande raie-guitare", 3, '2003-07-08', 'Male', 345.0, null,  2, date('now')),
	
	("Lion1", "Lion de mer de Steller", 4, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Lion2", "Lion de mer de Steller", 4,'2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Lion3", "Lion de mer de Steller", 4,'2003-07-08', 'Male', 345.0, null, 2, date('now')),

	("Méduse1", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Méduse2", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Méduse3", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Méduse4", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Méduse5", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2, date('now')),

	("Beluga1", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Beluga2", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Beluga3", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2, date('now')),

		--terrarium
	("Python1", "Python royal", 7, '2003-07-08', 'Male', 345.0, null, 2, date('now')),

	("Rainette1", "Rainette jaguar", 8, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Rainette2", "Rainette jaguar", 8, '2003-07-08', 'Male', 345.0, null, 2, date('now')),

	("Tortue1", "Tortue des Seychelles", 9, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Tortue2", "Tortue des Seychelles", 9, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Tortue3", "Tortue des Seychelles", 9, '2003-07-08', 'Male', 345.0, null, 2, date('now')),

		-- extérieur
	("Enzo", "Hérisson du désert", 10, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Eric", "Hérisson du désert", 10, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Edgar", "Hérisson du désert", 10, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Elsa", "Hérisson du désert", 10, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),
	("Emilie", "Hérisson du désert", 10, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),

	("Ugo", "Panda géant", 11, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Ugette", "Panda géant", 11, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),
	("Uta", "Panda géant", 11, '2003-07-08', 'Femelle', 345.0, "née dans le zoo", 2, date('now')),

	("Rémi", "Panda roux", 12, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Raoul", "Panda roux", 12, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Ron", "Panda roux", 12, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Rosie", "Panda roux", 12, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),
	("Roxane", "Panda roux", 12, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),
	("Raymonde", "Panda roux", 12, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),

    ("Nicolas", "Girafe", 13, '2003-07-08', 'Male', 345.0, null, 2, date('now')),
	("Nina", "Girafe", 13, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),
	("Naomi", "Girafe", 13, '2003-07-08', 'Femelle', 345.0, null, 2, date('now')),

    ("Moussa", "Eléphant de forêt d'Afrique", 14, '1985-04-16', 'Male', 5654.5, null, 1, '2000-01-05'),
    ("Margot", "Eléphant de forêt d'Afrique", 14, '1988-07-21', 'Femelle', 4378.9, null, 1, '2000-01-05'),
    ("Milan", "Eléphant de forêt d'Afrique", 14, '2008-03-04', 'Male', 3452.7, "né dans le zoo", 1, '2008-03-04')
;

insert into AvoirParent values
    ("Moussa","Milan"),
    ("Margot","Milan"),
	("Ugo","Uta"),
	("Ugette","Uta")
;


insert into Animation(duree, description_anim, id_soign) values
    (20, 'dancer les dauphins', 1),
	(30, 'caresser les ouistitis', 2)
;

insert into AvoirLieu(id_anim, id_enclos, date_anim, heure_debut) values
	(1, 1, date('now'), '12:55'),
	(2, 9, date('now'), '12:35'),
	(2, 1, date('now'), '13:34')
;



/*
--TESTS ERREURS ! 
-- vérif l'incrémentation
-- enclos plein
insert into Animal values ("Test1", '1988-07-21', 'Femelle', 4378.9, null, "Eléphant de forêt d'Afrique", 1, 14, '2000-01-05');
-- mauvais type d'enclos
insert into Animal values ("Test2", '1988-07-21', 'Femelle', 4378.9, null, "Eléphant de forêt d'Afrique", 1, 1, '2000-01-05');
-- autre espece y habite deja
insert into Animal values ("Test3", '1988-07-21', 'Femelle', 4378.9, null, "Eléphant de forêt d'Afrique", 1, 18, '2000-01-05');
*/

