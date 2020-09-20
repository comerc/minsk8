-- how to see trigger
select 
    prosrc
from pg_trigger, pg_proc
where
 pg_proc.oid=pg_trigger.tgfoid
 and pg_trigger.tgname like 'suggestion_inserted';

-- how to create trigger
DROP TRIGGER IF EXISTS before_insert_suggestion ON suggestion;
DROP FUNCTION IF EXISTS before_insert_suggestion();

CREATE FUNCTION before_insert_suggestion()
RETURNS trigger AS $BODY$
  BEGIN
    NEW.member_id := (SELECT member_id FROM unit WHERE id = NEW.unit_id);
    RETURN NEW;
  END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_insert_suggestion BEFORE INSERT ON suggestion FOR EACH ROW EXECUTE PROCEDURE before_insert_suggestion();

-- how to insert comment
-- COMMENT ON TRIGGER before_insert_suggestion ON suggestion IS 'before insert suggestion';

-- how to delete comment
-- COMMENT ON TRIGGER before_insert_suggestion ON suggestion IS NULL;

--
DROP TRIGGER IF EXISTS before_update_want ON want;
DROP FUNCTION IF EXISTS before_update_want();

CREATE FUNCTION before_update_want()
RETURNS trigger AS $BODY$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_update_want BEFORE UPDATE ON want FOR EACH ROW EXECUTE PROCEDURE before_update_want();

--
DROP TRIGGER IF EXISTS after_delete_wish ON wish;
DROP FUNCTION IF EXISTS after_delete_wish();

-- CREATE FUNCTION after_delete_wish()
-- RETURNS trigger AS $BODY$
-- BEGIN
--   UPDATE unit SET total_wishes = total_wishes - 1 WHERE id = OLD.unit_id;
--   RETURN OLD;
-- END;
-- $BODY$ LANGUAGE plpgsql;  

-- CREATE TRIGGER after_delete_wish AFTER DELETE ON wish FOR EACH ROW EXECUTE PROCEDURE after_delete_wish();

--
DROP TRIGGER IF EXISTS after_insert_wish ON wish;
DROP FUNCTION IF EXISTS after_insert_wish();

CREATE FUNCTION after_insert_wish()
RETURNS trigger AS $BODY$
DECLARE _one INTEGER;
BEGIN
  IF NEW.value THEN
    _one := 1;
  ELSE
    _one := -1;
  END IF;
  UPDATE unit SET total_wishes = total_wishes + _one WHERE id = NEW.unit_id;
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER after_insert_wish AFTER INSERT ON wish FOR EACH ROW EXECUTE PROCEDURE after_insert_wish();

--
DROP TRIGGER IF EXISTS after_update_wish ON wish;
DROP FUNCTION IF EXISTS after_update_wish();

CREATE FUNCTION after_update_wish()
RETURNS trigger AS $BODY$
DECLARE _one INTEGER;
BEGIN
  IF OLD.value != NEW.value THEN 
    IF NEW.value THEN
      _one := 1;
    ELSE
      _one := -1;
    END IF;
    UPDATE unit SET total_wishes = total_wishes + _one WHERE id = NEW.unit_id;
  END IF;
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER after_update_wish AFTER UPDATE ON wish FOR EACH ROW EXECUTE PROCEDURE after_update_wish();

--
DROP TRIGGER IF EXISTS after_insert_member ON member;
DROP FUNCTION IF EXISTS after_insert_member();

CREATE FUNCTION after_insert_member()
RETURNS trigger AS $BODY$
DECLARE _start_payment INTEGER;
BEGIN
  _start_payment := 4;
  INSERT INTO profile (member_id, balance) VALUES (NEW.id, _start_payment);
  INSERT INTO payment (member_id, account, value) VALUES (NEW.id, 'start', _start_payment);
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER after_insert_member AFTER INSERT ON member FOR EACH ROW EXECUTE PROCEDURE after_insert_member();

-- TODO: [MVP] NEW.value получаю с клиента - неправильно
--
DROP TRIGGER IF EXISTS before_insert_payment ON payment;
DROP FUNCTION IF EXISTS before_insert_payment();

CREATE FUNCTION before_insert_payment()
RETURNS trigger AS $BODY$
DECLARE _balance INTEGER;
DECLARE _count INTEGER;
DECLARE _limit INTEGER;
BEGIN
  _balance := (SELECT balance FROM profile WHERE member_id = NEW.member_id);
  IF NEW.account = 'limit' THEN
    IF NEW.unit_id IS NULL THEN
      RAISE EXCEPTION 'Argument "unit_id" must be not null';
    END IF;
    IF NEW.value IS NOT NULL THEN
      RAISE EXCEPTION 'Argument "value" must be null';
    END IF;
    _count := (SELECT count(*) FROM payment 
      WHERE created_at > now() - interval '1 day' AND account = 'limit' AND member_id = NEW.member_id);
    IF _balance >= 7 THEN
      _limit = 10;
    ELSE
      _limit = _balance + 3;
    END IF;
    NEW.value := _limit - _count - 1;
    IF NEW.value < 0 THEN
      RAISE EXCEPTION 'Calculated argument "value" must be greater than 0';
    END IF;
  ELSIF NEW.account = 'freeze' THEN
    IF NEW.unit_id IS NULL THEN
      RAISE EXCEPTION 'Argument "unit_id" must be not null';
    END IF;
    _balance := _balance + NEW.value;
    IF _balance < 0 THEN
      RAISE EXCEPTION 'Argument "balance" must be greater than 0';
    END IF;
    UPDATE profile SET balance = _balance WHERE member_id = NEW.member_id;
  ELSIF NEW.account = 'unfreeze' THEN
    IF NEW.unit_id IS NULL THEN
      RAISE EXCEPTION 'Argument "unit_id" must be not null';
    END IF;
    IF NEW.text_variant IS NULL THEN
      RAISE EXCEPTION 'Argument "text_variant" must be not null';
    END IF;
    _balance := _balance + NEW.value;
    UPDATE profile SET balance = _balance WHERE member_id = NEW.member_id;
  ELSIF NEW.account = 'invite' THEN
    IF NEW.invited_member_id IS NULL THEN
      RAISE EXCEPTION 'Argument "invited_member_id" must be not null';
    END IF;
    _balance := _balance + NEW.value;
    UPDATE profile SET balance = _balance WHERE member_id = NEW.member_id;
  ELSIF NEW.account = 'profit' THEN
    _balance := _balance + NEW.value;
    UPDATE profile SET balance = _balance WHERE member_id = NEW.member_id;
  END IF;
  NEW.balance = _balance;
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;  

CREATE TRIGGER before_insert_payment BEFORE INSERT ON payment FOR EACH ROW EXECUTE PROCEDURE before_insert_payment();
