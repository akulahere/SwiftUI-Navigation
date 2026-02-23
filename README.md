# SwiftUI Navigation PoC

This README is the canonical navigation guide for this repository.
It covers:

1. core navigation entities and interfaces
2. invariants and state contracts
3. implementation playbooks for common and advanced navigation changes

## 1. Why This Architecture

Navigation is modeled as explicit state plus typed commands.
The design goals are:

1. single source of truth for navigation state
2. flow isolation (onboarding, tab1, tab2)
3. predictable cross-flow transitions
4. testable routing logic without UI coupling

## 2. Current Navigation Layout

### 2.1 Core

- `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/FeatureRoutingProtocols.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter+SuccessRouting.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/AppRouter+RouteCommandHandling.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/RootCoordinatorView.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/AuthorizedCoordinatorView.swift`

### 2.2 Flow-specific

- `SwiftUI-Navigation-PoC/Navigation/Onboarding/AppRouter+OnboardingRouting.swift`
- `SwiftUI-Navigation-PoC/Navigation/Onboarding/OnboardingCoordinatorView.swift`
- `SwiftUI-Navigation-PoC/Navigation/Tab1/AppRouter+Tab1Routing.swift`
- `SwiftUI-Navigation-PoC/Navigation/Tab1/Tab1CoordinatorView.swift`
- `SwiftUI-Navigation-PoC/Navigation/Tab2/AppRouter+Tab2Routing.swift`
- `SwiftUI-Navigation-PoC/Navigation/Tab2/Tab2CoordinatorView.swift`

### 2.3 Models

- `SwiftUI-Navigation-PoC/Navigation/Core/Models/Flow.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/OnboardingRoute.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab1Route.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/Tab2Route.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/SuccessAction.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/SuccessPayload.swift`
- `SwiftUI-Navigation-PoC/Navigation/Core/Models/AppRouteCommand.swift`

## 3. Navigation Entity Catalog

### 3.1 `Flow`
Top-level application mode.

Current values:
- `onboarding`
- `authorized`

### 3.2 `Tab`
Selected tab in authorized flow.

Current values:
- `tab1`
- `tab2`

### 3.3 `Route` enums
Each flow has a route enum used by `NavigationStack(path:)`.

- `OnboardingRoute`
- `Tab1Route`
- `Tab2Route`

### 3.4 `SuccessAction`
Action selected on global success UI.
It is mapped to cross-flow command via `routeCommand`.

### 3.5 `AppRouteCommand`
Typed cross-flow command used by command handler.

Current commands:
- `goAuthorizedTab1Root`
- `goAuthorizedTab2Root`
- `logoutToOnboarding`

### 3.6 `SuccessPayload`
Data for global success presentation:
- title
- message
- primary button title
- `SuccessAction`

### 3.7 `AppRouter`
Single navigation state holder (`@MainActor`, `ObservableObject`).
State groups:

1. shared state
- `flow`
- `selectedTab`
- `successPayload`

2. onboarding state
- `onboardingStack`
- `isPaywallPresented`

3. feature states
- `tab1Stack`
- `tab2Stack`

### 3.8 Routing protocols
- `OnboardingRouting`
- `Tab1Routing`
- `Tab2Routing`
- `SuccessRouting`
- `AppRouteCommandHandling`

These protocols define the contract surface used by coordinators and command handlers.

### 3.9 Coordinators
Coordinators map route state to UI.
They own screen composition and navigation bindings.

## 4. Interface Reference (Current Contracts)

### 4.1 Router state

```swift
@MainActor
final class AppRouter: ObservableObject {
    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .tab1
    @Published var successPayload: SuccessPayload?

    @Published var onboardingStack: [OnboardingRoute] = []
    @Published var isPaywallPresented = false

    @Published var tab1Stack: [Tab1Route] = []
    @Published var tab2Stack: [Tab2Route] = []
}
```

### 4.2 Flow routing protocols

