# CrewAI SwiftUI Architecture Team

This project simulates a five-agent software engineering team that designs the
architecture for a small iOS SwiftUI app.

## Folder Structure

```text
crewai-project/
├── agents.py
├── tasks.py
├── crew.py
├── crewAI.py
├── .gitignore
├── requirements.txt
├── README.md
└── skills/
    └── swiftui-pro/
```

## Agents

- SwiftUI Expert Agent: designs the SwiftUI UI architecture.
- Swift Concurrency Expert Agent: designs async/await and background workflows.
- Core Data Expert Agent: designs persistence and schema boundaries.
- Swift Testing Expert Agent: creates the test strategy.
- Code Reviewer Agent: reviews the full plan and suggests improvements.

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

4. Set your LLM API key. For example, with OpenAI:

   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```

5. Run the crew:

   ```bash
   python crew.py
   ```

## What It Produces

The workflow runs sequentially:

1. SwiftUI app architecture design
2. Async data flow design
3. Core Data schema design
4. Unit test plan
5. Final review and improvement checklist

The final terminal output is a reviewed architecture plan for the sample app,
FocusLog.
