"""Run the SwiftUI architecture CrewAI workflow."""

import os
from pathlib import Path

from crewai import Crew, Process

from agents import create_agents
from tasks import create_tasks


def validate_environment() -> None:
    """Fail early with a clear setup message if no LLM key is configured."""
    if not os.getenv("OPENAI_API_KEY"):
        raise RuntimeError(
            "OPENAI_API_KEY is not set. Run "
            "`export OPENAI_API_KEY=\"your-api-key-here\"` before `python crew.py`."
        )


def configure_local_storage() -> None:
    """Store CrewAI's local SQLite state inside this project."""
    project_dir = Path(__file__).resolve().parent
    storage_dir = project_dir / ".crewai-storage"
    storage_dir.mkdir(exist_ok=True)
    os.environ.setdefault("CREWAI_STORAGE_DIR", str(storage_dir))


def build_crew() -> Crew:
    """Build the full multi-agent crew."""
    validate_environment()
    configure_local_storage()

    agents = create_agents()
    tasks = create_tasks(agents)

    return Crew(
        agents=list(agents.values()),
        tasks=tasks,
        process=Process.sequential,
        verbose=True,
    )


def main() -> None:
    """Kick off the workflow and print the final result."""
    crew = build_crew()
    result = crew.kickoff()

    print("\n\n=== Final SwiftUI Architecture Review ===\n")
    print(result)


if __name__ == "__main__":
    main()
