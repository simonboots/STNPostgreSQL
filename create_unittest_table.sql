-- Drop Table
DROP TABLE IF EXISTS stnpostgresqltests;

-- Create Table
CREATE TABLE stnpostgresqltests (
  id integer NOT NULL,
  name character varying(50)
)
WITHOUT OIDS;

-- Insert some dummy data
INSERT INTO stnpostgresqltests VALUES(1, 'foo');
INSERT INTO stnpostgresqltests VALUES(2, 'bar');
INSERT INTO stnpostgresqltests VALUES(3, 'baz');
INSERT INTO stnpostgresqltests VALUES(4, 'bazz');
