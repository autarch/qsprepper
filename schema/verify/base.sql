-- Verify qsprepper:base on pg

BEGIN;

SELECT pg_catalog.has_table_privilege('user', 'usage');
SELECT pg_catalog.has_table_privilege('item', 'usage');
SELECT pg_catalog.has_table_privilege('subscription', 'usage');
SELECT pg_catalog.has_table_privilege('subscription_record', 'usage');

ROLLBACK;
