<!-- @format -->

# SCRUM_TMA

    SCRUM_TMA is a project management tool designed for teams following the SCRUM methodology. This application allows users to manage sprints, create tasks, assign them to team members, and track progress in an organized manner. The system also includes comprehensive logging of user and task data to facilitate auditing and analytics.

Table of Contents:

- [About the Project](#about-the-project)
- [Technologies](#technologies)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## About the Project

    SCRUM_TMA is a web-based tool that helps teams efficiently manage their SCRUM sprints and tasks. It provides features for creating user stories, assigning tasks, logging progress, and reviewing sprint outcomes. Each change in the system is tracked through an OLAP table to maintain a complete audit log for analytics and reporting purposes.

### Key highlights

    Create and manage sprints
    Assign tasks to team members
    Track user activities and task modifications through OLAP logging for analytics

## Technologies

    Backend: Java (Spring Boot), PostgreSQL
    Frontend: HTML, CSS, JavaScript (React)
    Logging & Analytics: OLAP system for tracking user activities
    Authentication: Spring Security for role-based access control
    Database Management: PostgreSQL with custom schema for tasks, sprints, and user data
    Other Tools: Hibernate ORM, RESTful APIs

## Installation

To run the SCRUM_TMA project locally, follow the steps below:

    Clone the repository:
        git clone <https://github.com/your-username/scrum_tma.git>

    Navigate to the project directory:
        cd scrum_tma

    Set up the backend:
        Install Java 11 or higher.
        Install PostgreSQL and set up the database:
            CREATE DATABASE scrum_tma_db;

    Apply the schema:
        psql -U postgres -d scrum_tma_db -f db/schema.sql

    Configure environment variables:
        Create a .env file in the root directory and add:
            DB_HOST=localhost
            DB_NAME=scrum_tma_db
            DB_USER=your-db-user
            DB_PASS=your-db-password

    Run the backend:
        ./mvnw spring-boot:run

    Set up the frontend:
        Navigate to the client folder:
            cd client
        Install dependencies:
            npm install

    Start the frontend development server:
        npm start

    Access the app:
        The backend runs on <http://localhost:8080.>
        The frontend runs on <http://localhost:3000.>

## Usage

Once the application is running, you can:

    Create an account or log in with an existing one.
    Create a sprint: Add tasks, assign them to team members, and define their priorities.
    Track progress: As tasks are completed or updated, their status is logged for future analysis.
    View task changes: Use the analytics dashboard to view historical changes logged in the OLAP table.

## Features

    User Management: Role-based access control for admin, manager, and team members.
    Task Management: Full CRUD operations (Create, Read, Update, Delete) for tasks.
    Sprint Management: Organize tasks into sprints and track progress with burndown charts.
    OLAP Logging: Each change in task or sprint data is logged for auditing and analytics.
    Secure Authentication: User login and registration with encrypted passwords.
    Responsive Design: Fully functional on desktop and mobile devices.

## Contributing

Contributions are welcome! To contribute:

    Fork the repository
    Create a new branch (git checkout -b feature/your-feature)
    Commit your changes (git commit -m 'Add your feature')
    Push to the branch (git push origin feature/your-feature)
    Open a pull request

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contact

    Jonathan Sutton - LinkedIn - <https://www.linkedin.com/in/jonathan-d-sutton>
    Project Link: <https://github.com/CodeJonDave/SCRUM_TMA>
