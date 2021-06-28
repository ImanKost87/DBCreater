CREATE OR REPLACE FUNCTION live_in_correct_district() RETURNS TRIGGER
    AS $$
    DECLARE
--         Проверка на то, что букмекер/мафия живет в своем раойне. Если оказывается что нет,
--         то меняем просто его принадлежность к той мафии, где он живет.
        mafia_id integer;
    BEGIN
        SELECT owner INTO mafia_id FROM Districts m WHERE m.id = NEW.live_in;
        IF (NEW.mafia_family IS NOT NULL AND NEW.mafia_family != mafia_id) THEN
            UPDATE Persons SET mafia_family = mafia_id WHERE id = NEW.id;
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER live_in_correct_district
    AFTER INSERT OR UPDATE ON Persons
    FOR EACH ROW EXECUTE PROCEDURE live_in_correct_district();

CREATE OR REPLACE FUNCTION correct_kill() RETURNS TRIGGER
    AS $$
    DECLARE
--         Здесь все, что связано с убийством
        mafia_id integer;
        owner_id integer;
        time_die timestamp;
        person_respect integer;
        mafia_authority real;
        authority_up real;
        killer_job varchar(20);
        victim_job varchar(20);
    BEGIN
        SELECT time_to_die INTO time_die FROM Kills k WHERE k.victim = NEW.killer;
        IF FOUND THEN
            IF (time_die > NEW.time_to_die) THEN
            RAISE EXCEPTION 'Убийца уже умер, поэтому убийство не могло быть совершенно';
            END IF;
        END IF;

        SELECT job INTO killer_job FROM Persons p WHERE p.id = NEW.killer;
        SELECT job INTO victim_job FROM Persons p WHERE p.id = NEW.victim;

        IF (killer_job != 'mafia') THEN
            RAISE EXCEPTION 'Только мафия может убивать';
        ELSIF (killer_job = 'mafia' AND victim_job = 'officer') THEN
            RAISE EXCEPTION 'Мафия не может убить офицера';
        ELSE
--             убытки и прибыль (денег, авторитет) для нормального убийства.
            SELECT owner INTO owner_id FROM Districts d WHERE d.id = NEW.crime_place;
            SELECT mafia_family INTO mafia_id FROM Persons p WHERE p.id = NEW.killer;
            SELECT respect INTO person_respect FROM Persons p WHERE p.id = NEW.victim;
            SELECT authority INTO mafia_authority FROM Mafies m WHERE m.id = mafia_id;
--             приход авторитета зависит от авторитета общего.
            authority_up := person_respect * (10 - mafia_authority) / 100;
            IF (mafia_id = owner_id) THEN
                UPDATE Mafies m SET authority = authority + authority_up WHERE m.id = owner_id;
            ELSE
                UPDATE Mafies m SET authority = authority + 1.5 * authority_up,
                                  wealth = wealth - person_respect * 100 WHERE m.id = mafia_id;
            END IF;
            RETURN NEW;
        END IF;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER correct_kill
    BEFORE INSERT OR UPDATE ON Kills
    FOR EACH ROW EXECUTE PROCEDURE correct_kill();

CREATE OR REPLACE FUNCTION win_via_bribe() RETURNS TRIGGER
    AS $$
    DECLARE
        bribe_race_id integer;
        race_district_id integer;
        officer_district_id integer;
        officer_person_id integer;
        bribe_horse_id integer;
        mafia_id integer;
        mafia_wealth bigint;
        need_money integer;
        addressee_relationship integer;
        officer_rank varchar;
        rank_coef integer;
    BEGIN
        SELECT Hippodromes.district INTO race_district_id FROM Races JOIN Hippodromes ON (Races.hippodrome = Hippodromes.id);
        SELECT person INTO officer_person_id FROM Officers WHERE id = NEW.addressee;
        SELECT Persons.live_in INTO officer_district_id FROM Officers JOIN Persons ON (officer_person_id = Persons.id);

        IF (race_district_id != officer_district_id) THEN
            RAISE EXCEPTION 'Вы подкупаете не того офицера';
        END IF;

        SELECT race_id INTO bribe_race_id FROM Horse_in_race hir WHERE hir.id = NEW.horse_in_race;
        SELECT horse_id INTO bribe_horse_id FROM Horse_in_race hir WHERE hir.id = NEW.horse_in_race;
        SELECT mafia_family INTO mafia_id FROM Persons p WHERE p.id = NEW.sender;
        SELECT relationship INTO addressee_relationship FROM Mafia_officer mo WHERE mo.officer = NEW.addressee AND
                                                                                    mo.mafia_family = mafia_id;


        IF NOT FOUND THEN
            INSERT INTO Mafia_officer (officer, mafia_family) VALUES (NEW.addressee, mafia_id) RETURNING relationship INTO addressee_relationship;
        END IF;

        SELECT rank INTO officer_rank FROM Officers of WHERE of.id = NEW.addressee;
        case officer_rank
            when 'general' then
                rank_coef = 4;
            when 'captain' then
                rank_coef = 3;
            when 'major' then
                rank_coef = 2;
            else
                rank_coef = 1;
        end case;

        need_money := (11 - addressee_relationship) * rank_coef * 150;

        SELECT wealth INTO mafia_wealth FROM Mafies WHERE id = mafia_id;
        IF (NEW.amount > mafia_wealth) THEN
            RAISE EXCEPTION 'Недостаточно денег, чтобы дать взятку';
        ELSIF (need_money <= NEW.amount) THEN
            UPDATE Races r SET fake_winner = bribe_horse_id WHERE r.id = bribe_race_id;
            UPDATE Mafies m SET wealth = wealth - NEW.amount WHERE m.id = mafia_id;
            RETURN NEW;
        END IF;
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER win_via_bribe
    AFTER INSERT OR UPDATE ON Bribes
    FOR EACH ROW EXECUTE PROCEDURE win_via_bribe();

