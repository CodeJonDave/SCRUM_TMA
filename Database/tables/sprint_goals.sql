-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create sprint goals table

CREATE TABLE IF NOT EXISTS sprint_goals
    (sprint_goal_id SERIAL PRIMARY KEY, -- Unique identifier for each sprint goal
 sprint_id INT NOT NULL, -- References the sprint for which the goal is set
 goal_description TEXT NOT NULL, -- Describes the specific goal for the sprint
 is_achieved BOOLEAN DEFAULT FALSE, -- Indicates whether the goal was achieved; defaults to false
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the sprint goal was created
updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the sprint was last updated
 CONSTRAINT fk_sprint_id
     FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Reference to the 'sprints' table.
 ON DELETE CASCADE);

-- 2. Create indexes for fast lookups

CREATE INDEX idx_sprint_goals_sprint_id ON sprint_goals (sprint_id);


CREATE INDEX idx_sprint_goals_is_achieved ON sprint_goals (is_achieved);

-- 3. Create the sprint_goals olap table to log changes in the sprint_goals table

CREATE TABLE IF NOT EXISTS sprint_goals_olap (log_id SERIAL PRIMARY KEY, -- Unique ID for each log
 sprint_goal_id INTEGER, -- The ID of the sprint_goal
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- Stores the full sprint goal data in JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of when the operation occurred
);

-- 4. Define the function to log the changes to the products table

CREATE OR REPLACE FUNCTION log_sprint_goals_changes() RETURNS TRIGGER AS $$
BEGIN
    -- log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO sprint_goals_olap (sprint_goal_id, operation_type, data)
        VALUES (NEW.sprint_goal_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    -- log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sprint_goals_olap (sprint_goal_id, operation_type, data)
        VALUES (NEW.sprint_goal_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    -- log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO sprint_goals_olap (sprint_goal_id, operation_type, data)
        VALUES (OLD.sprint_goal_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the log changes function on any insert, update, delete

CREATE TRIGGER trg_sprint_goals_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON sprint_goals
FOR EACH ROW EXECUTE FUNCTION log_sprint_goals_changes();

-- Commit the transaction to finalize the operation

COMMIT;