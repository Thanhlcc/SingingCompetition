---------------------------Q3------------------------------
-- A trainee has at most one group in episode 2, 3, and 4
-- and has one solo stage and one group stage in the final stage (if he/she comes to the final)
CREATE OR REPLACE TRIGGER groupNo_check
    BEFORE INSERT OR UPDATE
    ON STAGEINCLUDETRAINEE
    FOR EACH ROW
    DECLARE
        CURSOR groupStage_cur IS
            SELECT IS_GROUP
            FROM STAGE natural join STAGEINCLUDETRAINEE
            WHERE YEAR = :NEW.YEAR AND EP_NO = :NEW.EP_NO AND SSN_TRAINEE = :NEW.SSN_TRAINEE;
        v_isGroup STAGE.IS_GROUP%TYPE;
        v_isGroupNew STAGE.IS_GROUP%TYPE;
    BEGIN
        SELECT IS_GROUP into v_isGroupNew
        FROM STAGE
        WHERE :NEW.EP_NO = EP_NO AND :NEW.YEAR = YEAR AND :NEW.STAGE_NO = STAGE_NO;

        OPEN groupStage_cur;
        FETCH groupStage_cur INTO v_isGroup;

        IF :NEW.EP_NO in (2, 3, 4) THEN
            DBMS_OUTPUT.PUT_LINE(UPPER(v_isGroupNew));
            IF groupStage_cur%ROWCOUNT = 1 THEN
                raise_application_error(-20996, 'NOGROUP_ERROR_ep234');
            ELSIF UPPER(trim(v_isGroupNew)) = 'NO' THEN
                raise_application_error(-20995, 'Must be a group performance');
            END IF;
        ELSIF :NEW.EP_NO = 5 THEN
            IF (groupStage_cur%ROWCOUNT = 1 AND v_isGroup = v_isGroupNew)
                OR groupStage_cur%ROWCOUNT = 2 THEN
                raise_application_error(-20994, 'NOGROUP_ERROR_ep5');
            END IF;
        END IF;

        CLOSE groupStage_cur;
    END;