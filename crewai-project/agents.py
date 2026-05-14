"""Agent definitions for the beginner gym helper crew."""

from crewai import Agent
from crewai import LLM


def create_beginner_gym_coach_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for beginner gym guidance."""
    return Agent(
        role="Beginner Gym Coach Agent",
        goal=(
            "Understand a beginner user's fitness goals, constraints, gym "
            "confidence, and weekly routine, then suggest safe, simple coaching "
            "directions that the Fitness Coach app can support."
        ),
        backstory=(
            "You are a friendly beginner gym coach with iOS product sense. You "
            "help people who are new to training choose realistic next steps, "
            "avoid overcomplicated plans, and build confidence. You never give "
            "medical advice, diagnose issues, prescribe extreme diets, or push "
            "pain-based training."
        ),
        llm=llm,
        verbose=True,
    )


def create_healthkit_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for HealthKit behavior and privacy review."""
    return Agent(
        role="HealthKit Agent",
        goal=(
            "Review the Fitness Coach app's HealthKit integration, privacy copy, "
            "authorization states, active-energy fetching, and failure handling."
        ),
        backstory=(
            "You are an iOS health data engineer. You know HealthKit permission "
            "flows, entitlement requirements, user privacy expectations, and the "
            "difference between simulator checks and real-device validation."
        ),
        llm=llm,
        verbose=True,
    )


def create_swiftui_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for SwiftUI UX and app structure."""
    return Agent(
        role="SwiftUI Agent",
        goal=(
            "Review the Fitness Coach SwiftUI screens for clear state ownership, "
            "usable layout, accessible coaching guidance, onboarding, and launch "
            "readiness."
        ),
        backstory=(
            "You are a senior SwiftUI engineer who ships practical iOS apps. You "
            "look for fragile view state, confusing navigation, clipped layouts, "
            "missing accessibility labels, and places where product copy should "
            "be clearer before users rely on coaching guidance."
        ),
        llm=llm,
        verbose=True,
    )


def create_qa_agent(llm: LLM | None = None) -> Agent:
    """Create the agent responsible for terminal checks and QA planning."""
    return Agent(
        role="QA Agent",
        goal=(
            "Create a concrete QA plan for the Fitness Coach app, including "
            "terminal checks the developer can run, simulator expectations, "
            "real-device HealthKit validation, and release blockers."
        ),
        backstory=(
            "You are an iOS QA lead. You separate what can be proven in terminal "
            "from what must be checked on an iPhone, and you write short, "
            "repeatable test steps that developers can actually follow."
        ),
        llm=llm,
        verbose=True,
    )


def create_agents(llm: LLM | None = None) -> dict[str, Agent]:
    """Return all agents keyed by a short, readable name."""
    return {
        "beginner_gym_coach": create_beginner_gym_coach_agent(llm),
        "healthkit": create_healthkit_agent(llm),
        "swiftui": create_swiftui_agent(llm),
        "qa": create_qa_agent(llm),
    }
