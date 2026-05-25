"""Task definitions for the Fitness Coach iOS engineering workflow."""

from crewai import Task


APP_ENGINEERING_BRIEF = """
Build a native iOS fitness tracker app called Fitness Coach.

Primary product goals:
- SwiftUI application architecture using MVVM.
- HealthKit and Apple Health sync.
- Workout tracking with workout sessions and history.
- Step counter and active calories tracking.
- Dashboard with charts and progress summaries.
- Modular, clean, scalable Swift code.
- QA and testing workflow for simulator and real iPhone validation.

Important behavior constraints:
- Agents collaborate to build the app.
- Agents do not behave like customer support chatbots.
- Avoid long motivational fitness conversations.
- Prioritize implementation, architecture, debugging, and code generation.
- Outputs should support an app development workflow.
"""


DEFAULT_ENGINEERING_CONTEXT = """
No custom engineering brief was provided. Assume the team is starting a SwiftUI
and HealthKit fitness tracker from an early scaffold and needs a practical feature
plan, starter architecture, HealthKit service design, workout data models, sample
seed data, and QA checklist.
"""


def create_healthkit_task(agent, engineering_context: str) -> Task:
    """Design HealthKit services and sync behavior."""
    return Task(
        description=(
            f"{APP_ENGINEERING_BRIEF}\n\n"
            f"Engineering context:\n{engineering_context}\n\n"
            "Act as HealthKitAgent. Design the HealthKit layer. Cover "
            "entitlements, Info.plist purpose strings, authorization states, "
            "read/write types, step-count queries, active-energy queries, "
            "workout-session saving, Apple Health sync, background/refresh "
            "considerations, error handling, privacy, and real-device testing "
            "guidance. Provide production-ready Swift code sketches for a "
            "HealthKit manager or service."
        ),
        expected_output=(
            "A HealthKit implementation plan with Swift service code, permission "
            "flow, read/write data contracts, sync strategy, error states, and "
            "simulator versus real-device validation notes."
        ),
        agent=agent,
    )


def create_swiftui_task(agent, context_tasks) -> Task:
    """Design SwiftUI MVVM architecture and app screens."""
    return Task(
        description=(
            f"{APP_ENGINEERING_BRIEF}\n\n"
            "Using the HealthKit design, act as SwiftUIProAgent. Design the "
            "native iOS app architecture using MVVM. Produce SwiftUI views, "
            "ViewModels, reusable components, navigation, dashboard/charts "
            "approach, workout history UI, step/calorie summary UI, loading/"
            "empty/error states, and state-management boundaries. Include "
            "Swift-friendly workout data models, beginner workout sample seeds, "
            "exercise categories, metadata fields, and preview fixtures directly "
            "as app development artifacts. Favor production-ready Swift code and "
            "clear module organization."
        ),
        expected_output=(
            "A SwiftUI MVVM implementation package containing architecture "
            "folders, key models/ViewModels/views, sample workout seed data, "
            "reusable components, dashboard and history UI code sketches, and "
            "integration points for HealthKit."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_qa_task(agent, context_tasks) -> Task:
    """Create QA, testing, and bug-reporting workflow."""
    return Task(
        description=(
            f"{APP_ENGINEERING_BRIEF}\n\n"
            "Using the HealthKit implementation plan and SwiftUI MVVM package, "
            "act as QAAgent. Validate the architecture and generate a QA "
            "workflow. Include Swift unit-test targets, ViewModel tests, "
            "HealthKit mock strategy, workout seed-data validation, permission "
            "denied tests, simulator limitations, real-device Apple Health sync "
            "validation, UI/UX consistency checks, edge cases, regression tests, "
            "and bug-report format. Flag release blockers clearly."
        ),
        expected_output=(
            "A QA and testing report with test matrix, sample XCTest cases, "
            "HealthKit mock strategy, simulator and iPhone test steps, edge "
            "cases, release blockers, and bug-report templates."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_tasks(
    agents: dict,
    engineering_context: str = DEFAULT_ENGINEERING_CONTEXT,
) -> list[Task]:
    """Create the full sequential Fitness Coach engineering workflow."""
    healthkit_task = create_healthkit_task(
        agents["healthkit"],
        engineering_context,
    )
    swiftui_task = create_swiftui_task(
        agents["swiftui"],
        [healthkit_task],
    )
    qa_task = create_qa_task(
        agents["qa"],
        [healthkit_task, swiftui_task],
    )

    return [
        healthkit_task,
        swiftui_task,
        qa_task,
    ]
