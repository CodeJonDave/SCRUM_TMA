-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create roles if they don't already exist
DO $$ 
BEGIN
    -- Check if the role exists before creating it
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'ADMIN') THEN
        CREATE ROLE ADMIN;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'PRODUCT_OWNER') THEN
        CREATE ROLE PRODUCT_OWNER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'SCRUM_MASTER') THEN
        CREATE ROLE SCRUM_MASTER;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'TEAM_MEMBER') THEN
        CREATE ROLE TEAM_MEMBER;
    END IF;
END;
$$ LANGUAGE plpgsql;
-- 2. Grant permissions to existing tables dynamically for ADMINISTRATOR role
DO $$ 
DECLARE
    tbl RECORD;
BEGIN
    FOR tbl IN
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
    LOOP
        EXECUTE format(
            'GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE %I.%I TO ADMIN;',
            tbl.table_schema, tbl.table_name
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Grant permissions on future tables to ADMIN

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT
SELECT,
INSERT,
UPDATE,
DELETE ON TABLES TO ADMIN;

-- 3. Role-specific permissions
-- PRODUCT_OWNER role
GRANT
SELECT ON public.users,
          public.products,
          public.daily_scrums TO PRODUCT_OWNER;

GRANT
SELECT,
UPDATE ON public.increments TO PRODUCT_OWNER;

GRANT
SELECT,
INSERT,
UPDATE ON public.product_backlog,
          public.sprints,
          public.sprint_backlog,
          public.sprint_goals,
          public.sprint_retrospectives,
          public.sprint_reviews,
          public.impediments TO PRODUCT_OWNER;

GRANT
SELECT,
UPDATE ON public.daily_scrum_updates TO PRODUCT_OWNER;

-- SCRUM_MASTER role
GRANT
SELECT ON public.users,
          public.products,
          public.product_backlog TO SCRUM_MASTER;

GRANT
SELECT,
INSERT,
UPDATE ON public.increments,
          public.daily_scrums,
          public.sprints,
          public.sprint_backlog,
          public.sprint_goals,
          public.sprint_retrospectives,
          public.sprint_reviews,
          public.impediments,
          public.daily_scrum_updates TO SCRUM_MASTER;

-- TEAM_MEMBER role
GRANT
SELECT ON public.users,
          public.daily_scrums,
          public.sprint_backlog,
          public.sprint_goals,
          public.sprint_retrospectives,
          public.sprint_reviews TO TEAM_MEMBER;

GRANT
SELECT,
INSERT ON public.impediments TO TEAM_MEMBER;

GRANT
SELECT,
INSERT,
UPDATE ON public.daily_scrum_updates TO TEAM_MEMBER;

-- Commit the transaction to finalize changes
COMMIT;

