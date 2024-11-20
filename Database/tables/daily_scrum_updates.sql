-- Begin transaction
BEGIN TRANSACTION;

-- 1. Create the daily scrum updates table to store updates from daily scrum meetings

CREATE TABLE IF NOT EXISTS daily_scrum_updates
    (update_id SERIAL PRIMARY KEY, -- Unique ID for each scrum update
 daily_scrum_id INT NOT NULL, -- ID of the associated daily scrum
 team_member UUID NOT NULL, -- ID of the team member providing the update
 work_done_yesterday TEXT NOT NULL, -- Description of the work done yesterday
 work_planned_today TEXT NOT NULL, -- Description of the work planned for today
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is created
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is updated
CONSTRAINT fk_daily_scrum_id
     FOREIGN KEY (daily_scrum_id) REFERENCES daily_scrums (daily_scrum_id) -- Foreign key to reference the daily scrum
ON DELETE CASCADE,
          CONSTRAINT fk_team_member
     FOREIGN KEY (team_member) REFERENCES users (user_id) -- Foreign key to reference the team member (user)
ON UPDATE CASCADE);

-- 2. Create indexes for faster look ups

CREATE INDEX idx_daily_scrum_updates_daily_scrum_id ON daily_scrum_updates (daily_scrum_id);


CREATE INDEX idx_daily_scrum_updates_team_member ON daily_scrum_updates (team_member);

-- 3. Create the daily scrum updates olap table

CREATE TABLE IF NOT EXISTS daily_scrum_updates_olap (log_id SERIAL PRIMARY KEY, -- Unique ID for the log
 update_id INTEGER, -- The ID of the update that was changed
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- Stores the info into jsonb format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp when the log entry was made
);

-- 4. Define function to log the changes to the daily_scrum_updates table

CREATE OR REPLACE FUNCTION log_daily_scrum_updates_changes() RETURNS TRIGGER AS $$
BEGIN
    -- log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO daily_scrum_updates_olap (update_id, operation_type, data)
        VALUES (NEW.update_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;
    -- log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO daily_scrum_updates_olap ( update_id, operation_type, data)
        VALUES (NEW.update_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;
    -- log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO daily_scrum_updates_olap (update_id, operation_type, data)
        VALUES (OLD.update_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the daily_scrum_updates_changes function on any insert, update, or delete

CREATE TRIGGER trg_daily_scrum_updates_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON daily_scrum_updates
FOR EACH ROW EXECUTE FUNCTION log_daily_scrum_updates_changes();

-- Commit the transaction to finalize the operation

COMMIT;