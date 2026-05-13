"""Agent definitions for the SwiftUI architecture design crew."""

from crewai import Agent


def create_swiftui_expert() -> Agent:
    """Create the agent responsible for SwiftUI app structure and UI design."""
    return Agent(
        role="SwiftUI Expert Agent",
        goal=(
            "Design a clean SwiftUI application architecture that uses modern "
            "view composition, state management, navigation, and accessibility "
            "best practices."
        ),
        backstory=(
            "You are a senior iOS engineer who specializes in SwiftUI. You know "
            "how to split features into small views, keep state predictable, and "
            "make app screens easy to maintain as the product grows."
        ),
        verbose=True,
    )


def create_concurrency_expert() -> Agent:
    """Create the agent responsible for async data flow design."""
    return Agent(
        role="Swift Concurrency Expert Agent",
        goal=(
            "Design safe async/await workflows using structured concurrency, "
            "task cancellation, main actor updates, and background work where "
            "appropriate."
        ),
        backstory=(
            "You are an iOS platform engineer focused on Swift concurrency. You "
            "help teams avoid race conditions, accidental main-thread blocking, "
            "and unstructured background tasks."
        ),
        verbose=True,
    )


def create_core_data_expert() -> Agent:
    """Create the agent responsible for persistence and Core Data modeling."""
    return Agent(
        role="Core Data Expert Agent",
        goal=(
            "Design a Core Data persistence layer with practical entities, "
            "relationships, fetch patterns, migrations, and background context "
            "usage."
        ),
        backstory=(
            "You are a persistence specialist who has shipped production apps "
            "using Core Data. You care about schema clarity, predictable saves, "
            "and keeping persistence details out of SwiftUI views."
        ),
        verbose=True,
    )


def create_testing_expert() -> Agent:
    """Create the agent responsible for tests and test strategy."""
    return Agent(
        role="Swift Testing Expert Agent",
        goal=(
            "Create a unit testing and integration testing plan for the SwiftUI "
            "architecture, async workflows, and Core Data persistence layer."
        ),
        backstory=(
            "You are a testing lead for iOS apps. You design fast, meaningful "
            "test suites that cover business rules, persistence behavior, and "
            "async edge cases without making the project hard to maintain."
        ),
        verbose=True,
    )


def create_code_reviewer() -> Agent:
    """Create the agent responsible for final review and improvements."""
    return Agent(
        role="Code Reviewer Agent",
        goal=(
            "Review all architecture outputs, identify bugs or weak spots, and "
            "suggest concrete improvements before the team finalizes the plan."
        ),
        backstory=(
            "You are a principal iOS engineer known for clear, practical code "
            "reviews. You look for architectural risks, missing test coverage, "
            "threading mistakes, and places where the design can be simplified."
        ),
        verbose=True,
    )


def create_agents() -> dict[str, Agent]:
    """Return all agents keyed by a short, readable name."""
    return {
        "swiftui": create_swiftui_expert(),
        "concurrency": create_concurrency_expert(),
        "core_data": create_core_data_expert(),
        "testing": create_testing_expert(),
        "reviewer": create_code_reviewer(),
    }
