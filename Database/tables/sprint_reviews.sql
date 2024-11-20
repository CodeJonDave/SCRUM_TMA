-- Begin a transaction to ensure atomicity for all operations
BEGIN TRANSACTION;

-- 1. Create the sprint reviews table to store sprint review meetings

CREATE TABLE IF NOT EXISTS sprint_reviews
    (sprint_review_id SERIAL PRIMARY KEY, -- Unique ID for each sprint review
 sprint_id INT NOT NULL, -- ID of the associated sprint
 meeting_date DATE NOT NULL, -- Date of the meeting
 feedback TEXT, -- Feedback provided during the review
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is created
 updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is updated
 -- Ensure the reviews are deleted when the sprint is deleted
 CONSTRAINT fk_sprint_id
     FOREIGN KEY (sprint_id) REFERENCES sprints(sprint_id) -- Reference to the 'sprints' table
 ON DELETE CASCADE);

-- 2. Create indexes for fast lookups

CREATE INDEX idx_sprint_reviews_sprint_id ON sprint_reviews (sprint_id);


CREATE INDEX idx_sprint_reviews_meeting_date ON sprint_reviews (meeting_date);

-- 3. Create the sprint_reviews olap table to log changes in the sprint_reviews table

CREATE TABLE IF NOT EXISTS sprint_reviews_olap (log_id SERIAL PRIMARY KEY, -- Unique ID for each log
 sprint_review_id INTEGER, -- The ID of the sprint review
 operation_type VARCHAR(10), -- The type of operation performed
 data JSONB NOT NULL, -- Stores info into JSONB format
 operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- Timestamp of the log
);

-- 4. Define function to log changes in the sprint_reviews table

CREATE OR REPLACE FUNCTION log_sprint_review_changes() RETURNS TRIGGER AS $$
BEGIN
    --Log insert operations
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO sprint_reviews_olap (sprint_review_id, operation_type, data)
        VALUES (NEW.sprint_review_id, 'INSERT', row_to_json(NEW));
        RETURN NEW;

    -- log update operations
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO sprint_reviews_olap (sprint_review_id, operation_type, data)
        VALUES (NEW.sprint_review_id, 'UPDATE', row_to_json(NEW));
        RETURN NEW;

    -- Log delete operations
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO sprint_reviews_olap (sprint_review_id, operation_type, data)
        VALUES (OLD.sprint_review_id, 'DELETE', row_to_json(OLD));
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 5. Create a trigger to call the log_sprint_reviews_changes function on any insert, update, or delete

CREATE TRIGGER trg_sprint_reviews_changes AFTER
INSERT
OR
UPDATE
OR
DELETE ON sprint_reviews
FOR EACH ROW EXECUTE FUNCTION log_sprint_review_changes();

-- Commit the transaction to finalize the operation

COMMIT;