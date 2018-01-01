-- Deploy qsprepper:base to pg

BEGIN;

CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP DOMAIN IF EXISTS email;
/* FROM https://dba.stackexchange.com/a/165923 */
CREATE DOMAIN email AS CITEXT
  CHECK ( value ~ '^[a-zA-Z0-9.!#$%&''*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$' );

DROP DOMAIN IF EXISTS zero_to_one;
CREATE DOMAIN zero_to_one AS DECIMAL
  CHECK ( value >= 0 and value <= 1.0 );

CREATE TABLE "user" (
    user_id    UUID      PRIMARY KEY DEFAULT uuid_generate_v4(),
    name       CITEXT    NOT NULL,
    email      email     NOT NULL,
    password   char(64)  NOT NULL
);

CREATE TABLE item (
    item_id     UUID         PRIMARY KEY DEFAULT uuid_generate_v4(),
    name        CITEXT       NOT NULL,
    content     TEXT         NOT NULL,
    difficulty  zero_to_one  DEFAULT 0.3
);

COMMENT ON TABLE item IS 'This is anything that can be included in a reminder.';

COMMENT ON COLUMN item.content IS 'This is stored as CommonMark text.';

-- See
-- http://www.blueraja.com/blog/477/a-better-spaced-repetition-learning-algorithm-sm2
-- for the algorithm that determines what values we store.

CREATE TABLE subscription (
    subscription_id       UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id               UUID        NOT NULL REFERENCES "user" (user_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    item_id               UUID        NOT NULL REFERENCES item (item_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    days_between_reviews  SMALLINT    DEFAULT 1,
    UNIQUE ( user_id, item_id )
);

COMMENT ON TABLE subscription IS
    'A user can subscribe to one or more items. These are the things for which they receive spaced reminders.';

CREATE TABLE subscription_review (
    subscription_id    UUID         NOT NULL REFERENCES subscription (subscription_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    review_date        DATE         NOT NULL,
    success            zero_to_one  NOT NULL,
    PRIMARY KEY ( subscription_id, review_date )
);

COMMENT ON TABLE subscription_review IS
    'The record of a user reviewing an item. We use this to calculate the next time to send an item.';

COMMIT;
