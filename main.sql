pragma foreign_keys = true;

create table TypeEnclos(
	id_type_enclos		char(2)		primary key,
	description_type	varchar(200),
	titre_type_enclos 				varchar(20)
);

create table CategorieNourriture(
	id_categorie	char(1)		primary key,
	titre_categorie varchar(20),
	description_cat	varchar(50)
);

create table Espece(
	race		varchar(30)	primary key,
	nb_dans_zoo	int		check(nb_dans_zoo>=0) default(0),
	espe_vie	varchar(30)		not null,
	espe_poids_adulte	varchar(30)		not null,
	poids_moyen_zoo 	float	check(poids_moyen_zoo>=0) default(0),
	dangerosite			int		check(0<=dangerosite and dangerosite<=5)	not null,
	menace_extinction	int		check(-1<=menace_extinction and menace_extinction<=5)	not null,
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
	date_naissance_animal		date  	not null,
	genre	varchar(7)	check(genre in ('Male','Femelle'))  not null,
	poids	float		check(poids>0)	not null,
	origine	varchar(30),
	id_soign 	int 	references Soigneur(id_soign)
);

create table Nourriture(
	id_plat	    varchar(15)	primary key
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
	duree		int		check(duree >= 15)	not null,
	description_anim	varchar(50),
	id_soign	int		references Soigneur(id_soign),
	race char(30) references Espece(race)
);

-- associations

create table AvoirParent(
	parent		varchar(30)		references Animal(nom),
	enfant		varchar(30)		references Animal(nom),
	constraint 	pkAvoirParent	primary key (parent, enfant)
);

create table Convenir(
	id_plat		varchar(15)	references Nourriture(id_plat),
	id_categorie	char(1)		references CategorieNourriture(id_categorie),
	constraint 	pkConvenir	primary key (id_plat, id_categorie)
);

create table Planning(
	id_planning 	integer 	primary key		autoincrement,
	id_anim 	int 	references Animation(id_anim),
	id_enclos 	int 	references Enclos(id_enclos),
	date_anim	date 	,--check(date_anim >= date('now')), --check?
	heure_debut	time	not null, --check??
	heure_fin	time 	default(null)
);

create table Manger(
	race 	varchar(30) 	references Espece(race),
	id_plat varchar(15) 	references Nourriture(id_plat),
	constraint pkManger primary key (race, id_plat)
);




















































-- view


-- pour la page d'accueil
create view NombreTotalAnimauxZoo as
	select count(1) as nombre
	from Animal
;

-- pour la page 'Animaux'
create view NombreEspecesParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from espece natural join typeenclos
	where nb_dans_zoo > 0
	group by id_type_enclos
;
create view NombreTypeEnclos as 
	select count(1) as nombre
	from TypeEnclos
;

-- pour la page espece
create view NombreAnimauxParEspece as
	select race, count(1) as nombre
	from Espece natural join Animal
	group by race
;
create view ListeNourritureParRace as
	select race, description_plat
	from Espece natural join ListePlatParCategorie
;

-- pour la page d'un animal
create view EnfantsDuZoo as
	select distinct enfant as noms
	from AvoirParent
;

-- pour la page soigneur
create view ListeAnimalPourSoigneur as
	select id_soign, nom
	from Soigneur natural join Animal
;

-- pour trigger EmpecheAjoutAnimal
create view RaceParEnclos as
    select distinct id_enclos, race
    from Enclos natural join Animal
;
create view EnclosPlein as
	select id_enclos
	from Enclos
	where nb_actuel = nb_max
;





-- ??
create view NombreAnimauxParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from TypeEnclos natural join Enclos natural join Animal
	group by id_type_enclos
;

-- ? pour la page nourriture ?
create view ListePlatParCategorie as
	select id_categorie, description_plat
	from CategorieNourriture natural join Convenir natural join Nourriture
;


















































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

