-- Begin the transaction
BEGIN TRANSACTION;

-- 1. Create the daily scrums table to store daily scrum meetings

CREATE TABLE IF NOT EXISTS daily_scrums
    (daily_scrum_id SERIAL PRIMARY KEY, -- Unique ID for each daily scrum
 sprint_id INT NOT NULL, -- ID of the associated sprint
 meeting_date DATE NOT NULL, -- Date of the scrum meeting
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when daily_scrum was created
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- timestamp when the daily_scrum was updated
 CONSTRAINT fk_sprint_id
     FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Foreign key to reference the sprint
 ON DELETE CASCADE);

-- 2. Create the indexes for faster lookups

CREATE INDEX idx_daily_scrums_sprint_id ON daily_scrums (sprint_id);


CREATE INDEX idx_daily_scrums_meeting_date ON daily_scrums (meeting_date);

-- 3. Create the daily_scrums olap table to log changes to the daily scrum table

CREATE TABLE IF NOT EXISTS daily_scrums_olap ( log_id SERIAL PRIMARY KEY; -- Unique ID for each log

daily_scrum_id INTEGER, -- The ID of the daily_scrum that was changed
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- Stores info into jsonb format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of the log
);

-- 4. Define the function to log changes in the olap table

CREATE OR REPLACE FUNCTION log_daily_scrums_changes() RETURNS TRIGGER AS $$
BEGIN
    -- log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO daily_scrums_olap (daily_scrum_id, operation_type, data)
        VALUES (NEW.daily_scrum_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;
    -- log update operations
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO daily_scrums_olap (daily_scrum_id, operation_type, data)
        VALUES (NEW.daily_scrum_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;
    -- log delete operations
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO daily_scrums_olap ( daily_scrum_id, operation_type, data)
        VALUES (OLD.daily_scrum_id, 'DELETE', row_to_json(OLD));
        RETURN NEW;\
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the log daily scrum changes function

CREATE TRIGGER trg_daily_scrums_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON daily_scrums
FOR EACH ROW EXECUTE FUNCTION log_daily_scrums_changes();

-- Commit the transaction to finalize the operation

COMMIT;