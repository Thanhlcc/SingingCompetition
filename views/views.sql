
CREATE OR REPLACE TYPE trainee_result AS OBJECT (
    ssn CHAR(12),
    result NUMBER
                                                );
CREATE OR REPLACE TYPE trainee_nextEp AS table of trainee_result;


CREATE OR REPLACE VIEW stages_ep3 as
    (
        SELECT * FROM STAGE natural join STAGEINCLUDETRAINEE
        WHERE EP_NO = 3 AND YEAR = 2021
    );

CREATE OR REPLACE VIEW losingGroups as
    (
        select STAGE_NO
        from (
            SELECT DISTINCT stage_no, TOTAL_VOTE, MIN(TOTAL_VOTE) OVER(partition by SONG_ID) minVote
            FROM STAGES_EP3
            )
        WHERE TOTAL_VOTE = minVote
    );

CREATE OR REPLACE VIEW eliminatedTrainees AS
    (
    select ssn
    from (
        SELECT SSN_TRAINEE ssn, NO_OF_VOTES votes, dense_rank() over (partition by STAGE_NO
                                                order by NO_OF_VOTES asc) rnk
        FROM STAGEINCLUDETRAINEE natural join losingGroups
         )
    WHERE rnk <= 2
    );

create or replace FUNCTION nextEp(year_p1 IN NUMBER, cur_episode_p2 IN NUMBER)
    RETURN trainee_nextEp
AS
    resultTab trainee_nextEp;
	TYPE trainee_t IS RECORD (ssn CHAR(12), result NUMBER);
	seeker SYS_REFCURSOR;
    cnt NUMBER := 1;
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

		ELSE
			IF cur_episode_p2 = 2 THEN amt := 20;
            ELSIF cur_episode_p2 = 4 THEN amt := 10;
			ELSIF cur_episode_p2 = 5 THEN amt := 5;
			ELSE DBMS_OUTPUT.PUT_LINE('Invalid episode number');
			END IF;
			OPEN seeker FOR
							SELECT trainee_result(SSN_TRAINEE, NO_OF_VOTES)
							FROM SYSTEM.STAGEINCLUDETRAINEE
							WHERE YEAR = year_p1 AND EP_NO = cur_episode_p2
							ORDER BY NO_OF_VOTES DESC
							FETCH first amt rows only;
		END CASE;
		resultTab.extend(amt);
		LOOP
			FETCH seeker INTO resultTab(cnt);
			cnt := cnt + 1;
			EXIT WHEN seeker%NOTFOUND;
		END LOOP;
        RETURN resultTab;
    END nextEp;

