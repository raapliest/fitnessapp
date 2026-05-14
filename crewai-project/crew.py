"""Run the Fitness Coach beginner gym helper workflow."""

import argparse
import os
from pathlib import Path

DEFAULT_INTAKE_CONTEXT = """
No custom intake was provided. Assume the user is a beginner who wants to go to
the gym consistently, understand daily active calories, and receive simple,
safe workout suggestions.
"""

INTAKE_QUESTIONS = [
    (
        "User goal",
        "What does the beginner user want most right now?",
        "Build a consistent gym habit and know what workout to do today.",
    ),
    (
        "Experience level",
        "How experienced is the user with gym training?",
        "New to the gym and unsure how to choose exercises.",
    ),
    (
        "Training schedule",
        "How many days per week can the user realistically train?",
        "Three days per week.",
    ),
    (
        "Available equipment",
        "What equipment does the user have access to?",
        "Basic gym machines, dumbbells, treadmill, and bike.",
    ),
    (
        "Confidence blocker",
        "What makes the user feel stuck or intimidated?",
        "They do not know whether they are doing enough or too much.",
    ),
    (
        "HealthKit signal",
        "Which HealthKit signal should guide the app's advice first?",
        "Active energy burned.",
    ),
    (
        "Safety boundary",
        "What should the app avoid recommending?",
        "Avoid medical advice, extreme calorie targets, and pain-based coaching.",
    ),
    (
        "Open context",
        "Add any extra context for the Beginner Gym Coach Agent.",
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

def ask_product_intake() -> str:
    """Ask lightweight product questions before the agents start reviewing."""
    print("\n=== Beginner Gym Coach Intake ===")
    print("Answer freely. The coach agent will give beginner gym guidance first.\n")

    answers: list[str] = []
    for label, question, default in INTAKE_QUESTIONS:
        answer = input(f"{question}\n[{default}]\n> ").strip()
        answers.append(f"- {label}: {answer or default}")
        print()

    return "\n".join(answers)


def parse_args() -> argparse.Namespace:
    """Parse CLI options for the crew runner."""
    parser = argparse.ArgumentParser(
        description="Run the Fitness Coach beginner gym helper crew.",
    )
    parser.add_argument(
        "--no-intake",
        action="store_true",
        help="Skip interactive product questions and use default context.",
    )
    return parser.parse_args()


def build_crew(intake_context: str):
    """Build the Fitness Coach beginner helper crew with the resolved LLM."""
    validate_environment()
    configure_local_storage()

    from crewai import Crew, Process
    from agents import create_agents
    from tasks import create_tasks

    llm    = resolve_llm()
    agents = create_agents(llm=llm)
    tasks  = create_tasks(agents, intake_context=intake_context)

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
    intake_context = DEFAULT_INTAKE_CONTEXT if args.no_intake else ask_product_intake()
    crew   = build_crew(intake_context)
    result = crew.kickoff()

    print("\n\n=== Final Fitness Coach Beginner Helper Report ===\n")
    print(result)


if __name__ == "__main__":
    main()