```swift
@MainActor
protocol OnboardingRouting: AnyObject {
    var onboardingStack: [OnboardingRoute] { get set }
    var isPaywallPresented: Bool { get set }

    func onboardingPush(_ route: OnboardingRoute)
    func onboardingPopToRoot()
    func presentPaywall()
    func dismissPaywall()
}

@MainActor
protocol Tab1Routing: AnyObject {
    var tab1Stack: [Tab1Route] { get set }

    func tab1Push(_ route: Tab1Route)
    func tab1Pop(_ n: Int)
    func tab1PopToRoot()
}

@MainActor
protocol Tab2Routing: AnyObject {
    var tab2Stack: [Tab2Route] { get set }

    func tab2Push(_ route: Tab2Route)
    func tab2Pop(_ n: Int)
    func tab2PopToRoot()
}

@MainActor
protocol SuccessRouting: AnyObject {
    var successPayload: SuccessPayload? { get set }
    var flow: Flow { get set }
    var selectedTab: Tab { get set }

    func presentSuccess(
        title: String,
        message: String,
        primaryButton: String,
        primaryAction: SuccessAction
    )

    func handleSuccessPrimary()
}
```

### 4.3 Cross-flow command handling

```swift
@MainActor
protocol AppRouteCommandHandling: AnyObject {
    func handleRouteCommand(_ command: AppRouteCommand)
}
```

## 5. Operational Contracts

### 5.1 Push
Contract:
1. append route to target flow stack
2. no unrelated stack mutation

### 5.2 Pop one / pop N
Contract:
1. pop count is clamped with `min(max(n, 0), stack.count)`
2. if effective count is `0`, operation is no-op
3. must never crash for out-of-range `n`

### 5.3 Pop to root
Contract:
1. target stack becomes empty
2. unrelated stacks unchanged

### 5.4 Global success
Contract:
1. `presentSuccess(...)` sets payload
2. `handleSuccessPrimary()` clears payload first
3. if action maps to command, command handler applies cross-flow transition
4. if action is `dismiss`, no command is applied

### 5.5 Cross-flow command
Contract:
1. command handler is the only place for cross-flow reset/switch behavior
2. each command must leave router in valid invariant state

## 6. Global Invariants

1. `AppRouter` is the single source of navigation state.
2. Coordinators do not directly edit unrelated flow stacks.
3. Cross-flow transitions must go through `AppRouteCommandHandling`.
4. Flow-specific operations are exposed by flow-specific protocols.
5. Navigation operations are deterministic and safe for invalid pop counts.

## 7. Change Playbooks

All playbooks follow the same skeleton:

1. update model(s)
2. update protocol contract(s)
3. update `AppRouter` extension implementation(s)
4. update coordinator wiring
5. update tests
6. update analytics events if required

### 7.1 Add new flow

Touch points:
- `Flow.swift`
- new route model file(s)
- `AppRouter.swift`
- new `NewFlowRouting` in `FeatureRoutingProtocols.swift`
- `AppRouter+NewFlowRouting.swift`
- `RootCoordinatorView.swift`
- optional `AppRouteCommand.swift` and command handler

Steps:
1. add flow enum case
2. add flow route enum and router state stack
3. add flow routing protocol and extension
4. create new flow coordinator
5. add coordinator to root flow switch
6. add cross-flow command if flow can be entered externally
7. add tests for entry and reset

Done criteria:
- flow can be entered and exited
- no unrelated stacks are corrupted

### 7.2 Add new screen to existing flow

Touch points:
- route enum of target flow
- target flow coordinator switch in `navigationDestination`
- optional reusable screen file in `Views/*`

Steps:
1. add route case
2. add destination mapping in coordinator
3. add trigger (`push`) from source screen
4. add return behavior if needed
5. add unit/integration test for transition

Done criteria:
- new route is reachable
- back navigation works and preserves stack consistency

### 7.3 Add tab bar or add new tab

Touch points:
- `Tab.swift`
- new tab route model
- `AppRouter.swift` state
- `FeatureRoutingProtocols.swift` and `AppRouter+NewTabRouting.swift`
- `AuthorizedCoordinatorView.swift`

Steps:
1. add tab enum case
2. add stack state for tab
3. add routing protocol and extension
4. add tab coordinator
5. register in `TabView`
6. add optional command for tab root switch

Done criteria:
- independent stack per tab
- switching tabs does not lose stack state unexpectedly

### 7.4 Navigate to flow root

Same-flow:
1. call `popToRoot()` in the corresponding flow protocol

Cross-flow:
1. define command in `AppRouteCommand`
2. apply state mutation in command handler only

Done criteria:
- target flow root shown
- invariant state preserved

