-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create the sprint Retrospective table

CREATE TABLE IF NOT EXISTS sprint_retrospectives
    (retrospective_id SERIAL PRIMARY KEY, -- Unique ID for each sprint retrospective
 sprint_id INT NOT NULL, -- ID of the associated sprint
 meeting_date DATE NOT NULL, -- Date of the retrospective meeting
 went_well TEXT, -- Things that went well during the sprint
 needs_improvement TEXT, -- Things that need improvement
 actions_to_take TEXT, -- Actions to be taken for improvement
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Ensure the retrospectives are deleted when the sprint is deleted
 CONSTRAINT fk_sprint_id
     FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Reference to the 'sprints' table
 ON DELETE CASCADE);

-- 2. Create the indexes for faster lookups

CREATE INDEX idx_sprint_retrospectives_sprint_id ON sprint_retrospectives (sprint_id);


CREATE INDEX idx_sprint_retrospectives_meeting_date ON sprint_retrospectives (meeting_date);

-- 3. Create the sprint_retrospectives_olap

CREATE TABLE IF NOT EXISTS sprint_retrospectives_olap (log_id SERIAL PRIMARY KEY, -- Unique identifier for each log
 retrospective_id INTEGER, -- The ID of the associated sprint retrospective
 operation_type VARCHAR(10) NOT NULL, -- Commit the transaction to finalize the operation
 data JSONB NOT NULL, -- Stores info into JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of the log
 );

-- 4. Define function to log changes to the sprint_retrospectives table

CREATE OR REPLACE FUNCTION log_sprint_retrospectives_changes() RETURNS TRIGGER AS $$
BEGIN
    -- log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO sprint_retrospectives_olap (retrospective_id, operation_type, data)
        VALUES (NEW.retrospective_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;
    -- log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Update timestamp
        NEW.updated_at = CURRENT_TIMESTAMP;
        -- log update
        INSERT INTO sprint_retrospectives_olap(retrospective_id, operation_type, data)
        VALUES (NEW.retrospective_id,'UPDATE', row_to_json(NEW));
        RETURN NEW;
    -- log delete of file
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO sprint_retrospectives_olap (retrospective_id, operation_type, data)
        VALUES (OLD.retrospective_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;

    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create trigger to call the log_sprint_retrospectives_changes function on any inset, update, or delete

CREATE TRIGGER trg_sprint_retrospective_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON sprint_retrospectives
FOR EACH ROW EXECUTE FUNCTION log_sprint_retrospectives_changes();

-- Commit the transaction to finalize the operation

COMMIT;