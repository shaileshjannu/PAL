-- cleanup
DROP TYPE "T_DATA";
DROP TYPE "T_PARAMS";
DROP TYPE "T_ESTIMATES";
DROP TYPE "T_STATS1";
DROP TYPE "T_STATS2";
DROP TABLE "SIGNATURE";
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_DROP"('DEVUSER', 'P_KMS');
DROP TABLE "DATA";
DROP TABLE "ESTIMATES";
DROP TABLE "STATS1";
DROP TABLE "STATS2";

-- procedure setup
CREATE TYPE "T_DATA" AS TABLE ("TIME" INTEGER, "STATUS" INTEGER, "OCCURRENCES" INTEGER, "GROUP" VARCHAR(10));
CREATE TYPE "T_PARAMS" AS TABLE ("NAME" VARCHAR(60), "INTARGS" INTEGER, "DOUBLEARGS" DOUBLE, "STRINGARGS" VARCHAR(100));
CREATE TYPE "T_ESTIMATES" AS TABLE ("GROUP" VARCHAR(10), "TIME" INTEGER, "ATRISK" INTEGER, "OCCURRENCES" INTEGER,
"PROBABILITY" DOUBLE, "STDERR" DOUBLE, "LOWERLIMIT" DOUBLE, "UPPERLIMIT" DOUBLE);
CREATE TYPE "T_STATS1" AS TABLE ("GROUP" VARCHAR(10), "ATRISK" INTEGER, "OCCURRENCES" INTEGER, "EXPECTED" DOUBLE, "LOGRANK" DOUBLE);
CREATE TYPE "T_STATS2" AS TABLE ("NAME" VARCHAR(60), "VALUE" DOUBLE);

CREATE COLUMN TABLE "SIGNATURE" ("POSITION" INTEGER, "SCHEMA_NAME" NVARCHAR(256), "TYPE_NAME" NVARCHAR(256), "PARAMETER_TYPE" VARCHAR(7));
INSERT INTO "SIGNATURE" VALUES (1, 'DEVUSER', 'T_DATA', 'IN');
INSERT INTO "SIGNATURE" VALUES (2, 'DEVUSER', 'T_PARAMS', 'IN');
INSERT INTO "SIGNATURE" VALUES (3, 'DEVUSER', 'T_ESTIMATES', 'OUT');
INSERT INTO "SIGNATURE" VALUES (4, 'DEVUSER', 'T_STATS1', 'OUT');
INSERT INTO "SIGNATURE" VALUES (5, 'DEVUSER', 'T_STATS2', 'OUT');
CALL "SYS"."AFLLANG_WRAPPER_PROCEDURE_CREATE"('AFLPAL', 'KMSURV', 'DEVUSER', 'P_KMS', "SIGNATURE");

-- data setup
CREATE COLUMN TABLE "DATA" LIKE "T_DATA";
INSERT INTO "DATA" VALUES (1, 1, 2, 'Drug A');
INSERT INTO "DATA" VALUES (2, 1, 1, 'Drug A');
INSERT INTO "DATA" VALUES (3, 0, 1, 'Drug A');
INSERT INTO "DATA" VALUES (4, 0, 1, 'Drug A');
INSERT INTO "DATA" VALUES (5, 1, 1, 'Drug A');
INSERT INTO "DATA" VALUES (6, 0, 1, 'Drug A');
INSERT INTO "DATA" VALUES (7, 1, 1, 'Drug A');
INSERT INTO "DATA" VALUES (7, 1, 1, 'Drug A');
INSERT INTO "DATA" VALUES (8, 0, 2, 'Drug A');
INSERT INTO "DATA" VALUES (9, 1, 3, 'Drug A');
INSERT INTO "DATA" VALUES (10, 0, 1, 'Drug A');
INSERT INTO "DATA" VALUES (11, 1, 1, 'Drug A');
INSERT INTO "DATA" VALUES (12, 0, 1, 'Drug A');
/*
INSERT INTO "DATA" VALUES (1, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (2, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (3, 1, 3, 'Placebo');
INSERT INTO "DATA" VALUES (4, 1, 2, 'Placebo');
INSERT INTO "DATA" VALUES (5, 1, 2, 'Placebo');
INSERT INTO "DATA" VALUES (6, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (7, 0, 1, 'Placebo');
INSERT INTO "DATA" VALUES (8, 1, 2, 'Placebo');
INSERT INTO "DATA" VALUES (9, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (10, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (11, 1, 1, 'Placebo');
INSERT INTO "DATA" VALUES (12, 0, 1, 'Placebo');
*/

CREATE COLUMN TABLE "ESTIMATES" LIKE "T_ESTIMATES";
CREATE COLUMN TABLE "STATS1" LIKE "T_STATS1";
CREATE COLUMN TABLE "STATS2" LIKE "T_STATS2";

-- runtime
DROP TABLE "#PARAMS";
CREATE LOCAL TEMPORARY COLUMN TABLE "#PARAMS" LIKE "T_PARAMS";
--INSERT INTO "#PARAMS" VALUES ('EVENT_INDICATOR', 1, null, null); -- value when event (eg. death/failure) has occurred (default: 1)
--INSERT INTO "#PARAMS" VALUES ('CONF_LEVEL', null, 0.90, null); -- Confidence Limit Level (default: 0.95)

TRUNCATE TABLE "ESTIMATES";
TRUNCATE TABLE "STATS1";
TRUNCATE TABLE "STATS2";

CALL "P_KMS" ("DATA", "#PARAMS", "ESTIMATES", "STATS1", "STATS2") WITH OVERVIEW;

SELECT * FROM "ESTIMATES";
SELECT * FROM "STATS1";
SELECT * FROM "STATS2"