### 7.5 Navigate back N screens

Steps:
1. use `pop(n)` in flow routing extension
2. clamp count safely
3. keep no-op for invalid values
4. test `n=0`, negative `n`, and `n>count`

Done criteria:
- no crashes
- deterministic stack outcome

### 7.6 Return to specific screen

Recommended approach:
1. add helper in flow extension, for example `popTo(where:)`
2. locate target from top of stack
3. trim stack accordingly
4. if missing target, no-op

Done criteria:
- route found case and not-found case are both covered by tests

### 7.7 Add flow-scoped common screen with parameters

Use case:
- reusable screen inside one flow only

Steps:
1. add route case with associated values
2. create reusable view with typed params
3. map route to view in that flow coordinator
4. add tests for parameter propagation

Done criteria:
- screen is reusable in flow
- params are explicit and type-safe

### 7.8 Add app-global common screen

Use case:
- screen can be opened from any flow

Steps:
1. add global payload state to `AppRouter`
2. add present/dismiss API in dedicated protocol/extension
3. render in `RootCoordinatorView` as top-level sheet/full-screen cover
4. add command mapping if it triggers cross-flow transition
5. add tests for show/dismiss/command behavior

Done criteria:
- screen can be opened from all flows
- global layering is predictable

### 7.9 Add navigation analytics

Recommended event set:
- `screen_view`
- `route_push`
- `route_pop`
- `flow_switch`
- `tab_switch`
- `command_applied`

Steps:
1. define `NavigationAnalyticsTracking` protocol
2. inject tracker into routing extension or command handler
3. emit events where transition decision is made (not in raw UI body)
4. test with tracker spy for order and payload

Done criteria:
- stable event schema
- no duplicate events for a single action

### 7.10 Return to specific screen across flows

Steps:
1. model target via `AppRouteCommand`
2. command handler resets irrelevant stacks
3. command handler sets flow/tab and optionally target route path
4. add tests verifying full state result

Done criteria:
- transition deterministic from any source state

### 7.11 Deep links

Steps:
1. parse URL into typed intent
2. map intent to command plus optional route payload
3. apply in a single routing entrypoint
4. fallback to safe root for invalid/missing data
5. test valid and invalid links

Done criteria:
- unsupported links are safe
- supported links always resolve to expected state

### 7.12 State restoration

Steps:
1. define serializable `NavigationStateSnapshot`
2. restore `flow`, `selectedTab`, and route stacks on launch
3. validate compatibility for changed route payloads
4. fallback to safe root if snapshot invalid

Done criteria:
- app reopens in expected place
- invalid snapshot never crashes navigation

## 8. Testing Matrix

### 8.1 Unit tests (required)

- flow route push/pop/popToRoot
- `pop(n)` edge cases
- command handler state transitions
- success action to command mapping

Current examples:
- `SwiftUI-Navigation-PoCTests/AppRouterRouteCommandTests.swift`

### 8.2 Integration tests (recommended)

- coordinator route mapping correctness
- cross-flow transition execution from UI actions

### 8.3 UI tests (selective)

- startup flow routing
- onboarding happy path
- logout reset path

## 9. Analytics Contract (Recommended)

Use structured payloads for every event:

- `event_name`
- `from_flow`
- `to_flow`
- `from_route`
- `to_route`
- `tab`
- `command`
- `timestamp`
- `correlation_id`

This enables reconstruction of navigation sessions and debugging of edge transitions.

## 10. Anti-Patterns

1. cross-flow state edits from random coordinator code
2. untyped route payloads (for example dictionaries)
3. heavy domain models embedded directly in route enums
4. duplicated transition logic outside command handler
5. analytics emitted from multiple layers for one transition

## 11. Definition Of Done For Any Navigation Change

1. model layer updated (`Flow/Route/Action/Command` where needed)
2. protocol and router extension contracts updated
3. coordinator mapping updated
4. tests added or adjusted
5. analytics updated (if applicable)
6. README playbook updated if architecture changed

## 12. Quick Decision Guide

- Need transition inside one flow: use flow routing protocol.
- Need transition across flows or tab roots: use `AppRouteCommand`.
- Need reusable screen in one flow: use route with associated values.
- Need reusable screen app-wide: use global payload + root presentation.
- Need observability: log in routing/command layer, not view body.
