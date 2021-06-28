CREATE TABLE Mafies
(
 id serial PRIMARY KEY,
 name varchar(20) NOT NULL,
 nation varchar(20),
 authority real DEFAULT 0 NOT NULL,
 wealth bigint DEFAULT 0,
 CONSTRAINT limits_authority
     CHECK ( authority >= 0 AND authority <= 10)
);

CREATE TABLE Districts
(
 id serial PRIMARY KEY,
 name varchar(50) NOT NULL,
 owner integer REFERENCES Mafies (id) ON DELETE SET NULL ON UPDATE CASCADE ,
 population integer DEFAULT 0 NOT NULL CHECK (population >= 0)
);

CREATE TABLE Persons
(
 id serial PRIMARY KEY,
 full_name varchar(50) NOT NULL,
 gender char(1),
 date_birth date,
 job varchar(20) NOT NULL,
 respect integer DEFAULT 1 NOT NULL ,
 live_in integer NOT NULL REFERENCES Districts (id) ON DELETE CASCADE ON UPDATE CASCADE,
 mafia_family integer DEFAULT NULL REFERENCES Mafies (id) ON DELETE CASCADE ON UPDATE CASCADE,
 CONSTRAINT correct_gender
   CHECK ( gender =  'm' OR gender = 'f'),
 CONSTRAINT correct_job
   CHECK ( job = 'unemployed' OR
           job = 'ordinary' OR
           job = 'mafia' OR
           job = 'officer' OR
           job = 'bookmaker'
          ),
 CONSTRAINT limits_respect
   CHECK ( respect >= 1 AND respect <= 5 ),
 CONSTRAINT limits_mafia
   CHECK (
        ((job = 'mafia' OR job='bookmaker') AND mafia_family IS NOT NULL)
        OR ((job = 'unemployed' OR job='ordinary' OR job='officer') AND mafia_family IS NULL)
    )
);

CREATE TABLE Hippodromes
(
 id serial PRIMARY KEY,
 name varchar(20) NOT NULL,
 number_of_seats integer DEFAULT 100 NOT NULL CHECK (number_of_seats > 0),
 district integer NOT NULL REFERENCES Districts (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Bookmakers
(
 id serial PRIMARY KEY,
 person integer NOT NULL REFERENCES Persons (id) ON DELETE CASCADE ON UPDATE CASCADE,
 coefficient real DEFAULT 0.95 NOT NULL
);

CREATE TABLE Horses
(
 id serial PRIMARY KEY,
 name varchar(20) NOT NULL,
 gender char(1) NOT NULL,
 weight integer CHECK (weight > 0),
 age integer CHECK (age > 0 AND age < 65),
 power integer DEFAULT 5 NOT NULL CHECK (power > 0 AND power <=10),
 popularity integer DEFAULT 5 NOT NULL CHECK (popularity >= 0 AND popularity <=10),
 luck real DEFAULT 0.5 NOT NULL CHECK (luck >= 0 AND luck <=1),
 CONSTRAINT correct_gender
   CHECK ( gender =  'm' OR gender = 'f')
);

CREATE TABLE Races
(
 id serial PRIMARY KEY,
 time_start timestamp DEFAULT current_timestamp NOT NULL,
 is_finished boolean DEFAULT FALSE NOT NULL,
 is_ready_to_start boolean DEFAULT FALSE NOT NULL,
 predicted_winner integer REFERENCES Horses (id) ON DELETE CASCADE ON UPDATE CASCADE,
 fake_winner integer REFERENCES Horses (id) ON DELETE RESTRICT ON UPDATE CASCADE,
 hippodrome integer NOT NULL REFERENCES Hippodromes (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Horse_in_race
(
 id serial PRIMARY KEY,
 race_id integer NOT NULL REFERENCES Races (id) ON DELETE CASCADE ON UPDATE CASCADE,
 horse_id integer NOT NULL REFERENCES Horses (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Bets
(
 id serial PRIMARY KEY,
 amount integer NOT NULL,
 bookmaker integer NOT NULL REFERENCES Bookmakers (id) ON DELETE NO ACTION ON UPDATE CASCADE,
 who_put integer NOT NULL REFERENCES Persons (id) ON DELETE NO ACTION ON UPDATE CASCADE,
 horse_in_race integer NOT NULL REFERENCES Horse_in_race (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Officers
(
 id serial PRIMARY KEY,
 person integer NOT NULL REFERENCES Persons (id) ON DELETE CASCADE ON UPDATE CASCADE,
 rank varchar(20) NOT NULL check (rank = 'general' or rank = 'lieutenant' or rank = 'major' or rank = 'captain')
);

CREATE TABLE Bribes
(
 id serial PRIMARY KEY,
 sender integer NOT NULL REFERENCES Persons (id) ON DELETE NO ACTION ON UPDATE CASCADE,
 addressee integer NOT NULL REFERENCES Officers (id) ON DELETE NO ACTION ON UPDATE CASCADE ,
 amount integer NOT NULL,
 horse_in_race integer NOT NULL REFERENCES Horse_in_race (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Mafia_officer
(
 officer integer REFERENCES Officers (id) ON DELETE CASCADE ON UPDATE CASCADE,
 mafia_family integer REFERENCES Mafies (id) ON DELETE CASCADE ON UPDATE CASCADE,
 relationship integer DEFAULT 5 NOT NULL CHECK (relationship > 0 AND relationship <= 10),
 PRIMARY KEY (officer,mafia_family)
);

CREATE TABLE Kills
(
 id serial PRIMARY KEY,
 killer integer REFERENCES Persons (id) ON DELETE NO ACTION ON UPDATE CASCADE ,
 victim integer NOT NULL REFERENCES Persons (id) ON DELETE CASCADE ON UPDATE CASCADE,
 time_to_die timestamp NOT NULL,
 crime_place integer NOT NULL REFERENCES Districts (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE Finished_races
(
    race_id integer PRIMARY KEY,
    mafia_id integer
);

CREATE INDEX officer_mafia_idx ON Mafia_officer(mafia_family);
