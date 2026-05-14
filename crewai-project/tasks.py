"""Task definitions for the beginner gym helper workflow."""

from crewai import Task


APP_BRIEF = """
Shape an iOS SwiftUI app called Fitness Coach into a beginner gym helper.

Current product scope:
- Today screen shows active calories, daily calorie goal, and coaching notes.
- HealthKit reads active energy burned from Apple Health.
- Coach screen recommends workouts based on active calories, calorie goal, and focus.
- Form screen exists, but camera QA is intentionally out of scope for this crew run.
- Launch screen tracks readiness items such as HealthKit privacy, disclaimer, and QA.
- The app includes a medical disclaimer gate before coaching guidance.

The product direction is not a generic product review tool. It should help a
new gym user understand what to do today, how hard to go, and how to stay
consistent using simple HealthKit-aware guidance.
"""


DEFAULT_INTAKE_CONTEXT = """
No custom intake was provided. Assume the user is a beginner who wants to go to
the gym consistently, understand daily active calories, and receive simple,
safe workout suggestions.
"""


def create_beginner_guidance_task(agent, intake_context: str) -> Task:
    """Turn beginner answers into gym helper advice."""
    return Task(
        description=(
            f"{APP_BRIEF}\n\n"
            f"Answers from the beginner gym guidance conversation:\n"
            f"{intake_context}\n\n"
            "Act as the Beginner Gym Coach Agent. First summarize the user's "
            "goal, experience level, constraints, confidence blockers, and likely "
            "next step. Then suggest simple app guidance for today's workout, "
            "weekly consistency, calorie-progress interpretation, coaching tone, "
            "and safety boundaries. Keep suggestions beginner-friendly and avoid "
            "medical advice. Do not include camera QA because camera is out of "
            "scope for this run."
        ),
        expected_output=(
            "A beginner gym helper brief with the inferred user profile, simple "
            "training guidance, app feature suggestions, coaching guardrails, "
            "HealthKit priorities, and open follow-up questions."
        ),
        agent=agent,
    )


def create_healthkit_task(agent, context_tasks) -> Task:
    """Review HealthKit behavior and privacy readiness."""
    return Task(
        description=(
            f"{APP_BRIEF}\n\n"
            "Use the Beginner Gym Coach brief as product context. "
            "Review the HealthKit side of the app. Focus on entitlement and "
            "purpose-string readiness, authorization handling, unavailable or "
            "denied states, active-energy query behavior, user privacy wording, "
            "and what must be tested on a physical iPhone. Do not include camera "
            "testing."
        ),
        expected_output=(
            "A HealthKit review with pass/fail observations, risks, recommended "
            "code or copy improvements, and a real-device HealthKit checklist."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_swiftui_task(agent, context_tasks) -> Task:
    """Review SwiftUI screens and user-facing guidance."""
    return Task(
        description=(
            "Using the Beginner Gym Coach brief and HealthKit review, inspect "
            "the SwiftUI app experience. "
            "Cover Today, Coach, Launch, and the medical disclaimer flow. Check "
            "state ownership, layout risks, accessibility, navigation, empty or "
            "permission-denied states, and whether coaching guidance is clear "
            "without sounding like medical advice. Keep camera-specific review "
            "out of scope."
        ),
        expected_output=(
            "A SwiftUI UX and architecture review with concrete issues, suggested "
            "fixes, and launch-readiness notes."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_qa_task(agent, context_tasks) -> Task:
    """Create terminal and real-device QA instructions."""
    return Task(
        description=(
            "Using the Beginner Gym Coach brief, HealthKit review, and SwiftUI "
            "review, create a QA plan for the Fitness Coach app. Include terminal "
            "commands the developer can run from the repository, expected results, "
            "simulator limitations, iPhone HealthKit test steps, regression checks "
            "for onboarding/disclaimer, and release blockers. Do not include "
            "camera QA in this run."
        ),
        expected_output=(
            "A concise QA report with terminal checks, real-device HealthKit "
            "steps, expected outcomes, and a prioritized release-blocker list."
        ),
        agent=agent,
        context=context_tasks,
    )


def create_tasks(
    agents: dict,
    intake_context: str = DEFAULT_INTAKE_CONTEXT,
) -> list[Task]:
    """Create the full sequential Fitness Coach review workflow."""
    beginner_guidance_task = create_beginner_guidance_task(
        agents["beginner_gym_coach"],
        intake_context,
    )
    healthkit_task = create_healthkit_task(
        agents["healthkit"],
        [beginner_guidance_task],
    )
    swiftui_task = create_swiftui_task(
        agents["swiftui"],
        [beginner_guidance_task, healthkit_task],
    )
    qa_task = create_qa_task(
        agents["qa"],
        [beginner_guidance_task, healthkit_task, swiftui_task],
    )

    return [
        beginner_guidance_task,
        healthkit_task,
        swiftui_task,
        qa_task,
    ]
