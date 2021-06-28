DROP TABLE IF EXISTS Mafies CASCADE;
DROP TABLE IF EXISTS Districts CASCADE;
DROP TABLE IF EXISTS Persons CASCADE;
DROP TABLE IF EXISTS Hippodromes CASCADE;
DROP TABLE IF EXISTS Bookmakers CASCADE;
DROP TABLE IF EXISTS Horses CASCADE;
DROP TABLE IF EXISTS Races CASCADE;
DROP TABLE IF EXISTS Bets CASCADE;
DROP TABLE IF EXISTS Bribes CASCADE;
DROP TABLE IF EXISTS Kills CASCADE;
DROP TABLE IF EXISTS Horse_in_race CASCADE;
DROP TABLE IF EXISTS Officers CASCADE;
DROP TABLE IF EXISTS Mafia_officer CASCADE;
DROP TABLE IF EXISTS finished_races CASCADE;

DROP FUNCTION IF EXISTS correct_bookmaker();
DROP FUNCTION IF EXISTS correct_kill();
DROP FUNCTION IF EXISTS correct_race();
DROP FUNCTION IF EXISTS hippodrome_in_district();
DROP FUNCTION IF EXISTS live_in_correct_district();
DROP FUNCTION IF EXISTS win_via_bribe();
DROP FUNCTION IF EXISTS finish_race();
DROP FUNCTION IF EXISTS get_coef_by_race_and_winner(integer, integer, coef_in_winner out integer);
DROP FUNCTION IF EXISTS get_winner_for_race(integer, winner_id out integer);
DROP FUNCTION IF EXISTS correct_officer();