create trigger EmpecheAjoutPlanning
before insert on Planning
begin
	select *
	from Animation natural join Planning
	where 
			case 
			when 	(select nb_actuel from Enclos where id_enclos = new.id_enclos)=0
					then raise(abort, 'ERREUR : cet enclos est vide !')

			when 	(select race from Enclos natural join Animal where id_enclos = new.id_enclos)
					<> (select race from Animation where id_anim = new.id_anim)
					then raise(abort, "ERREUR : cette animation ne peut pas avoir lieu avec les animaux dans cet enclos !" )	

			when 	(select id_soign
					from Animation
					where id_anim = new.id_anim)=id_soign 
					
					and new.date_anim = date_anim 
					
					and (heure_debut between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																						from Animation
																						where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'ERREUR : le soigneur est déjà occupé sur une autre animation au moment sélectionné !')

			when 	(select id_soign
					from Animation
					where id_anim = new.id_anim)=id_soign 
					
					and new.date_anim = date_anim 

					and (heure_fin between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																						from Animation
																						where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'ERREUR : le soigneur est déjà occupé sur une autre animation au moment sélectionné !')
			
			when 	(new.id_enclos = id_enclos)
					and new.date_anim = date_anim
					and (heure_debut between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																							from Animation
																							where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'ERREUR : il y a déjà une animation dans cet enclos au moment sélectionné !' )

			when 	(new.id_enclos = id_enclos)
					and new.date_anim = date_anim
					and (heure_fin between (new.heure_debut) and time(new.heure_debut, '+'||(select duree
																						from Animation
																						where id_anim = new.id_anim)||' minutes'))
					then raise(abort, 'ERREUR : il y a déjà une animation dans cet enclos au moment sélectionné !' )
			end;
																			
end;
 
create trigger CalculeDateFinPlanning
after insert on Planning
begin 
	update Planning set heure_fin = time(new.heure_debut, '+'||(select duree
																from Animation
																where id_anim = new.id_anim)||' minutes') 
		where new.id_planning = id_planning;
end;

-- nourriture --> clef primaire ??
create trigger AjouteNourritureAUneEspece
before insert on Manger
begin
	select 
		case 
			when 	(select id_categorie
					from Espece
					where race = new.race) 	not in  (select id_categorie 
													from Nourriture natural join Convenir
													where id_plat = new.id_plat)
			then raise(abort, 'ERREUR : cette espèce ne peut pas manger de cette nourriture !')
		end;
end;
-- à tester !

create trigger AjoutLienParente
before insert on AvoirParent
begin 
	select 
		case 
-- différentes espèces
			when 	(select race from Animal where new.enfant = nom) <> (select race from Animal where new.parent = nom)
			then raise(abort, 'ERREUR : ces animaux ne sont pas de la même espèce !')

-- déjà un parent de ce genre
			when 	(select genre
					from Animal
					where nom = new.parent) = 	(select genre 
												from Animal
												where nom = (select parent
															from AvoirParent natural join Animal
															where new.enfant = enfant))
			then raise(abort, 'ERREUR : cet enfant a déjà un parent de ce genre')

-- date naissance inférieur ?
			when 	(select date_naissance_animal from Animal where new.enfant = nom) <= (select date_naissance_animal from Animal where new.parent = nom)
			then raise(abort, "ERREUR : l'enfant ne peut pas être plus vieux que son parent !")
		end;
end;














































-- insertions

insert into CategorieNourriture values
    ('o',"Omnivore", "Mange des aliments d'origines végétale et animale"),
    ('h',"Herbivore", "Se nourrit d'herbes et de plantes basses"),
    ('c',"Carnivore", "Son régime alimentaire est principalement basé sur la consommation de chairs ou de tissus d'animaux vivants ou morts"),
    ('i',"Insectivore", "Se nourrit d'insectes ou d'autres arthropodes."),
    ('p',"Piscivore", "Se nourrit de poissons.")
;

insert into Soigneur (date_naissance_soign, nom_soign, prenom_soign, genre_soign) values
    ('2002-10-16','Nulli','Enzo','M'),
    ('2001-09-03','Marquis','Zoé','F'),
	('1979-06-30','Desjardins','Capucine','F'),
	('1979-05-14','Bérubé','Olivier','M'),
	('1998-08-14','Lamy','Arnaud','M'),
	('1987-07-20','Rouleau','Jérôme','M'),
	('1966-02-13','Adler','Bernadette','F'),
	('1977-05-14','Allaire','Gilles','M'),
	('2002-09-23','Fresne','Blanche','F'),
	('1987-01-04','Daigle','Adèle','F'),
	('1995-11-24','Bernier','Margaux','F'),
	('1980-09-04','Babin','Luc','M')
;

insert into TypeEnclos values
    ('aq', "Un aquarium est un réservoir rempli d'eau dans lequel vivent des animaux et/ou des plantes aquatiques","Aquarium"),
    ('ex',"blabla extérieur","Enclos extérieur"),
    ('cg', "Une cage est un contenant ajouré, le plus souvent grillagé ou à barreaux, destiné à contenir un animal.","Cage"),
    --('vl', "Une volière est un enclos assez vaste ordinairement grillagé, généralement une grande cage, où l'on conserve, élève et nourrit des oiseaux d'ornement.","Volière"),
    ('tr', "Un terrarium est un milieu confiné imitant le biotope de certaines espèces animales et/ou végétales. Il est l'équivalent d'un aquarium dont l'eau serait remplacée par un substrat de quelques centimètres d'épaisseur disposé sur le fond.","Terrarium")
