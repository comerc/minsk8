-- how to see trigger
select 
    prosrc
from pg_trigger, pg_proc
where
 pg_proc.oid=pg_trigger.tgfoid
 and pg_trigger.tgname like 'suggestion_inserted'

-- how to create trigger
CREATE FUNCTION before_insert_suggestion()
RETURNS trigger AS $BODY$
  BEGIN
    NEW.member_id := (SELECT member_id FROM unit WHERE id = NEW.unit_id);
    RETURN NEW;
  END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_insert_suggestion BEFORE INSERT ON "suggestion" FOR EACH ROW EXECUTE PROCEDURE before_insert_suggestion();

-- how to insert comment
-- COMMENT ON TRIGGER before_insert_suggestion ON suggestion IS 'before insert suggestion';

-- how to delete comment
-- COMMENT ON TRIGGER before_insert_suggestion ON suggestion IS NULL;

--
CREATE FUNCTION before_update_want()
RETURNS trigger AS $BODY$
BEGIN
  NEW."updated_at" = NOW();
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_update_want BEFORE UPDATE ON "want" FOR EACH ROW EXECUTE PROCEDURE before_update_want();

--
CREATE FUNCTION after_delete_wish()
RETURNS trigger AS $BODY$
BEGIN
  UPDATE unit SET total_wishes = total_wishes - 1 WHERE id = OLD.unit_id;
  RETURN OLD;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER after_delete_wish AFTER DELETE ON "wish" FOR EACH ROW EXECUTE PROCEDURE after_delete_wish();

--
CREATE FUNCTION after_insert_wish()
RETURNS trigger AS $BODY$
BEGIN
  UPDATE unit SET total_wishes = total_wishes + 1 WHERE id = NEW.unit_id;
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER after_insert_wish AFTER INSERT ON "wish" FOR EACH ROW EXECUTE PROCEDURE after_insert_wish();

--
CREATE FUNCTION before_insert_member()
RETURNS trigger AS $BODY$
  BEGIN
    INSERT INTO profile (member_id) VALUES (NEW.id);
    RETURN NEW;
  END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_insert_member BEFORE INSERT ON "member" FOR EACH ROW EXECUTE PROCEDURE before_insert_member();
