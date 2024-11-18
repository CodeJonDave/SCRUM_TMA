-- Begin a transaction to ensure atomicity for all operations
BEGIN;

-- 1. Create the Sprint Backlog Table

CREATE TABLE IF NOT EXISTS sprint_backlog
        (sprint_backlog_item_id SERIAL PRIMARY KEY, -- Unique ID for each sprint backlog item
 sprint_id INT NOT NULL, -- Sprint associated with the backlog item
 product_backlog_item_id INT, -- Product Backlog item ID (linked to product backlog)
 assigned_team_member INT NOT NULL, -- Team member responsible for the backlog item
 status VARCHAR(30) CHECK (status IN ('To Do',
                                      'In Progress',
                                      'Blocked',
                                      'In Review',
                                      'Done',
                                      'Carried Over',
                                      'Removed')) DEFAULT 'To Do', -- Status with default value
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of creation
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp of the last update
 -- Ensures a unique combination of sprint and product backlog item
 UNIQUE (sprint_id,
         product_backlog_item_id), -- Foreign Key constraints
 CONSTRAINT fk_product_backlog_item_id
         FOREIGN KEY (product_backlog_item_id) REFERENCES product_backlog (backlog_item_id) ON DELETE CASCADE,
                                                                                                      CONSTRAINT fk_sprint_id
         FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) ON DELETE CASCADE,
                                                                          CONSTRAINT fk_assigned_team_member
         FOREIGN KEY (assigned_team_member) REFERENCES users (user_id));

-- 2. Create indexes for faster lookups

CREATE INDEX IF NOT EXISTS idx_sprint_backlog_sprint_id ON sprint_backlog (sprint_id);


CREATE INDEX IF NOT EXISTS idx_sprint_backlog_assigned_team_member ON sprint_backlog (assigned_team_member);


CREATE INDEX IF NOT EXISTS idx_sprint_backlog_status ON sprint_backlog (status);

-- 3. Create the sprint_backlog_olap table to store changes to the sprint_backlog

CREATE TABLE IF NOT EXISTS sprint_backlog_olap (log_id, SERIAL PRIMARY KEY, -- Unique identifier for each log entry
 sprint_backlog_item_id INTEGER, -- ID of the backlog item changed
 operation_type VARCHAR(10) NOT NULL, -- the type of operation being performed
 data JSONB NOT NULL, -- Stores the full sprint_backlog data in JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP);

-- 4. Define function to log changes in the sprint_backlog table

CREATE OR REPLACE FUNCTION log_sprint_backlog_changes() RETURNS TRIGGER AS $$
BEGIN
        --log insert operations
        IF(TG_OP = 'INSERT') THEN
                INSERT INTO sprint_backlog_olap (sprint_backlog_item_id, operation_type, data)
                VALUES (NEW.sprint_backlog_item_id, 'INSERT', row_to_json(NEW));
                RETURN NEW;
        --log update operations
        IF(TG_OP = 'UPDATE') THEN
                INSERT INTO sprint_backlog_olap (sprint_backlog_item_id, operation_type, data)
                VALUES (NEW.sprint_backlog_item_id, 'UPDATE', row_to_json(NEW));
                RETURN NEW;
         IF(TG_OP = 'DELETE') THEN
                INSERT INTO sprint_backlog_olap (sprint_backlog_item_id, operation_type, data)
                VALUES (OLD.sprint_backlog_item_id, 'DELETE', row_to_json(OLD));
                RETURN OLD;
        END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger that calls log sprint backlog changes function on any insert, update, or delete

CREATE TRIGGER trg_sprint_backlog_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON sprint_backlog
FOR EACH ROW EXECUTE FUNCTION log_product_backlog_changes();

-- Commit the transaction to finalize the operation

COMMIT;

