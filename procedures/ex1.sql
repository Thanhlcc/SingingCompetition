----------------------------EX1----------------------------
-- -- Create a procedure/function to print list of trainees come to the next episode (or debut if input episode is debut night)

CREATE OR REPLACE TYPE trainee_result AS OBJECT (
    ssn CHAR(12),
    result NUMBER
                                                );
CREATE OR REPLACE TYPE trainee_nextEp AS table of trainee_result;
CREATE OR REPLACE TYPE ep3Stages as OBJECT
    (
    SSN_TRAINEE CHAR(12),
    STAGE_NO NUMBER,
    votes NUMBER,
    TOTAL_VOTE NUMBER,
    SONG_ID CHAR(5)
                                           );
CREATE OR REPLACE TYPE ep3Stages_list AS TABLE OF ep3Stages;

CREATE OR REPLACE FUNCTION take_ep3stages(year IN NUMBER)
RETURN ep3Stages_list
    AS
    cur SYS_REFCURSOR;
    result ep3Stages_list;
    BEGIN
    result := ep3Stages_list();
    OPEN cur FOR
            SELECT ep3Stages(SSN_TRAINEE, STAGE_NO, NO_OF_VOTES, TOTAL_VOTE, SONG_ID)
            FROM STAGE_STAGEINCLUDETRAINEE s
            WHERE s.EP_NO = 3 AND s.YEAR = take_ep3stages.YEAR;
        FETCH cur BULK COLLECT INTO  result;
    CLOSE cur;
    RETURN result;
    END take_ep3stages;
select * from table (take_ep3stages(2020));
-- CREATE OR REPLACE VIEW stages_ep3 as
--     (
--         SELECT SSN_TRAINEE, STAGE_NO, TOTAL_VOTE, SONG_ID FROM STAGE_STAGEINCLUDETRAINEE
--         WHERE EP_NO = 3 AND YEAR = 2021
--     );
---------------------------------------------------------------------------------------------
CREATE OR REPLACE TYPE stageNo as OBJECT
    (
    stage_no NUMBER
                                           );
CREATE OR REPLACE TYPE stageNos_losingGroup AS TABLE OF stageNo;

CREATE OR REPLACE FUNCTION take_losingGroups(year IN NUMBER)
RETURN ep3Stages_list
    AS
    cur SYS_REFCURSOR;
    result stageNos_losingGroup;
    BEGIN
    result := stageNos_losingGroup();
    OPEN cur FOR
                SELECT stageNo(STAGE_NO)
                FROM (
                    SELECT DISTINCT stage_no, TOTAL_VOTE, MIN(TOTAL_VOTE) OVER(partition by SONG_ID) minVote
                    FROM table(take_ep3stages(take_losingGroups.year))
                    WHERE TOTAL_VOTE = minVote
                    );
    FETCH cur BULK COLLECT INTO result;
    CLOSE cur;
    RETURN result;
    END take_losingGroups;

-- select * from table(take_losingGroups(2021));
-- CREATE OR REPLACE VIEW losingGroups as
--     (
--         select STAGE_NO
--         from (
--             SELECT DISTINCT stage_no, TOTAL_VOTE, MIN(TOTAL_VOTE) OVER(partition by SONG_ID) minVote
--             FROM STAGES_EP3
--             )
--         WHERE TOTAL_VOTE = minVote
--     );
-----------------------------------------------------------------------------------------------------------

-- CREATE OR REPLACE VIEW eliminatedTrainees AS
--     (
--     select ssn
--     from (
--         SELECT SSN_TRAINEE ssn, NO_OF_VOTES votes, dense_rank() over (partition by STAGE_NO
--                                                 order by NO_OF_VOTES) rnk
--         FROM STAGEINCLUDETRAINEE natural join losingGroups
--          )
--     WHERE rnk <= 2
--     );

CREATE OR REPLACE TYPE ssn_obj as OBJECT
    (
    ssn CHAR(12)
                                           );
CREATE OR REPLACE TYPE ssn_eliminatedTrainees AS TABLE OF ssn_obj;

CREATE OR REPLACE FUNCTION take_eliminatedTrainee(year IN NUMBER)
RETURN ssn_eliminatedTrainees
    AS
    cur SYS_REFCURSOR;
    result ssn_eliminatedTrainees;
    BEGIN
    result := ssn_eliminatedTrainees();
    OPEN cur FOR
                SELECT ssn_obj(SSN_TRAINEE)
                from (
                    SELECT SSN_TRAINEE , NO_OF_VOTES votes, dense_rank() over (partition by STAGE_NO
                                                            order by NO_OF_VOTES) rnk
                    FROM STAGEINCLUDETRAINEE natural join table(take_losingGroups(take_eliminatedTrainee.year))
                    )
                WHERE rnk <= 2;
    FETCH cur BULK COLLECT INTO result;
    CLOSE cur;
    RETURN result;
    END take_eliminatedTrainee;

-- select * from table(take_eliminatedTrainee(2021));
----------------------------------------------------------------------------------------------------------

create or replace FUNCTION nextEp(year_p1 IN NUMBER, cur_episode_p2 IN NUMBER)
    RETURN trainee_nextEp
AS
    resultTab trainee_nextEp;
	TYPE trainee_t IS RECORD (ssn CHAR(12), result NUMBER);
	seeker SYS_REFCURSOR;
	amt NUMBER := 0;
    BEGIN
        resultTab := trainee_nextEp();
        CASE cur_episode_p2
		WHEN 1 THEN
			amt := 30;
			OPEN seeker FOR
							SELECT trainee_result(SSN_TRAINEE, AVG(SCORE))
							FROM SYSTEM.MENTOREVALUATETRAINEE
							GROUP BY SSN_TRAINEE
							ORDER BY AVG(SCORE) DESC
							FETCH first amt rows only;
		WHEN 3 THEN
            amt := 16;
            OPEN seeker FOR
                            SELECT trainee_result(SSN_TRAINEE, votes)
                            FROM table(take_ep3stages(year_p1))
                            WHERE SSN_TRAINEE not in (SELECT ssn from table(take_eliminatedTrainee(year_p1)));
		ELSE
			IF cur_episode_p2 = 2 THEN amt := 20;
            ELSIF cur_episode_p2 = 4 THEN amt := 10;
			ELSIF cur_episode_p2 = 5 THEN amt := 5;
			ELSE DBMS_OUTPUT.PUT_LINE('Invalid episode number');
			END IF;
			OPEN seeker FOR
							SELECT trainee_result(SSN_TRAINEE, NO_OF_VOTES)
							FROM SYSTEM.STAGEINCLUDETRAINEE
							WHERE YEAR = year_p1 AND EP_NO = cur_episode_p2 AND NO_OF_VOTES is not null
							ORDER BY NO_OF_VOTES DESC
							FETCH first amt rows only;
		END CASE;
		FETCH seeker bulk collect into resultTab;
        RETURN resultTab;
    END nextEp;



