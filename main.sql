.open zoo.db
pragma foreign_keys = true;
.headers on
.mode column

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

create table Animal(
	nom		varchar(15)		primary key,
	date_naissance_anim		date  	not null,
	genre	varchar(7)	check(genre in ('Male','Femelle'))  not null,
	poids	float		check(poids>0)	not null,
	origine	varchar(30),
	race 	varchar(30)		references Espece(race),
	id_soign 	int 	references Soigneur(id_soign)
);

create table Nourriture(
	id_plat		integer		primary key		autoincrement,
	description_plat		varchar(50)
);

create table TypeEnclos(
	id_type_enclos		char(2)		primary key,
	description_type	varchar(50)
);
	
create table Soigneur(
	id_soign	integer		primary key		autoincrement,
	date_naissance_soign	date,	--check avant aujourdhui moins 18 ans ?
	nom_soign	 	varchar(30)		not null,
	prenom_soign	varchar(30)		not null,
	sexe_soign		char(1)			check(sexe_soign in ('M', 'F'))	
);

create table Enclos(
	id_enclos	integer		primary key		autoincrement,
	nb_actuel	int 	check(nb_actuel >= 0 and nb_actuel<=nb_max),
	nb_max		int		check(nb_max>0),
	taille		int		not null,
	id_type_enclos		char(2)		references TypeEnclos(id_type_enclos)
);

create table Animation(
	id_anim		integer		primary key		autoincrement,
	duree		int		check(duree > 20)	not null,
	description_anim	varchar(50),
	id_soign	int		references Soignant(id_soign)
);

-- coucou, associations 

create table AvoirParent(
	parent		varchar(15)		references Animal(nom),
	enfant		varchar(15)		references Animal(nom),
	constraint 	pkAvoirParent	primary key (parent, enfant)
);

create table Convenir(
	id_plat		int 	references Nourriture(id_plat),
	id_categorie	char(1)		references CategorieNourriture(id_categorie),
	constraint 	pkConvenir	primary key (id_plat, id_categorie)
);

create table Occuper(
	nom 	varchar(15)		references Animal(nom),
	id_enclos 	int		references Enclos(id_enclos),
	date_debut	date	not null, --check? now
	date_fin	date, --check??
	constraint	pkOccuper	primary key (nom, id_enclos)
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
	select id_type_enclos, count(1)
	from TypeEnclos natural join Enclos natural join Occuper natural join Animal
	where date_fin != null
	group by id_type_enclos
;

create view NombreAnimauxParEspece as
	select race, count(1)
	from Espece natural join Animal natural join Occuper
	where date_fin != null
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
	select id_categorie, plat
	from CategorieNourriture natural join Nourriture
;
create view ListeNourritureParRace as
	select race, plat
	from Espece natural join ListePlatParCategorie
;

create view ListeAnimalPourSoigneur as 
	select id_soign, nom
	from Soigneur natural join Animal
;

create view AnimationAujourdhui as 
	select id_anim
	from Animation
	where date_anim = DATE('nom')
;

-- transaction ??

-- triggers

create trigger ChangementEnclos
after insert on Occuper
begin
	update Occuper set date_fin = DATE('now') where nom = new.nom;
	update Enclos set nb_actuel = nb_actuel - 1 where id_enclos = old.id_enclos;
	update Enclos set nb_actuel = nb_actuel + 1 where id_enclos = new.id_enclos;
end;
