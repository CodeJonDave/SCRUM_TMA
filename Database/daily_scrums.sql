-- Create the daily scrums table to store daily scrum meetings
CREATE TABLE IF NOT EXISTS daily_scrums (
    daily_scrum_id SERIAL PRIMARY KEY, -- Unique ID for each daily scrum
    sprint_id INT NOT NULL, -- ID of the associated sprint
    meeting_date DATE NOT NULL, -- Date of the scrum meeting
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Foreign key to reference the sprint
);
