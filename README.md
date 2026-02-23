# SwiftUI Navigation PoC

This document describes the navigation architecture used in this repository and provides implementation recipes for common and advanced navigation changes.

## Goals

- Keep navigation state explicit and testable.
- Keep flow-specific navigation logic isolated.
- Support cross-flow commands (for example logout or switch tab root) through a single command handler.
- Make common changes predictable through repeatable recipes.

## Navigation Architecture At A Glance

- `AppRouter` is the single source of navigation state.
- Feature routing protocols define flow-specific APIs:
  - `OnboardingRouting`
  - `Tab1Routing`
  - `Tab2Routing`
  - `SuccessRouting`
- `AppRouteCommand` models cross-flow transitions.
- `AppRouteCommandHandling` applies commands to router state.
- Coordinators build `NavigationStack`, map routes to screens, and invoke protocol APIs.

## Project Navigation Structure

- Core
  - `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/FeatureRoutingProtocols.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter+RouteCommandHandling.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter+SuccessRouting.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/RootCoordinatorView.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/AuthorizedCoordinatorView.swift`
- Flow extensions and coordinators
  - `SwiftUI-Navigation-PoC/Navigation/Onboarding/AppRouter+OnboardingRouting.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Onboarding/OnboardingCoordinatorView.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Tab1/AppRouter+Tab1Routing.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Tab1/Tab1CoordinatorView.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Tab2/AppRouter+Tab2Routing.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Tab2/Tab2CoordinatorView.swift`
