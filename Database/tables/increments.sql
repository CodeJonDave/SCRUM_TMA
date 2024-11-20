-- Begin transaction
BEGIN TRANSACTION;

-- 1. Create the increments table to store sprint increments

CREATE TABLE IF NOT EXISTS increments
    (increment_id SERIAL PRIMARY KEY, -- Unique ID for each increment
 sprint_backlog_item_id INT NOT NULL, -- ID of the associated sprint backlog item
 increment_description TEXT NOT NULL, -- Description of the sprint increment
 submitted_by UUID NOT NUll, -- ID of the team member that submitted
 is_Verified BOOLEAN DEFAULT FALSE, -- Boolean to for verification check
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is created
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is updated
 CONSTRAINT fk_sprint_backlog_item_id
     FOREIGN KEY (sprint_backlog_item_id) REFERENCES sprint_backlog(sprint_backlog_item_id) -- Foreign key to reference the sprint
ON DELETE CASCADE,
	CONSTRAINT fk_submitted_by
     FOREIGN KEY (submitted_by) REFERENCES users(user_id) -- Foreign key to reference the sprint
ON DELETE CASCADE);

-- 2. Create indexes for fast lookups

CREATE INDEX idx_increments_sprint_backlog_item_id ON increments (sprint_backlog_item_id);


CREATE INDEX idx_increments_is_Verified ON increments (is_Verified);

-- 3. Create the increments olap table to log changes in the increments table

CREATE TABLE IF NOT EXISTS increments_olap (log_id SERIAL PRIMARY KEY, -- Unique ID for each log
 increment_id INTEGER, -- The ID of the affected increment
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- Stores info into JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of the log
);

-- 4. Define function to log changes in the sprint_reviews table

CREATE OR REPLACE FUNCTION log_increments_changes() RETURNS TRIGGER AS $$
BEGIN
    --Log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO increments_olap (increment_id, operation_type, data)
        VALUES (NEW.increment_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    -- log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO increments_olap (increment_id, operation_type, data)
        VALUES (NEW.increment_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    -- Log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO increments_olap (increment_id, operation_type, data)
        VALUES (OLD.increment_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the log_sprint_reviews_changes function on any insert, update, or delete

CREATE TRIGGER trg_increments_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON sprint_reviews
FOR EACH ROW EXECUTE FUNCTION log_increments_changes();

-- Commit the transaction to finalize the operation

COMMIT;