

psql -f dump.2015092501.sql 
psql

ALTER DATABASE "datosabier_prod" RENAME "datosabier_old";
ALTER DATABASE "datosabier_stag" RENAME "datosabier_prod";
ALTER DATABASE datosabier_prod OWNER TO datosabier_prod; 
\c datosabier_prod;
REASSIGN OWNED BY datosabier_stag TO datosabier_prod;


