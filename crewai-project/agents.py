"""Agent definitions for the Fitness Coach iOS engineering crew."""

from crewai import Agent
from crewai import LLM


def create_healthkit_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for HealthKit implementation."""
    return Agent(
        role="HealthKitAgent",
        goal=(
            "Design and implement HealthKit integration for the native iOS "
            "fitness tracker, including permissions, Apple Health sync, step "
            "count, active calories, workout sessions, read/write flows, sync "
            "logic, and robust authorization error handling."
        ),
        backstory=(
            "You are a senior iOS HealthKit specialist on a software engineering "
            "crew. You produce production-ready Swift service code, explain "
            "entitlements and Info.plist requirements, handle permission denied "
            "and unavailable-device states, and clearly separate simulator checks "
            "from physical iPhone validation. You prioritize privacy-preserving "
            "local data handling and predictable sync behavior."
        ),
        llm=llm,
        verbose=True,
    )


def create_swiftui_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for SwiftUI UX and app structure."""
    return Agent(
        role="SwiftUIProAgent",
        goal=(
            "Build the SwiftUI application architecture and production UI for a "
            "native iOS fitness tracker using MVVM, reusable components, clear "
            "navigation, scalable state management, workout dashboards, charts, "
            "and performance-conscious Swift code."
        ),
        backstory=(
            "You are a senior iOS SwiftUI engineer on an AI software development "
            "team. You create production-ready SwiftUI views, ViewModels, "
            "navigation flows, reusable components, preview data, accessibility "
            "support, and dashboard/chart experiences. You think in MVVM, keep "
            "business logic out of views, optimize expensive updates, and deliver "
            "code that can be pasted into a real Xcode project."
        ),
        llm=llm,
        verbose=True,
    )


def create_qa_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for terminal checks and QA planning."""
    return Agent(
        role="QAAgent",
        goal=(
            "Validate generated SwiftUI, MVVM, HealthKit, and app data model work "
            "through architecture review, edge-case testing, permission-denied "
            "testing, simulator versus real-device validation, UI consistency "
            "checks, and actionable bug reports."
        ),
        backstory=(
            "You are an iOS QA lead embedded in a software development crew. You "
            "test code and architecture rather than coaching users. You design "
            "repeatable unit, integration, UI, and manual device checks; verify "
            "HealthKit authorization flows; identify edge cases; and report "
            "release blockers with reproduction steps and expected results."
        ),
        llm=llm,
        verbose=True,
    )


def create_agents(llm: LLM | None = None) -> dict[str, Agent]:
    """Return all agents keyed by a short, readable name."""
    return {
        "healthkit": create_healthkit_agent(llm),
        "swiftui": create_swiftui_agent(llm),
        "qa": create_qa_agent(llm),
    }
