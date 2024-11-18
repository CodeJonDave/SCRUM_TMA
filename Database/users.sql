-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create the 'users' table

CREATE TABLE IF NOT EXISTS users (user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(), -- Unique user ID generated automatically
 user_role VARCHAR(25) NOT NULL, -- User's role (e.g., 'admin', 'user')
 username VARCHAR(50) NOT NULL UNIQUE, -- Unique username
 email VARCHAR(100) NOT NULL UNIQUE, -- Unique email
 password_hash TEXT NOT NULL, -- Encrypted password
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of creation
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of last update
);

-- 2. Create indexes for faster lookups

CREATE INDEX IF NOT EXISTS idx_users_email ON users (email);


CREATE INDEX IF NOT EXISTS idx_users_username ON users (username);

-- 3. Create the 'users_olap' table for auditing

CREATE TABLE IF NOT EXISTS users_olap (log_id SERIAL PRIMARY KEY, -- Unique log ID
 user_id UUID NOT NULL, -- References the affected user
 operation_type VARCHAR(10) NOT NULL, -- Operation type: 'INSERT', 'UPDATE', 'DELETE'
 data JSONB NOT NULL, -- Stores full row data in JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of the operation
);

-- 4. Function to log changes on the 'users' table

CREATE OR REPLACE FUNCTION log_user_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO users_olap (user_id, operation_type, data)
        VALUES (NEW.user_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO users_olap (user_id, operation_type, data)
        VALUES (NEW.user_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO users_olap (user_id, operation_type, data)
        VALUES (OLD.user_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Trigger to call the log_user_changes function on the 'users' table

CREATE TRIGGER trg_users_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON users
FOR EACH ROW EXECUTE FUNCTION log_user_changes();

-- 6. Function to dynamically assign DB role based on 'user_role'

CREATE OR REPLACE FUNCTION assign_user_role() RETURNS TRIGGER AS $$
BEGIN
    EXECUTE format('GRANT %I TO %I', NEW.user_role, NEW.username);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Trigger to assign roles upon user insertion

CREATE TRIGGER trg_assign_role AFTER
INSERT ON users
FOR EACH ROW EXECUTE FUNCTION assign_user_role();

-- Ensure the 'pgcrypto' extension is enabled for UUID generation
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
        CREATE EXTENSION pgcrypto;
    END IF;
END;
$$;

-- Commit all changes in the transaction

COMMIT;