CREATE OR REPLACE FUNCTION correct_officer() RETURNS TRIGGER
    AS $$
    DECLARE
        person_job varchar(20);
    BEGIN
        SELECT job INTO person_job FROM Persons p WHERE p.id = NEW.person;
        IF (person_job != 'officer') THEN
            RAISE EXCEPTION 'Этот человек не офицер';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER correct_officer
    BEFORE INSERT OR UPDATE ON Officers
    FOR EACH ROW EXECUTE PROCEDURE correct_officer();

CREATE OR REPLACE FUNCTION correct_bookmaker() RETURNS TRIGGER
    AS $$
    DECLARE
        person_job varchar(20);
    BEGIN
        SELECT job INTO person_job FROM Persons p WHERE p.id = NEW.person;
        IF (person_job != 'bookmaker') THEN
            RAISE EXCEPTION 'Этот человек не букмекер';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER correct_bookmaker
    BEFORE INSERT OR UPDATE ON Bookmakers
    FOR EACH ROW EXECUTE PROCEDURE correct_bookmaker();

CREATE OR REPLACE FUNCTION hippodrome_in_district() RETURNS TRIGGER
    AS $$
    DECLARE
--         Проверяем, чтобы ипподром был, только там где население больше 5000
        population_district integer;
    BEGIN
        SELECT population INTO population_district FROM Districts d WHERE d.id = NEW.district;
        IF (population_district < 5000) THEN
            RAISE EXCEPTION 'В таком маленьком районе не может быть ипподрома';
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER hippodrome_in_district
    BEFORE INSERT OR UPDATE ON Hippodromes
    FOR EACH ROW EXECUTE PROCEDURE hippodrome_in_district();

CREATE OR REPLACE FUNCTION correct_race() RETURNS TRIGGER
    AS $$
    DECLARE
        count_horses integer;
        raceid integer;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            SELECT count(horse_id) INTO count_horses FROM Horse_in_race hr WHERE hr.race_id = OLD.race_id;
            raceid := old.race_id;
        ELSIF (TG_OP = 'UPDATE') THEN
            SELECT count(horse_id) INTO count_horses FROM Horse_in_race hr WHERE hr.race_id = NEW.race_id;
            raceid := new.race_id;
        ELSIF (TG_OP = 'INSERT') THEN
            SELECT count(horse_id) INTO count_horses FROM Horse_in_race hr WHERE hr.race_id = NEW.race_id;
            raceid := new.race_id;
        END IF;
--         SELECT count(horse_id) INTO count_horses FROM Horse_in_race hr WHERE hr.race_id = NEW.race_id;
        IF NOT FOUND THEN
            RETURN NULL;
        ELSIF (count_horses < 6 OR count_horses > 10) THEN
            UPDATE Races SET is_ready_to_start = FALSE WHERE id = raceid;
        ELSIF (count_horses >= 6 AND count_horses <= 10) THEN
            UPDATE Races SET is_ready_to_start = TRUE WHERE id = raceid;
        END IF;
        RETURN NULL;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER correct_race
    AFTER INSERT OR UPDATE OR DELETE ON Horse_in_race
    FOR EACH ROW EXECUTE PROCEDURE correct_race();

