"""Task definitions for the SwiftUI architecture design workflow."""

from crewai import Task


APP_BRIEF = """
Design a small SwiftUI app called FocusLog.

FocusLog lets users record short focus sessions, add a note after each session,
tag sessions by category, and review recent productivity patterns. The team is
not writing the Swift app yet; this CrewAI project should produce the app
architecture plan that a Swift team could implement next.
"""


def create_architecture_task(agent) -> Task:
    """Plan the SwiftUI app architecture and screen structure."""
    return Task(
        description=(
            f"{APP_BRIEF}\n\n"
            "Create the SwiftUI architecture design. Include the main features, "
            "screen hierarchy, view model responsibilities, state ownership, "
            "navigation approach, and accessibility notes. Keep the plan small "
            "enough for a beginner iOS project but realistic enough for a real "
            "engineering team."
        ),
        expected_output=(
            "A concise architecture document with feature modules, screen flow, "
            "SwiftUI state strategy, navigation plan, and UI best practices."
        ),
        agent=agent,
    )


def create_async_data_flow_task(agent, context_tasks) -> Task:
    """Plan async workflows and background work."""
    return Task(
        description=(
            "Using the SwiftUI architecture plan, design the async data flow for "
            "FocusLog. Cover async loading, saving sessions, refreshing summary "
            "data, task cancellation, MainActor updates, and background work. "
            "Explain where async/await should be used and where it should be "
            "avoided."
        ),
        expected_output=(
            "An async data flow plan with example responsibilities for services, "
            "view models, task cancellation, and main-thread UI updates."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_core_data_task(agent, context_tasks) -> Task:
    """Plan Core Data entities and persistence boundaries."""
    return Task(
        description=(
            "Using the app architecture and async data flow, design the Core Data "
            "schema for FocusLog. Include entities, attributes, relationships, "
            "delete rules, fetch requests, background context usage, and a simple "
            "migration strategy."
        ),
        expected_output=(
            "A Core Data design document with entities, fields, relationships, "
            "fetch patterns, persistence service boundaries, and migration notes."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_unit_test_task(agent, context_tasks) -> Task:
    """Create a testing strategy for the proposed architecture."""
    return Task(
        description=(
            "Using the architecture, async flow, and Core Data schema, write a "
            "unit test plan for FocusLog. Include what to test in view models, "
            "services, persistence, async behavior, and review logic. Include "
            "example test names and a recommended test folder structure."
        ),
        expected_output=(
            "A beginner-friendly Swift test plan with test categories, sample "
            "test names, fake dependencies, and coverage priorities."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_final_review_task(agent, context_tasks) -> Task:
    """Review the whole plan and suggest improvements."""
    return Task(
        description=(
            "Review all previous outputs as if this were a real software design "
            "review. Find architecture risks, missing data concerns, concurrency "
            "mistakes, testing gaps, and opportunities to simplify. Finish with "
            "a prioritized improvement checklist."
        ),
        expected_output=(
            "A final review report with findings, concrete fixes, and a "
            "prioritized checklist the Swift team can follow next."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_tasks(agents: dict) -> list[Task]:
    """Create the full sequential workflow."""
    architecture_task = create_architecture_task(agents["swiftui"])
    async_task = create_async_data_flow_task(
        agents["concurrency"],
        [architecture_task],
    )
    core_data_task = create_core_data_task(
        agents["core_data"],
        [architecture_task, async_task],
    )
    test_task = create_unit_test_task(
        agents["testing"],
        [architecture_task, async_task, core_data_task],
    )
    review_task = create_final_review_task(
        agents["reviewer"],
        [architecture_task, async_task, core_data_task, test_task],
    )

    return [
        architecture_task,
        async_task,
        core_data_task,
        test_task,
        review_task,
    ]
