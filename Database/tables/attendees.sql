BEGIN TRANSACTION;

-- 1. Create the `scrum_attendees` table

CREATE TABLE IF NOT EXISTS scrum_attendees
    (daily_scrum_id INTEGER NOT NULL, -- ID to the scrum
 user_id UUID NOT NULL, -- ID to the user assigned
 added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when user was added to the scrum
 PRIMARY KEY (daily_scrum_id,
              user_id), -- Ensures unique relationships
 CONSTRAINT fk_scrum_id
     FOREIGN KEY (daily_scrum_id) REFERENCES daily_scrums(daily_scrum_id) ON DELETE CASCADE,
                                                                                    CONSTRAINT fk_user_id
     FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);

-- 2. Create the `review_attendees` table

CREATE TABLE IF NOT EXISTS review_attendees
    (sprint_review_id INTEGER NOT NULL, -- ID to the review
 user_id UUID NOT NULL, -- ID to the user assigned
 added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when user was added to the review
 PRIMARY KEY (sprint_review_id,
              user_id), -- Ensures unique relationships
 CONSTRAINT fk_review_id
     FOREIGN KEY (sprint_review_id) REFERENCES sprint_reviews(sprint_review_id) ON DELETE CASCADE,
                                                                                          CONSTRAINT fk_user_id
     FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);

-- 3. Create the `retrospective_attendees` table

CREATE TABLE IF NOT EXISTS retrospective_attendees
    (retrospective_id INTEGER NOT NULL, -- ID to the retrospective
 user_id UUID NOT NULL, -- ID to the user assigned
 added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when user was added to the retrospective
 PRIMARY KEY (retrospective_id,
              user_id), -- Ensures unique relationships
 CONSTRAINT fk_retrospective_id
     FOREIGN KEY (retrospective_id) REFERENCES sprint_retrospectives(retrospective_id) ON DELETE CASCADE,
                                                                                                 CONSTRAINT fk_user_id
     FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE);

-- 4. Create the `teams` table

CREATE TABLE IF NOT EXISTS teams
    (scrum_master_id UUID NOT NULL, -- ID of the scrum master
 team_member_id UUID NOT NULL, -- ID of the team member
 added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the relationship was created
 PRIMARY KEY (scrum_master_id,
              team_member_id), -- Ensures unique relationships
 CONSTRAINT fk_scrum_master_id
     FOREIGN KEY (scrum_master_id) REFERENCES users(user_id) ON DELETE CASCADE,
                                                                       CONSTRAINT fk_team_member_id
     FOREIGN KEY (team_member_id) REFERENCES users(user_id) ON DELETE CASCADE);


COMMIT;

