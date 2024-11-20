-- Begin transaction
BEGIN TRANSACTION;

-- 1. Create Impediments table

CREATE TABLE IF NOT EXISTS impediments
        (impediment_id SERIAL PRIMARY KEY, -- Unique ID for each impediment
sprint_backlog_item_id INT NOT NULL, -- References the sprint in which the impediment occurred
 impediment_description TEXT NOT NULL, -- Description of the impediment
 raised_by_user_id UUID NOT NULL, -- The user who raised the impediment
 status VARCHAR(30) CHECK (status IN ('Open',
                                      'In Progress',
                                      'Resolved',
                                      'Closed')) DEFAULT 'Open', -- Status values:
 -- 'Open'         : The impediment has been identified but not yet addressed.
 -- 'In Progress'  : The impediment is being actively worked on or mitigated.
 -- 'Resolved'     : The impediment has been resolved.
 -- 'Closed'       : The impediment has been closed (whether resolved or deemed no longer relevant).
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the impediment was raised
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the impediment was last updated
 resolved_at TIMESTAMP, -- Timestamp when the impediment was resolved
CONSTRAINT fk_sprint_backlog_item
         FOREIGN KEY (sprint_backlog_item_id) REFERENCES sprint_backlog(sprint_backlog_item_id)-- Links to the sprint_backlog table
ON DELETE CASCADE,
          CONSTRAINT fk_raised_by_user_id
         FOREIGN KEY (raised_by_user_id) REFERENCES users (user_id) -- link the users table
ON UPDATE CASCADE);

-- 2. Create the indexes for faster look ups

CREATE INDEX idx_impediments_sprint_backlog_item_id ON impediments (sprint_backlog_item_id);


CREATE INDEX idx_impediments_raised_by_user_id ON impediments (raised_by_user_id);


CREATE INDEX idx_impediments_status ON impediments (status);

-- 3. Create the olap table for logging impediments

CREATE TABLE IF NOT EXISTS impediments_olap (log_id SERIAL PRIMARY KEY, -- Unique ID for each log
 impediment_id INTEGER, -- ID of the impediment that was affected
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- The info in JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

-- 4. Define the function for logging changes

CREATE OR REPLACE FUNCTION log_impediments_changes() RETURNS TRIGGER AS $$
BEGIN
        -- log inset operations
        IF(TG_OP = 'INSERT')THEN
                INSERT INTO impediments_olap (impediment_id, operation_type, data)
                VALUES (NEW.impediment_id, 'INSERT', row_to_json(NEW));
                RETURN NEW;
        -- log update operations
        ELSIF (TG_OP = 'UPDATE') THEN
                INSERT INTO impediments_olap (impediment_id, operation_type, data)
                VALUES (NEW.impediment_id, operation_type, row_to_json(NEW));
                RETURN NEW;
        -- log delete operations
        ELSIF (TG_OP = 'DELETE') THEN
                INSERT INTO impediments_olap (impediment_id, operation_type, data)
                VALUES (OLD.impediment_id, 'DELETE', row_to_json(OLD));
                RETURN NEW;
        END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create trigger to call the log_impediment_changes function on any insert, update, or delete

CREATE TRIGGER trg_impediments_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON impediments
FOR EACH ROW EXECUTE FUNCTION log_impediments_changes();

-- Commit transaction to finalize the operation

COMMIT;