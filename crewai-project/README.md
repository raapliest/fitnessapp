# CrewAI Beginner Gym Helper Team

This project runs a beginner gym helper crew for the Fitness Coach iOS app.

Camera QA is intentionally skipped for now. The crew focuses on HealthKit,
beginner-friendly SwiftUI guidance, and QA readiness.

## Agents

- Beginner Gym Coach Agent: asks beginner-focused training questions through
  the terminal and turns free-form answers into simple, safe gym guidance.
- HealthKit Agent: reviews HealthKit privacy, authorization, active-energy reads,
  unavailable states, and whether the HealthKit signals support beginner advice.
- SwiftUI Agent: reviews Today, Coach, Launch, onboarding/disclaimer, state
  ownership, accessibility, layout risks, and whether the UI feels clear to a
  new gym user.
- QA Agent: creates terminal checks, simulator expectations, iPhone HealthKit
  test steps, regression checks, and release blockers.

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

4. Set an LLM API key. Groq is used first if available; otherwise OpenAI is used.

   ```bash
   export GROQ_API_KEY="your-groq-key"
   # or
   export OPENAI_API_KEY="your-openai-key"
   ```

5. Run the crew:

   ```bash
   python crew.py
   ```

   By default, the script asks a few product-intake questions before the agents
   start. To skip the questions and use default context:

   ```bash
   python crew.py --no-intake
   ```

## Workflow

The workflow runs sequentially:

0. Beginner gym intake questions in terminal
1. Beginner Gym Coach guidance
2. HealthKit review
3. SwiftUI review
4. QA report

The final terminal output is a beginner helper report with simple training
guidance, HealthKit checks, SwiftUI issues, terminal commands, real-device
iPhone steps, and release blockers.