;

insert into Espece (race, espe_vie, espe_poids_adulte, dangerosite, menace_extinction, habitat_nat, id_categorie, id_type_enclos, photo)values
-- aq
-- fait : nourriture, id_categ, id_type_enclos, espe_vie, espe_poids_adulte,menace_ectionction, photo
-- à faire : dangerosite,  habitat_nat
	("Lion de mer de Steller", "25 ans", "300 à 1 100 kg", 1, 1, "Nord de l'océan Pacifique", 'p', 'aq','lionmer.jpg'),
	("Béluga", "35 à 50 ans", "Environ 1 400 kg", 0, 4, "Eaux arctiques et subarctiques", 'p','aq','beluga.jpg'),
	("Grande raie-guitare", "20 ans", "200 kg", 0, 4, "0", 'p','aq','raie.jpg'),
	("Méduse dorée", "1 à 2 ans", "inconnu", 0, -1, "0", 'c','aq','medusedoree.jpg'),
	("Boto", "12 à 15 ans", "100 à 150 kg", 0, 3, "0", 'p','aq','boto.jpeg'),
-- tr
-- fait :  menace_extinction, photo
-- à faire : espe_vie, espe_poids_adulte, dangerosite, habitat_nat, id_categorie, id_type_enclos, nourriture
	("Python royal", "Environ 30 ans", "1 à 2 kg", 2, 1, "Territoire allant du Sénégal jusqu'à l'ouest de l'Ouganda et au nord de la République démocratique du Congo.", 'c','tr', 'pythonroyal.jpg'),
    ("Rainette jaguar", "5 à 10 ans", "3g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude", 'i','tr', 'rainettejaguar.jpg'),
	("Rainette verte d'Amérique", "5 à 10 ans", "3g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude", 'i','tr', 'rainetteverte.jpg'),
	("Rainette criarde", "5 à 10 ans", "3g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude", 'i','tr', 'rainettecriarde.jpg'),
	("Tortue géante des Seychelles", "0", "0", 0, 2, "0", 'h','tr', 'tortuegeante.jpg'),
-- ex
-- fait : menace_extinction, photo
-- à faire : espe_vie, espe_poids_adulte, dangerosite, habitat_nat, id_categorie, id_type_enclos, nourriture
    ("Panda géant", "20 à 25 ans", "70 à 120 kg", 3, 2, "Forets de bambous", 'h', 'ex', 'pandageant.jpg'),
    ("Hérisson du désert", "3 à 5 ans", "280 à 510 g", 1, 0, "Deserts", 'i', 'ex', 'herisson.jpg'),
    ("Girafe", "10 à 15 ans", "550 à 1 200 kg", 0, 2, "Savanes", 'h', 'ex', 'girafe.jpg'),
	("Eléphant de forêt d'Afrique", "60 à 70 ans", "2 700 à 6 000 kg", 1, 4, "Forêt dense d'Afrique centrale et d'Afrique de l'Ouest", 'h', 'ex', 'elephant.jpg'),
    ("Panda roux", "8 à 18 ans", "3 à 6 kg", 3, 3, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'pandaroux.jpg'),
	("Hippopotame", "8 à 18 ans", "3 à 6 kg", 3, 2, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'hippopotame.jpg'),
	("Manchot empereur", "8 à 18 ans", "3 à 6 kg", 3, 1, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'manchot.jpg'),
	("Paresseux", "8 à 18 ans", "3 à 6 kg", 3, 1, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'paresseux.jpg'),
	("Maki catta", "8 à 18 ans", "3 à 6 kg", 3, 3, "Présent en Asie, dans la chaîne de l’Himalaya", 'o','ex', 'maki.jpg'),
