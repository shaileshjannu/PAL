-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PREDICT";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_RF_P');
DROP TABLE "DATA";
DROP TABLE "PREDICT";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("ID" INTEGER, "POLICY" NVARCHAR(10), "AGE" INTEGER, "AMOUNT" INTEGER, "OCCUPATION" NVARCHAR(10));
CREATE TYPE "T_PREDICT" AS TABLE ("ID" INTEGER, "FRAUD" VARCHAR(1000), "SCORE" DOUBLE);
CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_MODEL', 'IN');
INSERT INTO "SIGNATURE" VALUES (4, 'DEVUSER', 'T_PREDICT', 'OUT');
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'RANDOMFORESTSCORING', 'DEVUSER', 'P_RF_P', "SIGNATURE");

-- data setup
CREATE COLUMN TABLE "DATA" LIKE "T_DATA";
CREATE COLUMN TABLE "PREDICT" LIKE "T_PREDICT";

INSERT INTO "DATA" VALUES (1, 'Travel', 56, 350, 'IT');
INSERT INTO "DATA" VALUES (2, 'Vehicle', 26, 6230, 'Marketing');
INSERT INTO "DATA" VALUES (3, 'Home', 55, 2300, 'Marketing');
INSERT INTO "DATA" VALUES (4, 'Vehicle', 31, 2134, 'Marketing');
INSERT INTO "DATA" VALUES (5, 'Vehicle', 64, 1200, 'Sales');

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";

TRUNCATE TABLE "PREDICT";

CALL "P_RF_P" ("DATA", "#PARAMS", "MODEL", "PREDICT") WITH OVERVIEW;

SELECT d.*, p."FRAUD", "SCORE" 
 FROM "DATA" d
 INNER JOIN "PREDICT" p ON (p."ID"=d."ID")
 ;
