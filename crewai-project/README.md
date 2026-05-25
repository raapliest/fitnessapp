# CrewAI Fitness Coach Engineering Team

This project simulates a three-agent AI software development team for building a
native iOS fitness tracker app with SwiftUI, MVVM, HealthKit, Apple Health sync,
workout tracking, step counting, calories tracking, workout history, and QA.

The crew is engineering-oriented. It is not a fitness consultation chatbot and
does not produce long motivational coaching conversations.

## Folder Structure

```text
crewai-project/
├── agents.py
├── tasks.py
├── crew.py
├── .gitignore
├── requirements.txt
├── README.md
└── skills/
    └── swiftui-pro/
```

## Agents

- SwiftUIProAgent: senior iOS SwiftUI engineer for UI/UX, MVVM, navigation,
  reusable components, state management, charts, dashboards, and production
  Swift code.
- HealthKitAgent: HealthKit specialist for Apple Health sync, authorization,
  step count, active calories, workout sessions, read/write flows, sync logic,
  real-device guidance, and permission error handling.
- QAAgent: iOS QA lead for generated SwiftUI code, architecture issues,
  HealthKit flow validation, edge cases, permission-denied testing, simulator
  versus real-device checks, UI consistency, and bug reports.

## Deliverables

The workflow produces development artifacts such as:

- SwiftUI views and reusable components.
- ViewModels and MVVM architecture boundaries.
- HealthKit manager/service design.
- Modular folder structure.
- Fitness data models and seed content.
- Workout dashboard, tracking, and history plans.
- Testing reports and QA workflows.
- Production-ready Swift code sketches.

## Setup

1. Open the project folder:

   ```bash
   cd crewai-project
   ```

2. Create and activate a virtual environment:

   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. Install dependencies:

   ```bash
   pip install -r requirements.txt
   ```

4. Set your LLM API key. Groq is used first when both keys are present:

   ```bash
   export OPENAI_API_KEY="your-openai-key"
   export GROQ_API_KEY="your-groq-key"
   ```

5. Run the crew:

   ```bash
   python crew.py
   ```

   Or skip the interactive engineering brief:

   ```bash
   python crew.py --no-intake
   ```

## Workflow

The crew runs sequentially:

1. HealthKitAgent designs Apple Health integration and HealthKit service code.
2. SwiftUIProAgent designs the SwiftUI MVVM app architecture, screens, models,
   and sample workout seed data.
3. QAAgent validates architecture, HealthKit flows, UI consistency, and tests.

The final terminal output is an engineering report for building the Fitness
Coach iOS app.
