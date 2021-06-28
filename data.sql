INSERT INTO Mafies(name, nation, authority, wealth) VALUES ('Peaky Blinders', 'Irish', 8.5, 89000);
INSERT INTO Mafies(name, nation, authority, wealth) VALUES ('Camden Town gang', 'Jewish', 6.5, 77000);
INSERT INTO Mafies(name, nation, authority, wealth) VALUES ('Sabinis', 'Italian', 9.5, 217000);

INSERT INTO Districts(name, owner, population) VALUES ('Jewellery quarter', 2, 4500);
INSERT INTO Districts(name, owner, population) VALUES ('Gay village', 3, 7700);
INSERT INTO Districts(name, owner, population) VALUES ('Newtown', 1, 11000);
INSERT INTO Districts(name, owner, population) VALUES ('Lozells and east Handsworth', 1, 17000);
INSERT INTO Districts(name, owner, population) VALUES ('Edgebaston', 3, 14000);
INSERT INTO Districts(name, owner, population) VALUES ('Small heath', 2, 2500);
INSERT INTO Districts(name, owner, population) VALUES ('Soltley', 3, 8000);

INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Thomas Shelby', 'm', '1897-08-17', 'mafia', 5, 3, 1);
INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Chester Campbell', 'm', '1889-08-27', 'officer', 5, 3, NULL);
INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Alfred Solomons', 'm', '1892-03-09', 'mafia', 5, 1, 2);
INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Joe Cole', 'm', '1899-12-25', 'mafia', 3, 3, 1);
INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Darby Sabini', 'm', '1888-04-02', 'mafia', 4, 2, 3);
INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Jeremiah Jesus', 'm', '1890-04-02', 'bookmaker', 2, 3, 1);

INSERT INTO Hippodromes(name, number_of_seats, district) VALUES ('Main Newtown', 420, 3);
-- INSERT INTO Hippodromes(name, number_of_seats, district) VALUES ('Arthur Hippodrome', 250, 1);

INSERT INTO Officers(person, rank) VALUES (2, 'general');

INSERT INTO Bookmakers(person, coefficient) VALUES (6, 0.90);

INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);
INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES ('Fast Polly', 'f', 460, 10, 9, 9, 0.4);

INSERT INTO Races(time_start, predicted_winner, fake_winner, hippodrome) VALUES ('1924-06-09 14:00:00', 1, NULL, 1);

INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 1);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 2);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 3);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 4);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 5);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 6);
INSERT INTO Horse_in_race(race_id, horse_id) VALUES (1, 7);

INSERT INTO Bets(amount, bookmaker, who_put, horse_in_race) VALUES (2000, 1, 4, 3);

-- INSERT INTO Bribes(sender, addressee, amount, horse_in_race) VALUES (1, 1, 1000, 1);

INSERT INTO Kills(killer, victim, time_to_die, crime_place) VALUES (1, 3, '1922-07-08 08:52:56', 6);

INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family)
   VALUES ('Nobody', 'm', '1897-08-17', 'mafia', 5, 3, 2);