-- cg
-- fait :  menace_extinction, photo
-- à faire : espe_vie, espe_poids_adulte, dangerosite, habitat_nat, id_categorie, id_type_enclos, nourriture    
    ("Ouistiti à tête jaune", "10 à 16 ans", "230 à 450 g", 1, 4, "Forêt Atlanque", 'o', 'cg', 'ouistiti.jpg'),
	("Panthère des neiges", "16 à 18 ans", "40 à 55 kg", 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg', 'panthere.jpg'),
    ("Chouette forestière", "jusqu'à 16 ans", "160 à 180 g", 0, -1, "Plaines et de collines du sous-continent indien", 'c', 'cg', 'chouette.jpg'),
    ("Vautour à dos blanc", "10 à 16 ans", "230 à 450 g", 1, 4, "Forêt Atlanque", 'o', 'cg', 'vautour.jpg'),
	("Chouette lapone", "16 à 18 ans", "40 à 55 kg", 2, 0, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg', 'chouettelapone.jpg'),
    ("Harfang des neiges", "jusqu'à 16 ans", "160 à 180 g", 0, 2, "Plaines et de collines du sous-continent indien", 'c', 'cg', 'harfang.jpg'),
	("Tamarin lion", "10 à 16 ans", "230 à 450 g", 1, 3, "Forêt Atlanque", 'o', 'cg', 'tamarin.jpg'),
	("Ara militaire", "16 à 18 ans", "40 à 55 kg", 2, 2, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg', 'aramilitaire.jpg'),
	("Ara à ailes vertes", "16 à 18 ans", "40 à 55 kg", 2, 0, "Montagnes escarpées et rocheuses d'Asie", 'o', 'cg', 'ara-vertes.jpg'),
    ("Ara araraunas", "jusqu'à 16 ans", "160 à 180 g", 0, 0, "Plaines et de collines du sous-continent indien", 'c', 'cg', 'arableu.jpg')
;

insert into Enclos (nb_max, taille, id_type_enclos) values
    (5, 60, 'aq'), --1 vide
    (4, 400, 'aq'), --2 Boto
	(2, 150, 'aq'), --3 Raie
    (4, 200, 'aq'), --4 Lion Mer
	(6, 70, 'aq'), --5 Méduse
    (3, 300, 'aq'), --6 Beluga
	(5, 300, 'aq'), -- 7 vide
	(15, 300, 'aq'), -- 8 vide

	(2, 6,'tr'), --9 Python
    (2, 3,'tr'), --10 Rainette jaguar
    (3, 14,'tr'), --11 Tortue
	(2, 8,'tr'), --12 criarde
	(3, 10,'tr'), --13 verte d'amérique
	(1, 10,'tr'), --14 vide

	(6, 100,'ex'), --15 Hérisson
	(3, 150,'ex'), --16 Panda géant
	(8, 200,'ex'), --17 Panda roux 7
	(4, 300,'ex'), --18 Girafe 3
    (3, 500,'ex'), --19 Eléphant 3
	(2, 300,'ex'), -- 20 Hippopotame
	(7, 200,'ex'), -- 21 Manchot Empereur
	(3,40,'ex'),-- 22 paresseux
	(6,50,'ex'),-- 23 maki catta
	(5,500,'ex'),-- 24 vide
	(4,200,'ex'),-- 25 vide
	(3,400,'ex'),-- 26 vide 

	(2,50,'cg'), --27 panthere
	(7,70,'cg'), --28 ouistiti
	(5,60,'cg'), -- 29 tamarin
	(2,15,'cg'), -- 30 chouettes
	(2,15,'cg'), --31 
	(2,15,'cg'), -- 32
	(5,80,'cg'), --33 aras
	(4,80,'cg'), --34
	(5,80,'cg'), --35
	(1,60,'cg'), -- 36 vautour
	(1,15,'ex'), --37vide 
	(4,60,'ex'), --38vide
	(3,20,'ex')  --39vide
;

insert into Animal values
--aquarium
	("Boto1", "Boto", 2,'2003-07-08', 'Male', 300.0, null,  2),
	("Boto2", "Boto", 2,'2003-07-08', 'Male', 200.0, null,  2),
	("Boto3", "Boto", 2,'2003-07-08', 'Male', 800.0, null,  2),
	("Boto4", "Boto", 2,'2003-07-08', 'Male', 700.0, null,  2),

	("Raie1", "Grande raie-guitare", 3, '2003-07-08', 'Male', 345.0, null,  2),
	("Raie2", "Grande raie-guitare", 3, '2003-07-08', 'Male', 345.0, null,  2),
	
	("Lion1", "Lion de mer de Steller", 4, '2003-07-08', 'Male', 345.0, null, 2),
	("Lion2", "Lion de mer de Steller", 4,'2003-07-08', 'Male', 345.0, null, 2),
	("Lion3", "Lion de mer de Steller", 4,'2003-07-08', 'Male', 345.0, null, 2),

	("Méduse1", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2),
	("Méduse2", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2),
	("Méduse3", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2),
	("Méduse4", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2),
	("Méduse5", "Méduse dorée", 5,'2003-07-08', 'Male', 345.0, null, 2),

	("Beluga1", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2),
	("Beluga2", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2),
	("Beluga3", "Béluga", 6, '2003-07-08', 'Male', 345.0, null, 2),

--terrarium
	("Python1", "Python royal", 9, '2003-07-08', 'Male', 345.0, null, 2),

	("Rainette1", "Rainette jaguar", 10, '2003-07-08', 'Male', 345.0, null, 2),
	("Rainette2", "Rainette jaguar", 10, '2003-07-08', 'Male', 345.0, null, 2),

	("RV1", "Rainette verte d'Amérique", 13, '2003-07-08', 'Male', 345.0, null, 2),

	("RC1", "Rainette criarde", 12, '2003-07-08', 'Male', 345.0, null, 2),

	("Tortue1", "Tortue géante des Seychelles", 11, '2003-07-08', 'Male', 345.0, null, 2),
	("Tortue2", "Tortue géante des Seychelles", 11, '2003-07-08', 'Male', 345.0, null, 2),
	("Tortue3", "Tortue géante des Seychelles", 11, '2003-07-08', 'Male', 345.0, null, 2),

-- extérieur
	("Enzo", "Hérisson du désert", 15, '2003-07-08', 'Male', 345.0, null, 2),
	("Eric", "Hérisson du désert", 15, '2008-07-08', 'Male', 345.0, null, 2),
	("Edgar", "Hérisson du désert", 15, '2003-07-08', 'Male', 345.0, null, 2),
	("Elsa", "Hérisson du désert", 15, '2003-07-08', 'Femelle', 345.0, null, 2),
	("Emilie", "Hérisson du désert", 15, '2003-07-08', 'Femelle', 345.0, null, 2),

	("Ugo", "Panda géant", 16, '2000-07-08', 'Male', 345.0, null, 2),
	("Ugette", "Panda géant", 16, '2000-07-08', 'Femelle', 345.0, null, 2),
	("Uta", "Panda géant", 16, '2003-07-08', 'Femelle', 345.0, "née dans le zoo", 2),

	("Rémi", "Panda roux", 17, '2003-07-08', 'Male', 345.0, null, 2),
	("Raoul", "Panda roux", 17, '2003-07-08', 'Male', 345.0, null, 2),
	("Ron", "Panda roux", 17, '2003-07-08', 'Male', 345.0, null, 2),
	("Rosie", "Panda roux", 17, '2003-07-08', 'Femelle', 345.0, null, 2),
	("Roxane", "Panda roux", 17, '2003-07-08', 'Femelle', 345.0, null, 2),
	("Raymonde", "Panda roux", 17, '2003-07-08', 'Femelle', 345.0, null, 2),

    ("Nicolas", "Girafe", 18, '2003-07-08', 'Male', 345.0, null, 2),
	("Nina", "Girafe", 18, '2003-07-08', 'Femelle', 345.0, null, 2),
	("Naomi", "Girafe", 18, '2003-07-08', 'Femelle', 345.0, null, 2),

    ("Moussa", "Eléphant de forêt d'Afrique", 19, '1985-04-16', 'Male', 5654.5, null, 1),
    ("Margot", "Eléphant de forêt d'Afrique", 19, '1988-07-21', 'Femelle', 4378.9, null, 1),
    ("Milan", "Eléphant de forêt d'Afrique", 19, '2008-03-04', 'Male', 3452.7, "né dans le zoo", 1),

	("H1", "Hippopotame", 20, '1985-04-16', 'Male', 5654.5, null, 1),
    ("H2", "Hippopotame", 20, '1988-07-21', 'Femelle', 4378.9, null, 1),

	("M6", "Manchot empereur", 21, '2003-07-08', 'Male', 345.0, null, 2),
	("M5", "Manchot empereur", 21, '2003-07-08', 'Male', 345.0, null, 2),
	("M4", "Manchot empereur", 21, '2003-07-08', 'Male', 345.0, null, 2),
	("M3", "Manchot empereur", 21, '2003-07-08', 'Femelle', 345.0, null, 2),
	("M2", "Manchot empereur", 21, '2003-07-08', 'Femelle', 345.0, null, 2),

	("MK1", "Maki catta", 23, '2003-07-08', 'Male', 345.0, null, 2),
	("MK2", "Maki catta", 23, '2003-07-08', 'Male', 345.0, null, 2),
	("MK3", "Maki catta", 23, '2003-07-08', 'Male', 345.0, null, 2),

	("par1", "Paresseux", 22, '2003-07-08', 'Male', 345.0, null, 2),
	("par2", "Paresseux", 22, '2003-07-08', 'Male', 345.0, null, 2),
-- cage
	("O1", "Ouistiti à tête jaune", 28, '2003-07-08', 'Male', 345.0, null, 2),
	("O2", "Ouistiti à tête jaune", 28, '2008-07-08', 'Male', 345.0, null, 2),
	("O3", "Ouistiti à tête jaune", 28, '2003-07-08', 'Male', 345.0, null, 2),
	("O4", "Ouistiti à tête jaune", 28, '2003-07-08', 'Femelle', 345.0, null, 2),
	("O5", "Ouistiti à tête jaune", 28, '2003-07-08', 'Femelle', 345.0, null, 2),

	("T1", "Tamarin lion", 29, '2003-07-08', 'Male', 345.0, null, 2),
	("T2", "Tamarin lion", 29, '2008-07-08', 'Male', 345.0, null, 2),
	("T3", "Tamarin lion", 29, '2003-07-08', 'Male', 345.0, null, 2),
	("T4", "Tamarin lion", 29, '2003-07-08', 'Femelle', 345.0, null, 2),

	("P1", "Panthère des neiges", 27, '2000-07-08', 'Male', 345.0, null, 2),
	("P2", "Panthère des neiges", 27, '2000-07-08', 'Femelle', 345.0, null, 2),

	("VAutr", "Vautour à dos blanc", 36, '2000-07-08', 'Femelle', 345.0, null, 2),

	("C1", "Chouette forestière", 30, '2003-07-08', 'Male', 345.0, null, 2),
	("C2", "Chouette lapone", 31, '2008-07-08', 'Male', 345.0, null, 2),
	("C3", "Harfang des neiges", 32, '2003-07-08', 'Male', 345.0, null, 2),

	("AraM1", "Ara militaire", 33, '2003-07-08', 'Male', 345.0, null, 2),
	("AraM2", "Ara militaire", 33, '2003-07-08', 'Male', 345.0, null, 2),
	("AraM3", "Ara militaire", 33, '2003-07-08', 'Male', 345.0, null, 2),

	("AraA1", "Ara araraunas", 34, '2003-07-08', 'Male', 345.0, null, 2),
	("AraA2", "Ara araraunas", 34, '2003-07-08', 'Male', 345.0, null, 2),
	("AraA3", "Ara araraunas", 34, '2003-07-08', 'Male', 345.0, null, 2),
	
	("AraV1", "Ara à ailes vertes", 35, '2003-07-08', 'Male', 345.0, null, 2),
	("AraV2", "Ara à ailes vertes", 35, '2003-07-08', 'Male', 345.0, null, 2),
	("AraV3", "Ara à ailes vertes", 35, '2003-07-08', 'Male', 345.0, null, 2)
;

insert into AvoirParent values
    ("Moussa","Milan"),
    ("Margot","Milan"),
	("Ugo","Uta"),
	("Ugette","Uta")
;

insert into Animation(duree, description_anim, id_soign, race) values
    (30, "L'Odyssée des Lions de Mer : le ballet aquatique", 5, "Lion de mer de Steller"),
	(45, "Entrainement des Lions de Mer", 5, "Lion de mer de Steller"),
	(55, 'Caresser les raies', 2, "Grande raie-guitare"),

	(20, 'Le Maître des Airs : grande envergure !', 8, 'Vautour à dos blanc'),
	(20, 'Présentation des oiseaux en vol libre', 6, 'Ara militaire'),
	(20, 'Présentation des oiseaux en vol libre', 6, 'Ara à ailes vertes'),
	(20, 'Présentation des oiseaux en vol libre', 6, 'Ara araraunas'),
	(45, 'Jouer avec les singes', 4, "Ouistiti à tête jaune"),
	(45, 'Jouer avec les singes', 4, "Tamarin lion"),

	(15, 'Le goûter des éléphants', 3, "Eléphant de forêt d'Afrique"),
	(15, 'Le goûter des hippopotames', 9, 'Hippopotame'),
	(15, 'Le goûter des manchots', 9, 'Manchot empereur'),
	(40, 'Danser avec les manchots', 9, 'Manchot empereur'),
	(15, 'Le goûter des girafes', 3, "Girafe"),
	(15, 'Rencontre avec les éléphants', 3, "Eléphant de forêt d'Afrique"),

	(30, 'Terreur au terrarium', 1, "Python royal"),
	(15, 'Le chant de la rainette', 7, 'Rainette jaguar'),
	(15, 'Le chant de la rainette', 7, "Rainette verte d'Amérique"),
	(15, 'Le chant de la rainette', 7, 'Rainette criarde')
;
/*
TESTS TRIGGERS ANIM
	insert into Planning(id_anim, id_enclos, date_anim, heure_debut) values
		(2, 1, date('now'), '12:50')
	;
	-- enclos occupé
	insert into Planning(id_anim, id_enclos, date_anim, heure_debut) values
		(1, 7, date('now'), '13:00')
	;
	-- déjà occupé soigneur
	insert into Planning(id_anim, id_enclos, date_anim, heure_debut) values
		(3, 9, date('now'), '13:00')
	;
	-- déjà occupé enclos
*/
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


insert into Nourriture values
    ('hareng'),
    ('maquereau'),
	('esturgeon'),
    ('saumon'),
	('mollusques'),
    ('morue'),
	('crevette'),
    ('calmar'),
	('crustacés'),
    ('invertébrés'),
	('bivalve'),
    ('crabe'),
	('tortue de rivière'),
    ('piranha'),
	('larves de hareng'),
    ('zooplancton')
;

insert into Convenir values
    ('hareng','p'),
    ('maquereau','p'),
	('esturgeon','p'),
    ('saumon','p'),
	('mollusques','p'),
    ('morue','p'),
	('crevette','p'),
    ('calmar','p'),
	('crustacés','p'), ('crustacés','c'),
    ('invertébrés','p'),
	('bivalve','p'),
    ('crabe','p'),
	('tortue de rivière','p'),
    ('piranha','p'),

	('larves de hareng','c'),
    ('zooplancton','c')
;

insert into Manger values 
	("Lion de mer de Steller", 'hareng'),
	("Lion de mer de Steller", 'maquereau'),
	("Lion de mer de Steller", 'esturgeon'),
	("Lion de mer de Steller", 'saumon'),
	("Lion de mer de Steller", 'mollusques'),

	("Béluga", 'morue'),
	("Béluga", 'hareng'),
	("Béluga", 'saumon'),
	("Béluga", 'crevette'),
	("Béluga", 'calmar'),
	
	("Grande raie-guitare", 'crustacés'),
	("Grande raie-guitare", 'invertébrés'),
	("Grande raie-guitare", 'bivalve'),
	
	("Méduse dorée", 'zooplancton'),
	("Méduse dorée", 'crustacés'),
	("Méduse dorée", 'larves de hareng'),

	("Boto", 'piranha'),
	("Boto", 'crabe'),
	("Boto", 'tortue de rivière')
;

insert into Planning (id_anim, id_enclos, date_anim, heure_debut) values 
	(1, 4, '2022-04-11', '10:40'),
	(1, 4, '2022-04-26', '11:30'),
	(1, 4, '2022-04-27', '13:25'),
	(1, 4, '2022-05-11', '14:50'),
	(1, 4, '2022-05-20', '15:55'),
	(1,4,'2022-04-18', '09:55'),
	(1,4,'2022-04-20', '10:05'),
	(2,4,'2022-04-21', '10:10'),
	(2,4,'2022-04-26', '10:30'),
	(2,4,'2022-04-22', '09:25'),
	(2,4,'2022-05-12', '10:50'),
	(2,4,'2022-05-26', '12:30'),
	(2,4,'2022-05-30', '13:30'),
	(2,4,'2022-05-31', '14:40'),

	(3,3,'2022-04-12', '09:25'),
	(3,3,'2022-04-14', '10:35'),
	(3,3,'2022-04-19', '11:00'),
	(3,3,'2022-04-26', '11:10'),
	(3,3,'2022-04-27', '11:50'),
	(3,3,'2022-05-27', '17:15'),
	(3,3,'2022-05-31', '17:55'),
	(3,3,'2022-04-27', '10:35'),
	(3,3,'2022-04-29', '10:40'),

	(4,36,'2022-05-02',	'10:50'),
	(4,36,'2022-05-03',	'11:15'),
	(4,36,'2022-05-23',	'17:05'),
	(4,36,'2022-05-25',	'17:10'),
	(4,36,'2022-04-29',	'12:10'),
	(4,36,'2022-05-04',	'13:05'),
	(4,36,'2022-05-05',	'13:10'),
	(4,36,'2022-05-10',	'14:30'),
	(4,36,'2022-05-18',	'15:00'),
	(4,36,'2022-05-19',	'16:00'),

	(5,33,'2022-05-24',	'16:25'),
	(5,33,'2022-05-25',	'16:30'),
	(5,33,'2022-05-27',	'17:45'),
	(5,33,'2022-05-04',	'11:20'),
	(5,33,'2022-05-05',	'11:40'),
	(6,35,'2022-05-09',	'11:50'),
	(6,35,'2022-05-10',	'12:00'),
	(6,35,'2022-05-30',	'17:55'),
	(6,35,'2022-04-11',	'09:10'),
	(6,35,'2022-04-12',	'09:40'),
	(6,35,'2022-05-16',	'16:15'),
	(6,35,'2022-05-18',	'16:25'),
	(7,34,'2022-05-12',	'12:10'),
	(7,34,'2022-05-16',	'12:25'),
	(7,34,'2022-04-18',	'10:20'),
	(7,34,'2022-04-22',	'10:55'),
	(7,34,'2022-04-26',	'13:05'),

	(8,28,'2022-04-28',	'13:30'),
	(8,28,'2022-04-29',	'13:45'),
	(8,28,'2022-05-04',	'14:15'),
	(8,28,'2022-05-05',	'14:55'),
	(8,28,'2022-05-18',	'12:35'),
	(8,28,'2022-05-19',	'13:00'),
	(9,29,'2022-05-20',	'13:05'),
	(9,29,'2022-05-23',	'13:10'),
	(9,29,'2022-05-09',	'15:50'),
	(9,29,'2022-05-12',	'15:55'),
	(9,29,'2022-05-17',	'16:00'),
	
	(10,19,'2022-05-25', '13:30'),
	(10,19,'2022-05-27', '13:40'),
	(10,19,'2022-05-18', '16:40'),
	(10,19,'2022-05-20', '17:10'),
	(10,19,'2022-05-27', '17:55'),
	(15,19,'2022-04-13', '10:45'),
	(15,19,'2022-04-14', '11:00'),
	(15,19,'2022-04-15', '11:10'),
	(14,18,'2022-04-20', '14:30'),
	(14,18,'2022-04-21', '14:35'),
	(15,19,'2022-04-25', '11:20'),
	(15,19,'2022-04-26', '14:55'),
	(15,19,'2022-04-27', '15:05'),
	(14,18,'2022-05-23', '17:30'),
	(14,18,'2022-05-25', '17:40'),
	(14,18,'2022-05-27', '15:50'),
	(14,18,'2022-05-31', '17:55'),

	(11,20,'2022-04-11', '09:40'),
	(11,20,'2022-04-12', '11:35'),
	(11,20,'2022-04-13', '11:50'),
	(11,20,'2022-04-19', '12:10'),
	(11,20,'2022-05-31', '13:45'),
	(11,20,'2022-04-11', '14:00'),
	(12,21,'2022-04-12', '14:05'),
	(12,21,'2022-04-14', '14:10'),
	(12,21,'2022-04-22', '13:55'),
	(12,21,'2022-05-02', '14:05'),
	(12,21,'2022-05-06', '14:30'),
	(12,21,'2022-05-19', '16:40'),
	(12,21,'2022-05-20', '16:55'),
	(13,21,'2022-05-09', '14:40'),
	(13,21,'2022-05-10', '16:20'),
	(13,21,'2022-05-13', '16:30'),
	(13,21,'2022-05-17', '17:20'),
	(13,21,'2022-04-15', '14:20'),
	(13,21,'2022-04-18', '14:25'),

	(16,9,'2022-04-29',	'15:15'),
	(16,9,'2022-05-02',	'15:20'),
	(16,9,'2022-04-26',	'11:45'),
	(16,9,'2022-04-29',	'11:50'),
	(16,9,'2022-05-03',	'12:45'),
	(16,9,'2022-05-04',	'14:05'),

	(17,10,'2022-05-03', '15:30'),
	(17,10,'2022-05-04', '15:35'),
	(18,13,'2022-05-05', '15:50'),
	(17,10,'2022-05-06', '14:20'),
	(18,13,'2022-05-09', '13:00'),
	(17,10,'2022-05-09', '16:10'),
	(17,10,'2022-05-10', '16:15'),
	(17,10,'2022-05-11', '16:35'),
	(18,13,'2022-05-16', '16:40'),
	(18,13,'2022-05-17', '17:40'),
	(18,13,'2022-05-26', '17:55'),
	(19,12,'2022-04-11', '09:00'),
	(19,12,'2022-04-12', '09:10'),
	(19,12,'2022-04-14', '09:20'),
	(19,12,'2022-04-15', '09:35'),
	(19,12,'2022-05-10', '10:05'),
	(19,12,'2022-05-12', '16:10')
;
	-- <3

