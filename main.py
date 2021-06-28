from random import choice, uniform


def generate_any_table(numHippo):
    outputInFile = ''
    numberOfHippodromes = numHippo
    listOfOfficers = []
    listOfBookmakers = []
    listOfPopulationDistricts = []
    # generate table Mafies
    for i in range(numberOfMafies):
        outputInFile += 'INSERT INTO Mafies(name, nation, authority, wealth) VALUES (' + \
                        ', '.join([nameMafies[i],
                        nation[choice(range(0, len(nation)))],
                        str(round(uniform(0, 10), 2)),
                        str(int(uniform(15000, 500000)))]) + \
                        ');\n'
    outputInFile += '\n'
    # generate table District
    for i in range(numberOfDistricts):
        population = int(uniform(0, 12000))
        listOfPopulationDistricts.append(population)
        outputInFile += 'INSERT INTO Districts(name, owner, population) VALUES (' + \
                        ', '.join([nameDistricts[i],
                                   str(choice(range(1, 11))),
                                   str(population)]) + \
                        ');\n'
    outputInFile += '\n'
    # generate table Persons and Bookmakers and Officers
    for i in range(numberOfPersons):
        personJob = generate_random_job(jobsPersons)
        outputInFile += 'INSERT INTO Persons(full_name, gender, date_birth, job, respect, live_in, mafia_family) VALUES (' + \
                        ', '.join([generate_random_full_name(firstName, secondName),
                                   ['\'m\'', '\'f\''][choice([0, 1])],
                                   generate_random_date(),
                                   personJob,
                                   str(choice(range(1, 6))),
                                   str(choice(range(1, 26))),
                                   str(choice(range(1, 11))) if (personJob == '\'mafia\'' or personJob == '\'bookmaker\'') else 'NULL']) + \
                        ');\n'
        if personJob == '\'officer\'':
            listOfOfficers.append(i)
            outputInFile += 'INSERT INTO Officers(person, rank) VALUES (' + \
                            ', '.join([str(i + 1),
                                       rankOfficers[choice(range(len(rankOfficers)))]]) + \
                            ');\n'
        elif personJob == '\'bookmaker\'':
            listOfBookmakers.append(i)
            outputInFile += 'INSERT INTO Bookmakers(person, coefficient) VALUES (' + \
                            ', '.join([str(i + 1),
                                       str(round(uniform(0.85, 0.95), 2))]) + \
                            ');\n'
    # generate table Hippodromes
    for i in range(numberOfDistricts):
        if listOfPopulationDistricts[i] >= 5000: # Для того чтобы не сработал триггер
            numberOfHippodromes += 1 # Убрать для того чтобы сработал триггер, если надо
            outputInFile += 'INSERT INTO Hippodromes(name, number_of_seats, district) VALUES (' + \
                            ', '.join(['\'Hippodrome' + str(i + 1) + '\'',
                                       str(choice(range(120, 300))),
                                       str(i + 1)]) + \
                            ');\n'
    # generate table Horses
    for i in range(numberOfHorses):
        outputInFile += 'INSERT INTO Horses(name, gender, weight, age, power, popularity, luck) VALUES (' + \
                        ', '.join([horsesName[choice(range(len(horsesName)))],
                                   ['\'m\'', '\'f\''][choice([0, 1])],
                                   str(choice(range(400, 650))),
                                   str(choice(range(5, 15))),
                                   str(choice(range(1, 11))),
                                   str(choice(range(1, 11))),
                                   str(round(uniform(0, 1), 2))]) + \
                        ');\n'
    # generate table Races
    for i in range(numberOfRaces):
        hipp = choice(range(1, numberOfHippodromes + 1));
        outputInFile += 'INSERT INTO Races(time_start, predicted_winner, fake_winner, hippodrome) VALUES (' + \
                        ', '.join([generate_random_date(),
                                   str(choice(range(1, numberOfHorses + 1))),
                                   'NULL',
                                   str(hipp)]) + \
                        ');\n'
    # generate table Horse_in_race
    for i in range(numberOfHorseInRace):
        outputInFile += 'INSERT INTO Horse_in_race(race_id, horse_id) VALUES (' + \
                        ', '.join([str(choice(range(1, 51))),
                                   str(choice(range(1, 121)))]) + \
                        ');\n'
    # generate table Bets
    for i in range(numberOfBets):
        outputInFile += 'INSERT INTO Bets(amount, bookmaker, who_put, horse_in_race) VALUES (' + \
                        ', '.join([str(choice(range(10, 1000))),
                                   str(choice(range(1, len(listOfBookmakers) + 1))),
                                   str(choice(range(1, numberOfPersons + 1))),
                                   str(choice(range(1, 375 + 1)))]) + \
                        ');\n'
    # generate table Bribes
    for i in range(numberOfBribes):
        outputInFile += 'INSERT INTO Bribes(sender, addressee, amount, horse_in_race) VALUES (' + \
                        ', '.join([str(choice(range(1, numberOfPersons + 1))),
                                   str(choice(range(1, len(listOfOfficers) + 1))),
                                   str(choice(range(1, 10000))),
                                   str(choice(range(1, numberOfHorseInRace + 1)))]) + \
                        ');\n'
    # generate table Mafia_officer
    for i in range(len(listOfOfficers)):
        for j in range(numberOfMafies):
            outputInFile +=  'INSERT INTO Mafia_officer(officer, mafia_family, relationship) VALUES (' + \
                             ', '.join([str(i + 1),
                                        str(j + 1),
                                        str(choice(range(1, 11)))]) + \
                             ');\n'
    # generate table Kills
    for i in range(numberOfKills):
        outputInFile += 'INSERT INTO Kills(killer, victim, time_to_die, crime_place) VALUES (' + \
                        ', '.join([str(choice(range(1, numberOfPersons + 1))),
                                   str(choice(range(1, numberOfPersons + 1))),
                                   generate_random_date(),
                                   str(choice(range(1, numberOfDistricts + 1)))]) + \
                        ');\n'
    return outputInFile



