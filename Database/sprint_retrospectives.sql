-- Create the sprint Retrospective table
CREATE TABLE IF NOT EXISTS sprint_retrospectives (
    retrospective_id SERIAL PRIMARY KEY, -- Unique ID for each sprint retrospective
    sprint_id INT NOT NULL, -- ID of the associated sprint
    meeting_date DATE NOT NULL, -- Date of the retrospective meeting
    went_well TEXT, -- Things that went well during the sprint
    needs_improvement TEXT, -- Things that need improvement
    actions_to_take TEXT, -- Actions to be taken for improvement
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Foreign key to reference the sprint
);
