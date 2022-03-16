pragma foreign_keys = true;

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
	race 	varchar(30)		references Espece(race)
);

create table Nourriture(
	id_plat		int		primary key		auto_increment,
	description_plat		varchar(50)
);

create table TypeEnclos(
	id_type_enclos		char(2)		primary key,
	description_type	varchar(50)
);
	
create table Soigneur(
	id_soign	int		primary key		auto_increment,
	date_naissance_soign	date,	--check avant aujourdhui moins 18 ans ?
	nom_soign	 	varchar(30)		not null,
	prenom_soign	varchar(30)		not null,
	sexe_soign		char(1)			check(sexe_soign in ('M', 'F'))	
);

create table Enclos(
	id_enclos	int		primary key		auto_increment,
	nb_actuel	int 	check(nb_actuel >= 0 and nb_actuel<=nb_max),
	nb_max		int		check(nb_max>0),
	taille		int		not null,
	id_type_enclos		char(2)		references TypeEnclos(id_type_enclos)
);

create table Animation(
	id_anim		int		primary key		auto_increment,
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

create table PouvoirCohabiter(
	race_une	varchar(30)		references Espece(race),
	race_deux	varchar(30)		references Espece(race),
	constraint	pkPouvoirCohabiter	primary key (race_une, race_deux)
);

create table Convenir(
	id_plat		int 	references Nourriture(id_plat),
	id_categorie	char(1)		references CategorieNourriture(id_categorie),
	constraint 	pkConvenir	primary key (id_plat, id_categorie)
);

create table Soigner(
	id_soign 	int		references Soigneur(id_soign),
	nom 	varchar(15)		references Animal(nom),
	constraint	pkSoigner	primary key (id_soign, nom)
);

create table PouvoirVivre(
	race	varchar(30)		references Espece(race),
	id_type_enclos	char(2)	references TypeEnclos(id_type_enclos),
	constraint	pkPouvoirVivre	primary key (race, id_type_enclos)
);

create table Occuper(
	nom 	varchar(15)		references Animal(nom),
	id_enclos 	int		references Enclos(id_enclos),
	date_debut	date	not null, --check?
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
create view NombreAnimauxParTypeEnclos as(
	select id_type_enclos, count(1)
	from TypeEnclos natural join Enclos natural join Occuper natural join Animal
	where date_fin != null
	group by id_type_enclos
);

create view NombreAnimauxParEspece as(
	select race, count(1)
	from Espece natural join Animal natural join Occuper
	where date_fin != null
	group by race
);

create view EnclosVide as(
	select id_enclos
	from Enclos
	where nb_actuel = 0
);
create view EnclosNonVide as(
	select id_enclos
	from Enclos
	where nb_actuel > 0
);
create view EnclosPlein as(
	select id_enclos
	from Enclos
	where nb_actuel = nb_max
);

create view QuiPeutMangerQuoi as (
	select distinct race as qui, description_plat as quoi
	from (Espece natural join Appartenir natural join Categorie natural join Convenir natural join Nourriture)
	where 
)

create view QuiMangeVraimentQuoi as (
	select 
)