def generate_random_full_name(name, surname):
    return '\'' + name[choice(range(0, len(name)))] + ' ' + surname[choice(range(0, len(surname)))] + '\''

def generate_random_date():
    if choice([8, 9]) == 8:
        return '\'18' + \
               str(choice([7, 8, 9]) * 10 + choice(range(0, 10))) + \
               '-' + \
               str(choice(range(1, 13))) + \
               '-' + \
               str(choice(range(1, 29))) + \
               '\''
    else:
        return '\'190' + str(choice(range(0, 4))) + \
               '-' + \
               str(choice(range(1, 13))) + \
               '-' + \
               str(choice(range(1, 29))) + \
               '\''

def generate_random_job(jobs):
    return '\'' + jobs[choice(range(len(jobs)))] + '\''


numberOfMafies = 10
numberOfDistricts = 25
numberOfPersons = 100
numberOfHippodromes = 0 # Равно кол-ву районов, 0 для того чтобы не сработал триггер
numberOfHorses = 120
numberOfRaces = 50
numberOfHorseInRace = 375
numberOfBets = 120
numberOfBribes = 30
numberOfKills = 15

firstName = ["Thomas", "John", "Billy", "Joe", "Alfred", "Chester", "Jeremiah"]
secondName = ["Shelby", "Campbell", "Solomons", "Cole", "Sabini", "Jesus"]
nameMafies = ['\'Sabinis\'', '\'Camden Town gang\'', '\'Peaky Blinders\'', '\'The Kray Twins\'', '\'The Hunt syndicate\'',
              '\'Arif family\'', '\'Liverpudlian mafia\'', '\'Tottenham Mandem\'', '\'The Cartel\'', '\'Kenneth Noye firm\'']
nation = ['\'Irish\'', '\'Jewish\'', '\'Italian\'', '\'English\'']
nameDistricts = ['\'Jewellery quarter\'', '\'Gay village\'', '\'Newtown\'', '\'Lozells and east Handsworth\'', '\'Edgebaston\'',
                 '\'Small heath\'', '\'Soltley\'', '\'Sparkbrook\'', '\'Moseley\'', '\'Hall Green\'',
                 '\'Kings Heath\'', '\'Edgbaston\'', '\'Chinese Quarter\'', '\'West Bromwich\'', '\'Smethwick\'',
                 '\'Blackheath\'', '\'Halesowen\'', '\'Cradley Heath\'', '\'Frankley Green\'', '\'Rubery\'',
                 '\'Rednal\'', '\'Longbridge\'', '\'Romsley\'', '\'Stourbridge\'', '\'Hagley\'']
jobsPersons = ['unemployed', 'ordinary', 'mafia', 'officer', 'bookmaker']
rankOfficers = ['\'general\'', '\'lieutenant\'', '\'major\'', '\'captain\'']
horsesName = ['\'Far\'', '\'Fast\'', '\'Fire\'', '\'Fox\'', '\'Frog\'',
              '\'Frost\'', '\'Grass\'', '\'Gray\'', '\'Green\'', '\'Hawk\'',
              '\'Love\'', '\'Mini\'', '\'Mist\'', '\'Money\'', '\'Raven\'',
              '\'Rock\'', '\'Rose\'']

with open('new_data.sql', 'w') as data:
    data.write(generate_any_table(numberOfHippodromes))