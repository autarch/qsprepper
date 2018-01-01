-- Revert qsprepper:base from pg

BEGIN;

DROP TABLE IF EXISTS subscription_review;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS item;
DROP TABLE IF EXISTS "user";

COMMIT;
