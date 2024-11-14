-- Create the daily scrum updates table to store updates from daily scrum meetings
CREATE TABLE IF NOT EXISTS daily_scrum_updates (
    update_id SERIAL PRIMARY KEY, -- Unique ID for each scrum update
    daily_scrum_id INT NOT NULL, -- ID of the associated daily scrum
    team_member INT NOT NULL, -- ID of the team member providing the update
    work_done_yesterday TEXT NOT NULL, -- Description of the work done yesterday
    work_planned_today TEXT NOT NULL, -- Description of the work planned for today
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is created
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the record is updated
    FOREIGN KEY (daily_scrum_id) REFERENCES daily_scrums (daily_scrum_id), -- Foreign key to reference the daily scrum
    FOREIGN KEY (team_member) REFERENCES users (user_id) -- Foreign key to reference the team member (user)
);