-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create the roles

CREATE ROLE IF NOT EXISTS ADMIN;


CREATE ROLE IF NOT EXISTS PRODUCT_OWNER;


CREATE ROLE IF NOT EXISTS SCRUM_MASTER;


CREATE ROLE IF NOT EXISTS TEAM_MEMBER;

-- 2. Grant permissions to the roles based on necessity
 -- ADMIN role
 -- grants permissions to the ADMIN role for existing tables
 DO $$
    DECLARE
        tbl RECORD;
    BEGIN
        FOR tbl IN
            SELECT table_schema, table_name
            FROM information_schema.tables
            WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
        LOOP
            EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE %I.%I TO ADMIN;', tbl.table_schema, tbl.table_name);
        END LOOP;
    END;
    $$;

-- grants permissions for the ADMIN role for all future tables

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT
SELECT,
INSERT,
UPDATE,
DELETE ON TABLES TO ADMIN;

-- grants permissions to the product owner role
GRANT
SELECT,
UPDATE ON -- Commit the transaction
