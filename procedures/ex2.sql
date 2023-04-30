----------------------------EX2-----------------------------
-- Return a table of <ep_No, result> for a given ssn and year
-- Input: ssn, year
-- Output: table of <ep_No, score/votes>
CREATE OR REPLACE type ep_result as OBJECT (
    ep_no NUMBER(1),
    result NUMBER
);
CREATE OR REPLACE type fiveEp_record as TABLE OF ep_result;

CREATE OR REPLACE FUNCTION result_trainee(SSN_p1 IN CHAR, YEAR_p2 IN NUMBER)
    RETURN fiveEp_record
AS
    result_table fiveEp_record;
    CURSOR votes_cur(episode NUMBER) is
                SELECT NO_OF_VOTES
                FROM STAGEINCLUDETRAINEE
                WHERE SSN_TRAINEE = SSN_p1 AND EP_NO = episode AND YEAR = YEAR_p2
                ORDER BY NO_OF_VOTES;
    i NUMBER(1) := 1;
    BEGIN
        result_table := fiveEp_record();
        result_table.extend(5);
        LOOP
            result_table(i) := ep_result(i, NULL);
            IF i = 1 THEN
                SELECT AVG(SCORE) INTO result_table(i).result
                FROM MENTOREVALUATETRAINEE
                WHERE SSN_TRAINEE = SSN_p1 AND YEAR = YEAR_p2;
            ELSE
                IF NOT votes_cur%ISOPEN THEN
                    OPEN votes_cur(i);
                END IF;

                LOOP
                    FETCH votes_cur into result_table(i).result;
                    EXIT WHEN votes_cur%NOTFOUND;
                END LOOP;

                CLOSE votes_cur;
            END IF;
            i := i + 1;
            EXIT WHEN i > result_table.COUNT;
        END LOOP;
        RETURN result_table;
    END;

SELECT * from EMPLOYEE ORDER BY LENGTH(FNAME);

select M.*, F.* FROM (SELECT count(*) from EMPLOYEE where SEX ='M') M,
    (SELECT count(*) from  EMPLOYEE where SEX = 'F') F;