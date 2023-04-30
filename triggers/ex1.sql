-- A trainee can participate at most 3 times
CREATE OR REPLACE TRIGGER validTrainee_max3
    BEFORE INSERT OR UPDATE
    ON SEASONTRAINEE
    FOR EACH ROW
    DECLARE
        v_total NUMBER := 0;
        c_maxSeason NUMBER(1) := 3;
    BEGIN
        SELECT COUNT(*) INTO v_total
        FROM SEASONTRAINEE
        WHERE SSN_TRAINEE = :NEW.SSN_TRAINEE;

        IF v_total = c_maxSeason THEN
            raise_application_error(-20998,'MAX3 Error: The trainee already takes part in 3 times');
        end if;
    END;
select * from SYSTEM.STAGEINCLUDETRAINEE;
-- A trainee already took place in debut night cannot participate in the next season 
CREATE OR REPLACE TRIGGER validTrainee_debut
    BEFORE INSERT OR UPDATE
    ON SEASONTRAINEE
    FOR EACH ROW
    DECLARE
        CURSOR debutTrainee_cur is
            SELECT SSN_TRAINEE
            FROM STAGEINCLUDETRAINEE
            WHERE EP_NO = 5;
    BEGIN
        FOR debutTrainee in debutTrainee_cur LOOP
            IF :NEW.SSN_TRAINEE = debutTrainee.SSN_TRAINEE THEN
                raise_application_error(-20997, 'The trainee was in debut night');
            end if;
        END LOOP;
    END;




