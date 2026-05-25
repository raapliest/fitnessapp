"""Run the Fitness Coach iOS engineering crew workflow."""

import argparse
import os
from pathlib import Path

DEFAULT_ENGINEERING_CONTEXT = """
No custom engineering brief was provided. Assume the team is building a native
iOS fitness tracker with SwiftUI, MVVM, HealthKit, Apple Health sync, workout
tracking, step count, calories tracking, workout history, and QA coverage.
"""

ENGINEERING_BRIEF_QUESTIONS = [
    (
        "App goal",
        "What is the main app feature the engineering crew should prioritize?",
        "Build the MVP dashboard with step count, active calories, and workouts.",
    ),
    (
        "Architecture",
        "What architecture should the SwiftUI app follow?",
        "MVVM with modular Services, Models, ViewModels, Views, and Tests.",
    ),
    (
        "Health data",
        "Which HealthKit data should be implemented first?",
        "Step count, active energy burned, and workout sessions.",
    ),
    (
        "Screens",
        "Which screens should the SwiftUI team design?",
        "Dashboard, workout tracker, workout history, settings, and permissions.",
    ),
    (
        "Testing",
        "What testing workflow should QA emphasize?",
        "ViewModel unit tests, HealthKit mocks, permission tests, and device QA.",
    ),
    (
        "Constraints",
        "What should agents avoid while generating deliverables?",
        "Avoid chatbot consultation behavior and prioritize implementation output.",
    ),
    (
        "Open context",
        "Add any extra engineering context for the crew.",
        "No extra context.",
    ),
]


# ---------------------------------------------------------------------------
# Environment helpers
# ---------------------------------------------------------------------------

def validate_environment() -> None:
    """Fail early with a clear message if no supported LLM key is found."""
    has_openai = bool(os.getenv("OPENAI_API_KEY"))
    has_groq   = bool(os.getenv("GROQ_API_KEY"))

    if not has_openai and not has_groq:
        raise RuntimeError(
            "No LLM API key found.\n"
            "Set one of the following before running:\n"
            "  export OPENAI_API_KEY='sk-...'      # OpenAI\n"
            "  export GROQ_API_KEY='gsk_...'       # Groq (free tier available)\n"
        )


def configure_local_storage() -> None:
    """Store CrewAI's local SQLite state inside this project folder."""
    project_dir = Path(__file__).resolve().parent
    storage_dir = project_dir / ".crewai-storage"
    storage_dir.mkdir(exist_ok=True)
    os.environ.setdefault("CREWAI_STORAGE_DIR", str(storage_dir))


# ---------------------------------------------------------------------------
# LLM selection  (Groq takes priority if both keys are present)
# ---------------------------------------------------------------------------

def resolve_llm():
    """
    Return an LLM instance based on which API key is available.

    Priority:
      1. Groq  — if GROQ_API_KEY is set   (fast, free tier available)
      2. OpenAI — if OPENAI_API_KEY is set
    """
    groq_key   = os.getenv("GROQ_API_KEY")
    openai_key = os.getenv("OPENAI_API_KEY")

    from crewai import LLM

    if groq_key:
        print("[LLM] Using Groq → llama-3.3-70b-versatile")
        return LLM(
            model="groq/llama-3.3-70b-versatile",
            api_key=groq_key,
        )

    print("[LLM] Using OpenAI → gpt-4o")
    return LLM(
        model="gpt-4o",
        api_key=openai_key,
    )


# ---------------------------------------------------------------------------
# Crew builder
# ---------------------------------------------------------------------------

def ask_engineering_brief() -> str:
    """Ask lightweight engineering questions before the agents start building."""
    print("\n=== Fitness Coach Engineering Brief ===")
    print("Answer freely. The crew will turn this into app development deliverables.\n")

    answers: list[str] = []
    for label, question, default in ENGINEERING_BRIEF_QUESTIONS:
        answer = input(f"{question}\n[{default}]\n> ").strip()
        answers.append(f"- {label}: {answer or default}")
        print()

    return "\n".join(answers)


def parse_args() -> argparse.Namespace:
    """Parse CLI options for the crew runner."""
    parser = argparse.ArgumentParser(
        description="Run the Fitness Coach iOS engineering crew.",
    )
    parser.add_argument(
        "--no-intake",
        action="store_true",
        help="Skip interactive engineering questions and use default context.",
    )
    return parser.parse_args()


def build_crew(engineering_context: str):
    """Build the Fitness Coach iOS engineering crew with the resolved LLM."""
    validate_environment()
    configure_local_storage()

    from crewai import Crew, Process
    from agents import create_agents
    from tasks import create_tasks

    llm    = resolve_llm()
    agents = create_agents(llm=llm)
    tasks  = create_tasks(agents, engineering_context=engineering_context)

    return Crew(
        agents=list(agents.values()),
        tasks=tasks,
        process=Process.sequential,
        verbose=True,
    )


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main() -> None:
    """Kick off the workflow and print the final result."""
    args = parse_args()
    engineering_context = (
        DEFAULT_ENGINEERING_CONTEXT if args.no_intake else ask_engineering_brief()
    )
    crew   = build_crew(engineering_context)
    result = crew.kickoff()

    print("\n\n=== Final Fitness Coach iOS Engineering Report ===\n")
    print(result)


if __name__ == "__main__":
    main()
