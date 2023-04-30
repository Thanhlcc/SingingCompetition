--------------------------Q2-------------------------
-- calculate the total number of votes of a group
-- when number of votes of a member is updated
create or replace trigger TOTAL_VOTE
    before insert or update or delete
    on STAGEINCLUDETRAINEE
    for each row
BEGIN
    IF DELETING  THEN
		UPDATE STAGE SET total_vote = total_vote - :OLD.NO_OF_VOTES
        WHERE YEAR = :OLD.year and STAGE_NO = :OLD.STAGE_NO and EP_NO = :OLD.EP_NO;
	END IF;
    IF (UPDATING OR INSERTING) AND :NEW.NO_OF_VOTES != 0 THEN
        UPDATE STAGE SET total_vote = total_vote - :OLD.NO_OF_VOTES
        WHERE YEAR = :OLD.year and STAGE_NO = :OLD.STAGE_NO and EP_NO = :OLD.EP_NO;

		UPDATE STAGE SET total_vote = total_vote + :NEW.NO_OF_VOTES
        WHERE YEAR = :NEW.year and STAGE_NO = :NEW.STAGE_NO and EP_NO = :NEW.EP_NO;
    END IF;
END;