CREATE OR REPLACE FUNCTION get_winner_for_race(
   race integer,
   OUT winner_id integer
   )
    AS $$
    BEGIN
        SELECT h.id INTO winner_id FROM Horse_in_race JOIN Horses h ON (Horse_in_race.horse_id = h.id) WHERE race_id = race ORDER BY (h.power*0.6+h.luck*4) DESC LIMIT 1;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_coef_by_race_and_winner(
   race integer,
   winner integer,
   OUT coef_on_winner integer
   )
    AS $$
    DECLARE
        horse_winner_order integer;
    BEGIN
        SELECT row_number INTO horse_winner_order FROM (SELECT horse_id,
        ROW_NUMBER() OVER (
           ORDER BY h.power*0.6+h.luck*4 DESC
        ) FROM Horse_in_race
        JOIN Horses h ON (Horse_in_race.horse_id = h.id) WHERE race_id = race) as winners where horse_id = winner;
    coef_on_winner := horse_winner_order / 10;
    END;
    $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION finish_race() RETURNS TRIGGER
    AS $$
    DECLARE
        district_id integer;
        hippodrome_id integer;
        correct_mafia_id integer;
        time_start_race timestamp;
        race_fake_winner integer;
        winner_by_params integer;
        final_winner integer;
        coef_on_winner real;
        winner_bets_in_percent real;
    BEGIN
        SELECT time_start INTO time_start_race FROM Races r WHERE r.id = NEW.race_id;
        SELECT hippodrome INTO hippodrome_id FROM Races r WHERE r.id = NEW.race_id;
        SELECT district INTO district_id FROM Hippodromes h WHERE h.id = hippodrome_id;
        SELECT owner INTO correct_mafia_id FROM Districts d WHERE d.id = district_id;
        IF (time_start_race <= current_timestamp AND NEW.mafia_id = correct_mafia_id) THEN
            UPDATE Races r SET is_finished = TRUE WHERE r.id = NEW.race_id;
            -- тут происходит все самое интересное
            -- 1 определяем победителя гонки
            winner_by_params := get_winner_for_race(NEW.race_id);
            UPDATE Races SET predicted_winner = winner_by_params WHERE id = NEW.race_id;  --справлено
            SELECT fake_winner INTO race_fake_winner FROM Races WHERE id = NEW.race_id;
            final_winner := COALESCE(race_fake_winner, winner_by_params); --исправлено
            -- 2 рассчитываем коэф для выплаты выигрышных ставок
            coef_on_winner := get_coef_by_race_and_winner(NEW.race_id, final_winner);
            -- 3 рассчитываем все ставки, чистые выигрыша списываем со счета мафии, проигрышы переводим мафии
            UPDATE Mafies m SET wealth = wealth - COALESCE((
                SELECT ceil(sum(b.amount)*coef_on_winner) FROM Bets b JOIN Horse_in_race hir ON (b.horse_in_race = hir.id)
                WHERE hir.race_id = NEW.race_id AND hir.horse_id = final_winner
            ),0) WHERE m.id = NEW.mafia_id;

            UPDATE Mafies m SET wealth = wealth + COALESCE((
                SELECT floor(sum(b.amount*bkmk.coefficient)) FROM Bets b
                JOIN Bookmakers bkmk ON (b.bookmaker=bkmk.id)
                JOIN Horse_in_race hir ON (b.horse_in_race = hir.id)
                WHERE hir.race_id = NEW.race_id AND hir.horse_id != final_winner
            ), 0) WHERE m.id = NEW.mafia_id;

            -- 4 расчет прибыли от продажи билетов
            UPDATE Mafies m SET wealth = wealth + COALESCE((
                SELECT floor(number_of_seats*20*((
                   SELECT authority FROM Mafies WHERE id = NEW.mafia_id
                )/10.0)*((
                   SELECT h.popularity FROM Horse_in_race hir
                   JOIN Horses h ON (hir.horse_id = h.id)
                   WHERE hir.race_id=NEW.race_id ORDER BY h.popularity DESC LIMIT 1
                )/10.0)) FROM Hippodromes
                WHERE id = hippodrome_id
            ), 0) WHERE m.id = NEW.mafia_id;

            -- 5 увеличиваем характеристики выигравшей лошади
            UPDATE horses SET
            luck = round((luck + (1 - luck) * 0.1)::numeric, 3),
            popularity = ceil(popularity + (10 - popularity) * 0.1)
            WHERE id = final_winner;


            -- 6 расчет процента выигрышных ставок (<40%, понижение авторитета мафии)
--             SELECT round((
--                 SELECT count(*) FROM Bets b JOIN Horse_in_race hir ON (b.horse_in_race = hir.id) WHERE hir.race_id = NEW.race_id AND hir.horse_id = final_winner
--             )/GREATEST(((
--                 SELECT count(*) FROM Bets b JOIN Horse_in_race hir ON (b.horse_in_race = hir.id) WHERE hir.race_id = NEW.race_id
--             )::numeric, 3), 1))*100 INTO winner_bets_in_percent;

            SELECT round((
                SELECT count(*) FROM Bets b JOIN Horse_in_race hir ON (b.horse_in_race = hir.id) WHERE hir.race_id = NEW.race_id AND hir.horse_id = final_winner
                )/GREATEST((
                SELECT count(*) FROM Bets b JOIN Horse_in_race hir ON (b.horse_in_race = hir.id) WHERE hir.race_id = NEW.race_id
                    )::numeric, 1), 3)*100 INTO winner_bets_in_percent;


            IF (winner_bets_in_percent < 40) THEN
                UPDATE Mafies m SET authority = authority-(authority * 0.1) WHERE m.id = NEW.mafia_id;
            END IF;

            RETURN NEW;
        ELSE
            RAISE EXCEPTION 'Вы не можете завершить гонку';
        END IF;
    END;
    $$ LANGUAGE plpgsql;

CREATE TRIGGER finish_race
    BEFORE INSERT OR UPDATE ON Finished_races
    FOR EACH ROW EXECUTE PROCEDURE finish_race();