- Models
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/Flow.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/OnboardingRoute.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab1Route.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab2Route.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/SuccessAction.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/SuccessPayload.swift`
  - `SwiftUI-Navigation-PoC/Navigation/Core/Models/AppRouteCommand.swift`

## Core Entities

### `Flow`
Represents top-level app mode (`onboarding`, `authorized`).

### `Tab`
Represents active tab within authorized mode.

### `Route` enums
- `OnboardingRoute`
- `Tab1Route`
- `Tab2Route`

Each route enum models navigation path values for one flow/tab.

### `SuccessAction` and `SuccessPayload`
- `SuccessPayload` defines content and action of global success screen.
- `SuccessAction` is user intent from that screen.
- `SuccessAction.routeCommand` maps actions to cross-flow command when needed.

### `AppRouteCommand`
Normalized cross-flow command layer.
Examples:
- `goAuthorizedTab1Root`
- `goAuthorizedTab2Root`
- `logoutToOnboarding`

### `AppRouter`
Single state holder.
Owns:
- top-level state (`flow`, `selectedTab`)
- per-flow paths (`onboardingStack`, `tab1Stack`, `tab2Stack`)
- global overlays (`successPayload`, `isPaywallPresented`)

### `Coordinator` views
Compose UI trees and bind to router state using `NavigationStack` and sheet APIs.

## Interfaces (Protocols)

### `OnboardingRouting`
Owns onboarding-specific actions:
- push onboarding route
- pop onboarding to root
- present and dismiss paywall

### `Tab1Routing`
Owns tab1 stack actions:
- push route
- pop by count
- pop to root

### `Tab2Routing`
Owns tab2 stack actions:
- push route
- pop by count
- pop to root

### `SuccessRouting`
Owns success overlay lifecycle:
- present success
- handle success primary action

### `AppRouteCommandHandling`
Applies cross-flow command to full router state.
This is the single place for global reset/switch logic.

## Architectural Invariants

- One source of truth for navigation state: `AppRouter`.
- Every flow has an isolated route enum and routing protocol.
- Cross-flow transitions must go through `AppRouteCommand`.
- Coordinators should not mutate unrelated flow state directly.
- `pop(n)` must never crash when stack count is less than `n`.

## Navigation Operations

- `push(route)`
- `pop(1)`
- `pop(n)`
- `popToRoot()`
- `presentSheet(...)`
- `dismissSheet()`
- `presentGlobalSuccess(...)`
- `handleRouteCommand(...)`

## Recipe Template (Use For Any New Case)

1. Define or update model (`Flow`, `Tab`, `Route`, `Action`, `Command`).
2. Extend protocol contract for affected flow only.
3. Implement in corresponding `AppRouter+<Flow>Routing.swift` extension.
4. Update coordinator mapping (`navigationDestination`, toolbar/button handlers).
5. Add command handling if transition is cross-flow.
6. Add or update unit tests.
7. Add analytics events for entry, transition, and completion.

## How To Add Common Cases

### 1) Add A New Flow

1. Add new case to `Flow`.
2. Add route model(s) for the flow.
3. Add router state properties for new flow path and modal state.
4. Add new protocol `NewFlowRouting`.
5. Add extension `AppRouter+NewFlowRouting.swift`.
6. Add `NewFlowCoordinatorView`.
7. Connect it in `RootCoordinatorView` flow switch.
8. Add command(s) if other flows can jump to it.
9. Add tests for entry and reset.

### 2) Add A New Screen To Existing Flow

1. Add enum case to corresponding route.
2. Add UI screen view.
3. Update `navigationDestination(for:)` switch.
4. Add push trigger from current screen.
5. Add pop/return behavior if needed.
6. Add test for route transition.

### 3) Add Tab Bar Or Add New Tab

1. Add new case to `Tab`.
2. Add new route enum and stack state (if new tab needs stack).
3. Add `NewTabRouting` protocol and extension.
4. Add tab coordinator.
5. Wire new tab into `AuthorizedCoordinatorView` `TabView`.
6. Add command support for selecting/resetting new tab root.
7. Add tests for tab switch and reset behavior.

### 4) Navigate To Flow Root

For same flow:
- call `popToRoot()` in that flow protocol.

For cross-flow root:
- define/use `AppRouteCommand` and apply in command handler.

### 5) Navigate Back N Screens

1. Use `pop(n)` in flow protocol.
2. Clamp count safely (`min(max(n, 0), stack.count)`).
3. No-op if result is zero.
4. Add tests for `n = 0`, `n < 0`, and `n > stack.count`.

### 6) Navigate Back To Specific Screen

1. Add helper in flow router extension:
   - `popTo(_ predicate: (Route) -> Bool)` or
   - `popTo(routeID)`
2. Find index from top and trim stack.
3. No-op if target not found.
4. Add tests for found/not found cases.

### 7) Add Flow-Scoped Common Screen With Parameters

Use when screen is reusable inside one flow.

1. Add route case with associated values.
2. Route to one reusable `CommonScreenView(params:)`.
3. Keep params value-semantic and serializable when possible.
4. Add tests for parameter propagation.

### 8) Add App-Global Common Screen

Use when any flow can open same screen (for example success, alert hub, legal modal).

1. Add global payload state to router (`@Published var ...Payload`).
2. Add present/dismiss API in dedicated routing protocol.
3. Render from `RootCoordinatorView` as top-level sheet/fullScreenCover.
4. Add command if action triggers cross-flow transition.
5. Add tests for presentation and dismissal.

### 9) Add Navigation Analytics

Add lightweight event layer, for example:
- `screen_view`
- `route_push`
- `route_pop`
- `flow_switch`
- `tab_switch`
- `command_applied`

Implementation guideline:
1. Define analytics protocol (`NavigationAnalyticsTracking`).
2. Inject tracker into router or command handler.
3. Emit events where transitions are decided (router extensions, command handler).
4. Add tests with tracker spy to assert event order.

### 10) Return To Specific Screen Across Flows

1. Model target as command (`AppRouteCommand`).
2. Command handler resets irrelevant stacks.
3. Command handler sets target flow/tab and target route path.
4. Add tests verifying all unrelated stacks are reset.

### 11) Deep Links

1. Parse URL into typed intent.
2. Map intent to `AppRouteCommand` + optional route payload.
3. Apply command in one place.
4. Handle invalid links with fallback route.
5. Add tests for valid/invalid link mapping.

### 12) State Restoration

1. Serialize `NavigationState` snapshot.
2. Restore flow/tab/paths on launch.
3. Validate route payload compatibility on app version changes.
4. Fallback to safe root when restore fails.

## Testing Strategy

### Unit tests (required)
- Router state transitions.
- Command handling behavior.
- Route edge cases (`pop(n)`).

### Integration tests (recommended)
- Coordinator route mapping.
- Cross-flow command behavior.

### UI tests (selective)
- Critical user journeys.
- Smoke tests for startup and logout.

## Anti-Patterns

- Coordinators mutating unrelated flow state directly.
- Cross-flow transitions implemented ad hoc in random views.
- Route enums carrying heavy domain objects.
- Missing no-op behavior for invalid pop or missing targets.
- Analytics emitted from views instead of routing layer.

## Definition Of Done For Navigation Changes

- New behavior is represented in model/protocol/extension layers.
- Coordinator wiring is updated.
- Cross-flow logic goes through command handler.
- Unit tests cover transition and edge cases.
- Analytics events are emitted for key transitions.
- README recipes are updated when architecture changes.
