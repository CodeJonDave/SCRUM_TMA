-- Create the sprint reviews table to store sprint review meetings
CREATE TABLE IF NOT EXISTS sprint_reviews (
    sprint_review_id SERIAL PRIMARY KEY, -- Unique ID for each sprint review
    sprint_id INT NOT NULL, -- ID of the associated sprint
    meeting_date DATE NOT NULL, -- Date of the review meeting
    feedback TEXT, -- Feedback provided during the review
    FOREIGN KEY (sprint_id) REFERENCES sprints (sprint_id) -- Foreign key to reference the sprint
);