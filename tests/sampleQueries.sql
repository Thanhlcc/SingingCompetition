-- At most three seasons
-- test case 1:
-- find who already attends 3 times
SELECT DISTINCT SSN_TRAINEE
FROM SEASONTRAINEE
GROUP BY SSN_TRAINEE
HAVING COUNT(*) = 3;

SELECT * FROM SEASONTRAINEE
    WHERE SSN_TRAINEE = '890502314609';

DELETE FROM SEASONTRAINEE WHERE  SSN_TRAINEE = '890502314609' and YEAR = 2021;


-- total number of votes
-- Testcase;
update STAGEINCLUDETRAINEE set NO_OF_VOTES = 300 where year = 2018 and EP_NO=2 and STAGE_NO= 1821 and SSN_TRAINEE = '232456404174';



select YEAR, MAX(EP_NO) BestPerformance
from STAGEINCLUDETRAINEE
WHERE year in (
                select YEAR
                from SEASONTRAINEE
                where SSN_TRAINEE in (select SSN from PERSON natural join TRAINEE where FNAME = 'James' AND LNAME = 'Cynthia')
               )
GROUP BY YEAR;
select SSN from PERSON natural join TRAINEE;
where FNAME = 'James' AND LNAME = 'Cynthia';
select  * from person;
select * from trainee;




