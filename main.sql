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
	espe_poids_adulte	varchar(100)		not null,
	poids_moyen_zoo 	float	check(poids_moyen_zoo>=0) default(0),
	dangerosite			int		check(0<=dangerosite and dangerosite<=4)	not null,
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
	id_type_enclos		char(2)		references TypeEnclos(id_type_enclos)
);

create table Animal(
	nom		varchar(30)		primary key,
	race 	varchar(30)		references Espece(race),
	id_enclos	int		references Enclos(id_enclos),
	date_naissance_animal		date  	not null,
	genre	varchar(7)	check(genre in ('Mâle','Femelle'))  not null,
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




















































-- pour la page d'accueil ok
create view NombreTotalAnimauxZoo as
	select count(1) as nombre
	from Animal
;
-- pour la page 'Animaux'
create view NombreEspecesParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from Espece natural join TypeEnclos
	where nb_dans_zoo > 0
	group by id_type_enclos
;
create view NombreAnimauxParTypeEnclos as
	select id_type_enclos, count(1) as nombre
	from TypeEnclos natural join Enclos natural join Animal
	group by id_type_enclos
;
-- pour la page 'Soigneur'
create view ListeAnimalPourSoigneur as
	select id_soign, nom
	from Soigneur natural join Animal
;
create view ListeAnimationPourSoigneur as 
	select DISTINCT id_soign, description_anim
	from Soigneur natural join Animation
;
-- pour triggers
create view RaceParEnclos as
    select distinct id_enclos, race
    from Enclos natural join Animal
;
create view EnclosPlein as
	select id_enclos
	from Enclos
	where nb_actuel = nb_max
;
create view NourritureParCategorie as
	select id_categorie, id_plat
	from Convenir natural join Nourriture
;
-- pour la page d'un animal
create view EnfantsDuZoo as
	select distinct enfant as noms
	from AvoirParent
;
create view ParentsDuZoo as 
	select distinct parent as noms
	from AvoirParent
;

create view InfosEnclos as 
	select id_enclos, race, nb_max, nb_actuel
	from Enclos natural join Animal
	group by id_enclos
;























































-- triggers

create trigger MisAJourAjoutAnimal
after insert on Animal
begin
	update Espece set nb_dans_zoo = nb_dans_zoo + 1 where race = new.race;
	update Enclos set nb_actuel = nb_actuel + 1 where id_enclos = new.id_enclos;
	update Espece set poids_moyen_zoo = (select avg(poids) 
										from Animal natural join Espece
										where race = new.race
										group by race)	where race = new.race;
end;

create trigger MisAJourSupprAnimal
after delete on Animal
begin
	update Espece set nb_dans_zoo = nb_dans_zoo - 1 where race = old.race;
	update Enclos set nb_actuel = nb_actuel - 1 where id_enclos = old.id_enclos;
	update Espece set poids_moyen_zoo = (select avg(poids) 
										from Animal natural join Espece
										where race = old.race
										group by race)	where race = old.race;
end;

create trigger MisAJourPoids
after update of poids on Animal
begin
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

			when 	(select race from RaceParEnclos where id_enclos = new.id_enclos)
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
 
create trigger CalculeHeureFinPlanning
after insert on Planning
begin 
	update Planning set heure_fin = time(new.heure_debut, '+'||(select duree
																from Animation
																where id_anim = new.id_anim)||' minutes') 
		where new.id_planning = id_planning;
end;

create trigger EmpecheAjoutNourritureAUneEspece
before insert on Manger
begin
	select 
		case 
			when 	(select id_categorie
					from Espece
					where race = new.race) 	not in  (select id_categorie 
													from NourritureParCategorie
													where id_plat = new.id_plat)
			then raise(abort, 'ERREUR : cette espèce ne peut pas manger de cette nourriture !')
		end;
end;



create trigger EmpecheAjoutLienParente
before insert on AvoirParent
begin 
	select 
		case 
			when 	(select race from Animal where new.enfant = nom) <> (select race from Animal where new.parent = nom)
			then raise(abort, 'ERREUR : ces animaux ne sont pas de la même espèce !')

			when 	(select genre
					from Animal
					where nom = new.parent) = 	(select genre 
												from Animal
												where nom = (select parent
															from AvoirParent
															where new.enfant = enfant))
			then raise(abort, 'ERREUR : cet enfant a déjà un parent de ce genre')

			when 	(select date_naissance_animal from Animal where new.enfant = nom) <= (select date_naissance_animal from Animal where new.parent = nom)
			then raise(abort, "ERREUR : l'enfant ne peut pas être plus vieux que son parent !")
		end;
end;














































-- insertions
insert into CategorieNourriture values
    ('o',"Omnivore", "Se nourrit d'aliments d'origines végétale et animale"),
    ('h',"Herbivore", "Se nourrit d'herbes et de plantes basses"),
    ('c',"Carnivore", "Se nourrit de chairs ou de tissus d'animaux vivants ou morts"),
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
	("Lion de mer de Steller", "25 ans", "300 à 1 100 kg", 1, 1, "Nord de l'océan Pacifique.", 'p', 'aq','lionmer.jpg'),
	("Béluga", "35 à 50 ans", "Environ 1 400 kg", 0, 4, "Eaux arctiques et subarctiques.", 'p','aq','beluga.jpg'),
	("Grande raie-guitare", "20 ans", "200 kg", 1, 4, " Les fonds sableux d'Afrique.", 'p','aq','raie.jpg'),
	("Méduse dorée", "1 à 2 ans", "1 à 10 kg", 3, -1, "Les eaux chaudes.", 'c','aq','medusedoree.jpg'),
	("Boto", "12 à 15 ans", "100 à 150 kg", 1, 3, "Les eaux douces du bassin de l'Orénoque jusqu'au bassin de l'Amazone.", 'p','aq','boto.jpeg'),

	("Python royal", "30 ans en captivité", "1 à 2 kg", 4, 1, "Territoire allant du Sénégal jusqu'à l'ouest de l'Ouganda et au nord de la République démocratique du Congo.", 'c','tr', 'pythonroyal.jpg'),
    ("Rainette jaguar", "entre 5 et 10 ans", "3 g en moyenne", 4, 0, "Forêts tropicales humides de basse altitude.", 'i','tr', 'rainettejaguar.jpg'),
	("Rainette verte d'Amérique", "4 à 5 ans", "3 à 8 g environ", 1, 0, "Forêts tropicales humides de basse altitude.", 'i','tr', 'rainetteverte.jpg'),
	("Rainette criarde", "inconnue", "entre 3 et 14 g", 2, 0, "Forêts tropicales humides de basse altitude.", 'i','tr', 'rainettecriarde.jpg'),
	("Tortue géante des Seychelles", "plus de 150 ans", "environ 250 kg pour les mâles, 160 kg pour les femelles", 0, 2, "L'atoll corallien très sec et inhabité d'Aldabra.", 'h','tr', 'tortuegeante.jpg'),

    ("Panda géant", "20 à 25 ans", "70 à 120 kg", 3, 2, "Forets de bambous.", 'h', 'ex', 'pandageant.jpg'),
    ("Hérisson du désert", "10 ans", "280 à 510 g", 1, 0, "Déserts.", 'i', 'ex', 'herisson.jpg'),
    ("Girafe", "10 à 15 ans", "750 à 2 000 kg", 0, 2, "Savanes.", 'h', 'ex', 'girafe.jpg'),
	("Eléphant de forêt d'Afrique", "60 à 70 ans", "2 700 à 6 000 kg", 2, 4, "Forêt dense d'Afrique centrale et d'Afrique de l'Ouest.", 'h', 'ex', 'elephant.jpg'),
    ("Panda roux", "8 à 10 ans", "3 à 6 kg", 2, 3, "Présent en Asie, dans la chaîne de l’Himalaya.", 'o','ex', 'pandaroux.jpg'),
	("Hippopotame", "40 à 50 ans", "1 300 à 1 800 kg", 4, 2, "Répandus dans toute l’Afrique subsaharienne.", 'h','ex', 'hippopotame.jpg'),
	("Manchot empereur", "15 à 20 ans", "23 kg", 3, 1, "Le pourtour du continent antarctique de la limite du pack de glace jusqu'à 200 ou 250 km à l'intérieur des terres.", 'p','ex', 'manchot.jpg'),
	("Paresseux", "30 à 50 ans", "4 à 8 kg", 1, 1, "Forêts d'Amérique centrale et d'Amérique du sud.", 'o','ex', 'paresseux.jpg'),
	("Maki catta", "16 à 19 ans", "2,3 à 3,5 kg", 3, 3, "Les fourrés épineux du sud et du sud-ouest de Madagascar.", 'o','ex', 'maki.jpg'),

    ("Ouistiti à tête jaune", "12 ans environ", "230 à 453 g", 3, 4, "Forêt Atlantique au Brésil", 'i', 'cg', 'ouistiti.jpg'),
	("Panthère des neiges", "16 à 18 ans", "32 kg", 4, 2, "Montagnes escarpées et rocheuses d'Asie", 'c', 'cg', 'panthere.jpg'),
    ("Chevêche forestière", "9 ans", "moins de 200 g", 2, 3, "Plaines et de collines du sous-continent indien", 'o', 'cg', 'chouette.jpg'),
    ("Vautour à dos blanc", "19 ans", "4,2 à 7,2 kg", 4, 4, "Forêt Atlanque", 'c', 'cg', 'vautour.jpg'),
	("Chouette lapone", "7 ans", "800 à 1 700 g", 2, 0, "Les forêts boréales/touffues, les prairies et les champs boisés, les marais de l'Estonie et la Finlande jusqu'au Québec.", 'c', 'cg', 'chouettelapone.jpg'),
    ("Harfang des neiges", "environ 10 ans", "2 kg", 1, 2, "Il préfère les hautes toundras ondulantes avec des pointes de terre élevées pour se percher et fabriquer son nid à l’extrême nord du Canada.", 'c', 'cg', 'harfang.jpg'),
	("Tamarin lion", "10 ans", "350 à 600 g", 3, 3, "Forêt tropicale côtière de la Mata Atlântica riche en broméliacées à une altitude comprise entre le niveau de la mer et 300 m d’altitude.", 'o', 'cg', 'tamarin.jpg'),
	("Ara militaire", "45 à 60 ans", "1,1 kg", 2, 2, "Lontagne, dans les régions tempérées semi-arides et les forêts tropicales, près des cours d'eau.", 'h', 'cg', 'aramilitaire.jpg'),
	("Ara à ailes vertes", "50 à 60 ans", "1 à 1,7 kg", 3, 0, "Basse et moyenne altitude dans les forêts tropicales dans toute l’Amérique du Sud.", 'h', 'cg', 'ara-vertes.jpg'),
    ("Ara ararauna", "30 à 35 ans", "90 à 1 500 g", 1, 0, "Trous de palmiers secs du sud-est du Panama à l'État de São Paulo.", 'h', 'cg', 'arableu.jpg')
;

insert into Enclos (nb_max, id_type_enclos) values
    (5,'aq'), --1 vide
    (4, 'aq'), --2 Boto
	(2, 'aq'), --3 Raie
    (4, 'aq'), --4 Lion Mer
	(6,'aq'), --5 Méduse
    (3, 'aq'), --6 Beluga
	(5, 'aq'), -- 7 vide
	(15, 'aq'), -- 8 vide

	(2,'tr'), --9 Python
    (2,'tr'), --10 Rainette jaguar
    (3, 'tr'), --11 Tortue
	(2,'tr'), --12 criarde
	(3, 'tr'), --13 verte d'amérique
	(1, 'tr'), --14 vide

	(6,'ex'), --15 Hérisson
	(3,'ex'), --16 Panda géant
	(8,'ex'), --17 Panda roux 7
	(4,'ex'), --18 Girafe 3
    (3,'ex'), --19 Eléphant 3
	(2,'ex'), -- 20 Hippopotame
	(7,'ex'), -- 21 Manchot Empereur
	(3,'ex'),-- 22 paresseux
	(6,'ex'),-- 23 maki catta
	(5,'ex'),-- 24 vide
	(4,'ex'),-- 25 vide
	(3,'ex'),-- 26 vide 

	(2,'cg'), --27 panthere
	(7,'cg'), --28 ouistiti
	(5,'cg'), -- 29 tamarin
	(2,'cg'), -- 30 chouettes
	(2,'cg'), --31 
	(2,'cg'), -- 32
	(5,'cg'), --33 aras
	(4,'cg'), --34
	(5,'cg'), --35
	(1,'cg'), -- 36 vautour
	(1,'cg'), --37 vide 
	(4,'cg'), --38 vide
	(3,'cg')  --39 vide
;

insert into Animal values
	("Marceline", "Boto", 2,'2015-09-01', 'Femelle', 95.0, "née dans le zoo",  1),
	("Julie", "Boto", 2,'2009-10-11', 'Femelle', 128.0, null,  1),
	("Antoine", "Boto", 2,'2017-03-23', 'Mâle', 100.0, "né dans le zoo",  1),
	("Pierre", "Boto", 2,'2010-06-04', 'Mâle', 150.0, null,  1),

	("Emeline", "Grande raie-guitare", 3, '2005-05-13', 'Femelle', 182.0, null,  2),
	("William", "Grande raie-guitare", 3, '2008-02-28', 'Mâle', 194.0, null,  2),
	
	("Mathéo", "Lion de mer de Steller", 4, '2008-12-31', 'Mâle', 854.0, null, 3),
	("James", "Lion de mer de Steller", 4,'2004-07-02', 'Mâle', 1084.0, null, 3),
	("Gabrielle", "Lion de mer de Steller", 4,'1998-12-16', 'Femelle', 765.0, null, 3),

	("Hugo", "Méduse dorée", 5,'2020-12-09', 'Mâle', 7.4, null, 4),
	("Said", "Méduse dorée", 5,'2020-08-26', 'Mâle', 6.7, null, 4),
	("Anne", "Méduse dorée", 5,'2022-11-03', 'Femelle', 1.2, "née dans le zoo", 4),
	("Christine", "Méduse dorée", 5,'2022-04-02', 'Femelle', 2.5, "née dans le zoo", 4),
	("Maude", "Méduse dorée", 5,'2020-06-15', 'Femelle', 4.7, null, 4),

	("Nicolas", "Béluga", 6, '1997-09-17', 'Mâle', 1421.0, null, 5),
	("Alexandre", "Béluga", 6, '2005-11-06', 'Mâle', 1412.0, null, 5),
	("Hortense", "Béluga", 6, '1995-06-28', 'Femelle', 1368.0, null, 5),

	("Ramon", "Python royal", 9, '1993-05-16', 'Mâle', 1.6, null, 6),

	("Leo", "Rainette jaguar", 10, '2016-02-05', 'Mâle', 0.003, null, 6),
	("Olivia", "Rainette jaguar", 10, '2018-12-15', 'Femelle', 0.0025, null, 6),

	("Sylvie", "Rainette verte d'Amérique", 13, '2020-03-19', 'Femelle', 0.006, null, 7),

	("Mélina", "Rainette criarde", 12, '2020-04-09', 'Femelle', 0.011, null, 7),

	("Adèle", "Tortue géante des Seychelles", 11, '1918-11-18', 'Femelle', 145.0, null, 7),
	("Chouaib", "Tortue géante des Seychelles", 11, '1960-10-08', 'Mâle', 210.0, null, 7),
	("Louise", "Tortue géante des Seychelles", 11, '1945-08-17', 'Femelle', 139.0, null, 7),

	("Zoé", "Hérisson du désert", 15, '2013-04-21', 'Femelle', 0.410, null, 8),
	("Jean", "Hérisson du désert", 15, '2012-06-18', 'Mâle', 0.5, null, 8),
	("Benjamin", "Hérisson du désert", 15, '2022-01-08', 'Mâle', 0.290, "né dans le zoo", 8),
	("Elsa", "Hérisson du désert", 15, '2021-11-15', 'Femelle', 0.345, "née dans le zoo", 8),
	("Matthieu", "Hérisson du désert", 15, '2020-05-01', 'Mâle', 0.687,"né dans le zoo", 8),

	("Ugo", "Panda géant", 16, '2017-06-02', 'Mâle', 80,"né dans le zoo", 9),
	("Anis", "Panda géant", 16, '1998-11-18', 'Mâle', 110.0, null, 9),
	("Blandine", "Panda géant", 16, '2000-03-10', 'Femelle', 105.0, "née dans le zoo", 9),

	("Rémi", "Panda roux", 17, '2013-02-22', 'Mâle', 5.8, null, 10),
	("Loïs", "Panda roux", 17, '2018-03-15', 'Mâle', 4.1,"né dans le zoo", 10),
	("Elie", "Panda roux", 17, '2018-03-15', 'Femelle', 3.8, "née dans le zoo", 10),
	("Yann", "Panda roux", 17, '2014-08-21', 'Mâle', 5.6, null, 11),
	("Héléna", "Panda roux", 17, '2020-07-01', 'Femelle', 3.9, null, 11),
	("Alix", "Panda roux", 17, '2015-12-16', 'Femelle', 4.7, null, 11),

    ("Caren", "Girafe", 18, '2008-03-07', 'Femelle', 1165.0, null, 12),
	("Eve", "Girafe", 18, '2013-09-01', 'Femelle', 950.0, null, 12),
	("Alain", "Girafe", 18, '2018-03-30', 'Mâle', 1895.0, null, 12),

    ("Augustin", "Eléphant de forêt d'Afrique", 19, '1985-04-16', 'Mâle', 5654.5, null, 2),
    ("Martine", "Eléphant de forêt d'Afrique", 19, '1988-07-21', 'Femelle', 4378.9, null, 2),
    ("Milan", "Eléphant de forêt d'Afrique", 19, '2008-03-04', 'Mâle', 3452.7, "né dans le zoo", 3),

	("Mohammed", "Hippopotame", 20, '1995-02-16', 'Mâle', 1756, null, 5),
    ("Soufiane", "Hippopotame", 20, '2015-03-28', 'Mâle', 1456, "né dans le zoo", 6),

	("Ginette", "Manchot empereur", 21, '2006-05-13', 'Femelle', 21.5, null, 9),
	("Lucas", "Manchot empereur", 21, '2021-07-18', 'Mâle', 15.9, "né dans le zoo", 9),
	("Eloise", "Manchot empereur", 21, '2016-05-20', 'Femelle', 20.3, "née dans le zoo", 10),
	("Mathis", "Manchot empereur", 21, '2018-10-16', 'Mâle', 21.4, "né dans le zoo", 10),
	("Manlio", "Manchot empereur", 21, '2008-05-30', 'Mâle', 22.5, null, 11),

	("Jasmine", "Maki catta", 23, '2013-10-19', 'Femelle', 2.5, "née dans le zoo", 12),
	("Albert", "Maki catta", 23, '2015-04-13', 'Mâle', 3.1, null, 2),
	("Jérémy", "Maki catta", 23, '2007-11-14', 'Mâle', 3.4, null, 2),

	("Sandra", "Paresseux", 22, '1984-05-09', 'Femelle', 6.8, null, 11),
	("Fabrice", "Paresseux", 22, '1990-05-10', 'Mâle', 7.4, null, 3),

	("Enzo", "Ouistiti à tête jaune", 28, '2020-03-17', 'Mâle', 0.365, "né dans le zoo", 12),
	("Frédérique", "Ouistiti à tête jaune", 28, '2019-05-25', 'Femelle', 0.448, "née dans le zoo", 11),
	("Jacqueline", "Ouistiti à tête jaune", 28, '2013-02-02', 'Femelle', 0.398, null, 12),
	("Martin", "Ouistiti à tête jaune", 28, '2011-11-14', 'Mâle', 0.410, null, 6),
	("Oscar", "Ouistiti à tête jaune", 28, '2017-09-11', 'Mâle', 0.287, null, 5),

	("Olga", "Tamarin lion", 29, '2021-02-03', 'Femelle', 0.456, "née dans le zoo", 1),
	("Carole", "Tamarin lion", 29, '2014-09-28', 'Femelle', 0.589, null, 8),
	("Claude", "Tamarin lion", 29, '2020-03-17', 'Mâle', 0.397, null, 8),
	("Ayoub", "Tamarin lion", 29, '2013-12-18', 'Mâle', 0.487, null, 3),

	("Evelyne", "Panthère des neiges", 27, '2014-01-20', 'Femelle', 31.3, null, 1),
	("Lucien", "Panthère des neiges", 27, '2016-06-01', 'Mâle', 32.6, null, 5),

	("Dominique", "Vautour à dos blanc", 36, '2006-09-19', 'Femelle', 6.8, "née dans le zoo", 7),

	("Hubert", "Chevêche forestière", 30, '2016-08-12', 'Mâle', 0.195, null, 1),
	("Maurice", "Chouette lapone", 31, '2018-10-16', 'Mâle', 1.478, null, 5),
	("Marion", "Harfang des neiges", 32, '2017-09-27', 'Femelle', 1.946, null, 3),

	("Marie", "Ara militaire", 33, '1983-11-12', 'Femelle', 1.065, null, 6),
	("David", "Ara militaire", 33, '2003-08-04', 'Mâle', 1.004, "né dans le zoo", 3),
	("Nathan", "Ara militaire", 33, '2020-05-28', 'Mâle', 0.935, "né dans le zoo", 2),

	("Françoise", "Ara ararauna", 34, '1993-05-02', 'Femelle', 1.549, null, 1),
	("Fabienne", "Ara ararauna", 34, '2007-07-19', 'Femelle', 1.694,"née dans le zoo", 9),
	("Bastien", "Ara ararauna", 34, '2000-01-28', 'Mâle', 1.348, "né dans le zoo", 7),
	
	("Emilie", "Ara à ailes vertes", 35, '1981-10-08', 'Femelle', 0.648, null, 6),
	("Lola", "Ara à ailes vertes", 35, '1985-02-22', 'Femelle', 1.367, null, 2),
	("Gauthier", "Ara à ailes vertes", 35, '2003-11-11', 'Mâle', 1.182, "né dans le zoo", 5)
;

insert into AvoirParent values
    ("Julie","Marceline"),
	("Pierre","Marceline"),
	("Julie","Antoine"),
	("Pierre","Antoine"),

	("Hugo","Anne"),
	("Maude","Anne"),
	("Hugo","Christine"),
	("Maude","Christine"),

	("Zoé","Benjamin"),
	("Jean","Benjamin"),
	("Zoé","Elsa"),
	("Jean","Elsa"),
	("Zoé","Matthieu"),
	("Jean","Matthieu"),

	("Anis","Ugo"),
	("Blandine","Ugo"),

	("Alix","Loïs"),
	("Rémi","Loïs"),
	("Alix","Elie"),
	("Rémi","Elie"),

	("Augustin","Milan"),
	("Martine","Milan"),

	("Mohammed","Soufiane"),

	("Ginette","Lucas"),
	("Manlio","Lucas"),
	("Ginette","Eloise"),
	("Manlio","Eloise"),
	("Ginette","Mathis"),
	("Manlio","Mathis"),
	
	("Martin","Enzo"),
	("Jacqueline","Enzo"),
	("Martin","Frédérique"),
	("Jacqueline","Frédérique"),

	("Carole","Olga"),
	("Ayoub","Olga"),

	("David","Nathan"),
	("Marie","David"),

	("Françoise","Bastien")
;

insert into Animation(duree, description_anim, id_soign, race) values
    (30, "L'Odyssée des Lions de Mer : le ballet aquatique", 5, "Lion de mer de Steller"),
	(45, "Entrainement des Lions de Mer", 5, "Lion de mer de Steller"),
	(55, 'Caresser les raies', 2, "Grande raie-guitare"),

	(20, 'Le Maître des Airs : grande envergure !', 8, 'Vautour à dos blanc'),
	(20, 'Présentation des oiseaux en vol libre', 6, 'Ara militaire'),
	(20, 'Présentation des oiseaux en vol libre',11, 'Ara à ailes vertes'),
	(20, 'Présentation des oiseaux en vol libre', 6, 'Ara ararauna'),
	(45, 'Jouer avec les singes', 4, "Ouistiti à tête jaune"),
	(45, 'Jouer avec les singes', 4, "Tamarin lion"),

	(15, 'Le goûter des éléphants', 3, "Eléphant de forêt d'Afrique"),
	(15, 'Le goûter des hippopotames', 9, 'Hippopotame'),
	(15, 'Le goûter des manchots', 9, 'Manchot empereur'),
	(40, 'Danser avec les manchots', 12, 'Manchot empereur'),
	(15, 'Le goûter des girafes', 3, "Girafe"),
	(15, 'Rencontre avec les éléphants', 3, "Eléphant de forêt d'Afrique"),

	(30, 'Terreur au terrarium', 1, "Python royal"),
	(15, 'Le chant de la rainette', 10, 'Rainette jaguar'),
	(15, 'Le chant de la rainette', 7, "Rainette verte d'Amérique"),
	(15, 'Le chant de la rainette', 7, 'Rainette criarde')
;

insert into Nourriture values
    ('Hareng'),
    ('Maquereau'),
	('Esturgeon'),
    ('Saumon'),
	('Mollusques'),
    ('Morue'),
	('Crevette'),
    ('Calmar'),
	('Crustacés'),
    ('Invertébrés'),
	('Bivalve'),
    ('Crabe'),
	('Tortue de rivière'),
    ('Piranha'),
	('Larves de hareng'),
    ('Zooplancton'),

	('Rat'),
	('Souris'),
	('Oiseau'),
	('Fourmi'),
	('Termite'),
	('Araignée'),
	('Mouche'),
	('Ver'),
	('Herbe'),
	('Carex'),
	('Feuille'),
	('Tige'),
	('OEuf'),
	('Insecte'),
	('Scorpion'),
	('Fleur'),
	('Jeune pousse'),
	('Fruit'),
	('Écorce'),
	('Branche'),
	('Bourgeon'),
	('Calamar'),
	('Poisson'),
	('Racine'),
	('Graminée'),
	('Bambou'),
	('Plante'),

	('Champignon'),
	('Gomme'),
	('Chèvre sauvage'),
	('Mouton sauvage'),
	('Marmotte'),
	('Lièvre'),
	('Reptile'),
	('Sauterelle'),
	('Coléoptères'),
	('Carcasse'),
	('Rongeur'),
	('Campagnol'),
	('Musaraigne'),
	('Taupe'),
	('Renard'),
	('Lemming'),
	('Nectar'),
	('Graine'),
	('Noix'),
	('Baie'),
	('Granulé'),
	('Légume')
;

insert into Convenir values
    ('Hareng','p'),
    ('Maquereau','p'),
	('Esturgeon','p'),
    ('Saumon','p'),
	('Mollusques','p'),
    ('Morue','p'),
	('Crevette','p'),
    ('Calmar','p'),
	('Crustacés','p'), ('Crustacés','c'),
    ('Invertébrés','p'),
	('Bivalve','p'),
    ('Crabe','p'),
	('Tortue de rivière','p'),
    ('Piranha','p'),
	('Larves de hareng','c'),
    ('Zooplancton','c'),
	('Rat','c'),
	('Souris','c'),
	('Oiseau','c'),
	('Fourmi','i'),
	('Termite','i'),
	('Araignée','i'),
	('Mouche','i'),
	('Ver','i'),
	('Herbe','h'),
	('Carex','h'),
	('Feuille','h'), ('Feuille','o'),
	('Tige','h'),
	('OEuf','i'),('OEuf','o'),
	('Insecte','i'),('Insecte','o'),
	('Scorpion','i'),
	('Fleur','o'),('Fleur','h'),
	('Jeune pousse','o'),
	('Fruit','o'),('Fruit','h'),('Fruit','i'),
	('Écorce','o'),('Écorce','h'),
	('Branche','o'),('Branche','h'),
	('Bourgeon','o'),('Bourgeon','h'),
	('Calamar','p'),
	('Poisson','p'),
	('Racine','o'),
	('Graminée','h'),
	('Bambou','o'),	('Bambou','h'),
	('Plante','h'),

	('Champignon','i'),
	('Gomme','i'),
	('Chèvre sauvage','c'),
	('Mouton sauvage','c'),
	('Marmotte','c'),
	('Lièvre','c'),
	('Reptile','o'),
	('Sauterelle','o'),
	('Coléoptères','o'),
	('Carcasse','c'),
	('Rongeur','c'),
	('Campagnol','c'),
	('Musaraigne','c'),
	('Taupe','c'),
	('Renard','c'),
	('Lemming','c'),
	('Nectar','o'),
	('Graine','h'),
	('Noix','h'),
	('Baie','h'),
	('Granulé','h'),
	('Légume','h')
;

insert into Manger values 
	("Lion de mer de Steller", 'Hareng'),
	("Lion de mer de Steller", 'Maquereau'),
	("Lion de mer de Steller", 'Esturgeon'),
	("Lion de mer de Steller", 'Saumon'),
	("Lion de mer de Steller", 'Mollusques'),

	("Béluga", 'Morue'),
	("Béluga", 'Hareng'),
	("Béluga", 'Saumon'),
	("Béluga", 'Crevette'),
	("Béluga", 'Calmar'),
	
	("Grande raie-guitare", 'Crustacés'),
	("Grande raie-guitare", 'Invertébrés'),
	("Grande raie-guitare", 'Bivalve'),
	
	("Méduse dorée", 'Zooplancton'),
	("Méduse dorée", 'Crustacés'),
	("Méduse dorée", 'Larves de hareng'),

	("Boto", 'Piranha'),
	("Boto", 'Crabe'),
	("Boto", 'Tortue de rivière'),

	("Python royal", 'Rat'),
	("Python royal", 'Souris'),
	("Python royal", 'Oiseau'),

 	("Rainette jaguar", 'Fourmi'),
	("Rainette jaguar", 'Termite'),
	("Rainette jaguar", 'Ver'),

	("Rainette verte d'Amérique",'Mouche'),
	("Rainette criarde", 'Mouche'),
	("Rainette verte d'Amérique",'Araignée'),
	("Rainette criarde", 'Araignée'),
	("Rainette verte d'Amérique",'Ver'),
	("Rainette criarde", 'Ver'),

	("Tortue géante des Seychelles", 'Herbe'),
	("Tortue géante des Seychelles", 'Carex'),
	("Tortue géante des Seychelles", 'Feuille'),
	("Tortue géante des Seychelles", 'Tige'),
	
	("Panda géant","Bambou"),

    ("Hérisson du désert", 'OEuf'),
	("Hérisson du désert", 'Insecte'),
	("Hérisson du désert", 'Scorpion'),

    ("Girafe", 'Feuille'),
	("Girafe", 'Bourgeon'),
	("Girafe", 'Herbe'),
	("Girafe", 'Fleur'),
	("Girafe", 'Fruit'),

	("Eléphant de forêt d'Afrique", 'Plante'),
	("Eléphant de forêt d'Afrique", 'Fruit'),
	("Eléphant de forêt d'Afrique", 'Feuille'),
	("Eléphant de forêt d'Afrique", 'Branche'),
	("Eléphant de forêt d'Afrique", 'Écorce'),

    ("Panda roux", 'Bambou'),
	("Panda roux", 'Jeune pousse'),
	("Panda roux", 'Fruit'),
	("Panda roux", 'Racine'),

	("Hippopotame", 'Herbe'),
	("Hippopotame", 'Graminée'),

	("Manchot empereur", 'Mollusques'),
	("Manchot empereur", 'Calamar'),
	("Manchot empereur", 'Crustacés'),
	("Manchot empereur", 'Poisson'),

	("Paresseux", 'Feuille'),
	("Paresseux", 'Jeune pousse'),
	("Paresseux", 'Branche'),
	("Paresseux", 'Bourgeon'),
	("Paresseux", 'Fleur'),
	("Paresseux", 'Fruit'),
	("Paresseux", 'Racine'),

	("Maki catta", 'Feuille'),
	("Maki catta", 'Fleur'),
	("Maki catta", 'Fruit'),
	("Maki catta", 'Écorce'),

	("Ouistiti à tête jaune", 'Champignon'),
	("Ouistiti à tête jaune", 'Insecte'),
	("Ouistiti à tête jaune", 'Gomme'),
	("Ouistiti à tête jaune", 'Fruit'),

	("Panthère des neiges", 'Chèvre sauvage'),
	("Panthère des neiges", 'Mouton sauvage'),
	("Panthère des neiges", 'Marmotte'),
	("Panthère des neiges", 'Lièvre'),

    ("Chevêche forestière", 'Reptile'),
	("Chevêche forestière", 'Sauterelle'),
	("Chevêche forestière", 'Coléoptères'),

    ("Vautour à dos blanc", 'Carcasse'),

	("Chouette lapone", 'Rongeur'),
	("Chouette lapone", 'Souris'),
	("Chouette lapone", 'Campagnol'),
	("Chouette lapone", 'Musaraigne'),
	("Chouette lapone", 'Taupe'),

    ("Harfang des neiges", 'Lièvre'),
	("Harfang des neiges", 'Renard'),
	("Harfang des neiges", 'Lemming'),

	("Tamarin lion", 'Fruit'),
	("Tamarin lion", 'Fleur'),
	("Tamarin lion", 'Nectar'),
	("Tamarin lion", 'OEuf'),
	("Tamarin lion", 'Insecte'),

	("Ara militaire", 'Graine'),
	("Ara militaire", 'Noix'),
	("Ara militaire", 'Fruit'),
	("Ara militaire", 'Baie'),

	("Ara à ailes vertes", 'Baie'),
	("Ara à ailes vertes", 'Noix'),
	("Ara à ailes vertes", 'Graine'),

    ("Ara ararauna", 'Graine'),
	("Ara ararauna", 'Granulé'),
	("Ara ararauna", 'Fruit'),
	("Ara ararauna", 'Légume'),
	("Ara ararauna", 'Noix')
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
