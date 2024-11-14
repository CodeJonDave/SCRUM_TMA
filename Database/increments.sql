-- Create the increments table to store sprint increments
CREATE TABLE IF NOT EXISTS increments (
    increment_id SERIAL PRIMARY KEY, -- Unique ID for each increment
    sprint_id INT NOT NULL, -- ID of the associated sprint
    increment_description TEXT NOT NULL, -- Description of the sprint increment
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the increment is completed
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Foreign key to reference the sprint
);