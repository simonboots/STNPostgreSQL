-- Drop Table
DROP TABLE IF EXISTS stnpostgresqltests;

-- Create Table
CREATE TABLE stnpostgresqltests (
  id integer NOT NULL,
  name character varying(50)
)
WITHOUT OIDS;
