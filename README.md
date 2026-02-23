# SwiftUI Navigation Guide

This document is a practical blueprint for building scalable navigation from scratch in a new SwiftUI project.

Goals:

1. a single source of truth for navigation state
2. safe and predictable transitions within a flow and across flows
3. easy extensibility (new flows, tabs, common screens, deep links, analytics)
4. testable navigation logic at unit and integration levels

## 1. Core Architecture Model

The architecture has 4 layers:

1. `Models` (navigation types)
- `Flow`
- `Tab`
- feature-specific `Route` types
- `OverlayPayload` / `SuccessPayload`
- `NavigationCommand`
- `NavigationAction` (optional)

2. `Router State`
- one shared `AppRouter` with `@Published` state

3. `Routing Contracts`
- flow-specific protocols (`OnboardingRouting`, `ProfileRouting`, etc.)
- global protocols (`GlobalOverlayRouting`, `NavigationCommandHandling`)

4. `Coordinator Layer`
- root coordinator selects the active flow
- flow coordinators map route -> screen
- coordinators call methods from routing protocols

## 2. Standard Entities and Interfaces

### 2.1 `Flow`
Purpose: top-level application mode.

```swift
enum Flow: Equatable {
    case onboarding
    case authorized
    case maintenance
}
```

### 2.2 `Tab`
Purpose: active tab in the authorized area.

```swift
enum Tab: Hashable {
    case home
    case profile
    case settings
}
```

### 2.3 Route types
Purpose: navigation stack state within a specific flow/tab.

```swift
enum HomeRoute: Hashable {
    case details(id: UUID)
    case filters
}

enum ProfileRoute: Hashable {
    case edit
    case notifications
}
```

### 2.4 `NavigationCommand`
Purpose: cross-flow transitions and reset operations.

```swift
enum NavigationCommand: Equatable {
    case goToAuthorized(tab: Tab)
    case logoutToOnboarding
    case openFlowRoot(flow: Flow)
}
```

### 2.5 `OverlayPayload` (or `SuccessPayload`)
Purpose: global screens/overlays that can be triggered from any flow.

```swift
struct SuccessPayload: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let primaryAction: SuccessAction
}
```

### 2.6 `AppRouter`
Purpose: single navigation state container.

```swift
@MainActor
final class AppRouter: ObservableObject {
    @Published var flow: Flow = .onboarding
    @Published var selectedTab: Tab = .home

    @Published var homeStack: [HomeRoute] = []
    @Published var profileStack: [ProfileRoute] = []

    @Published var successPayload: SuccessPayload?
    @Published var isPaywallPresented = false
}
```

### 2.7 Routing protocols
Purpose: limit each feature to only the navigation API it needs.

```swift
@MainActor
protocol HomeRouting: AnyObject {
    var homeStack: [HomeRoute] { get set }
    func homePush(_ route: HomeRoute)
    func homePop(_ n: Int)
    func homePopToRoot()
}

@MainActor
protocol GlobalOverlayRouting: AnyObject {
    var successPayload: SuccessPayload? { get set }
    func presentSuccess(_ payload: SuccessPayload)
    func dismissSuccess()
}

@MainActor
protocol NavigationCommandHandling: AnyObject {
    func handleCommand(_ command: NavigationCommand)
}
```

### 2.8 `Coordinator`
Purpose: UI composition and binding to state.

- `RootCoordinator`: switches by `flow`, hosts global sheet/fullScreenCover.
- `FlowCoordinator`: owns `NavigationStack(path:)` and `navigationDestination`.

### 2.9 `NavigationAnalyticsTracking`
Purpose: centralized navigation analytics.

```swift
protocol NavigationAnalyticsTracking: AnyObject {
    func track(_ event: NavigationEvent)
}
```

## 3. Contracts and Invariants

1. `AppRouter` is the only source of navigation state.
2. Intra-flow operations must not mutate state of unrelated flows.
3. Cross-flow transitions must go through `NavigationCommand`.
4. `pop(n)` must be safe for any `n` (including `n <= 0` and `n > stack.count`).
5. Global overlays must be rendered at root level.
6. UI layer must not contain business logic for cross-flow transitions.

## 4. New Project Bootstrap (Step-by-step)

1. Define `Flow`, `Tab`, and route types by feature.
2. Create `AppRouter` with `@Published` state for each flow/tab/overlay.
3. Create routing protocols by feature.
4. Implement protocols in `AppRouter` using one extension per flow.
5. Add `NavigationCommand` and `NavigationCommandHandling` for cross-flow logic.
6. Implement `RootCoordinator`.
7. Implement `FlowCoordinator` for each flow/tab.
8. Add common/global overlays (sheet/fullScreenCover).
9. Add unit tests for router and command handler.
10. Add navigation analytics in the routing layer.

## 5. Playbook: How to Add Common Cases

The cases below cover most real-world navigation changes.

### 5.1 Add a new flow

What to add:

1. a new case in `Flow`
2. route type(s) for the flow
3. state in `AppRouter` (`[NewFlowRoute]`, modal flags)
4. `NewFlowRouting` protocol
5. `AppRouter+NewFlowRouting.swift`
6. `NewFlowCoordinator`
7. a new branch in `RootCoordinator` switch
8. (optional) related commands in `NavigationCommand`

Validation:

1. flow is reachable from root
2. reset from this flow is correct
3. unrelated stacks remain intact

### 5.2 Add a new screen inside a flow

What to do:

1. add a new route case
2. add destination mapping in coordinator switch
3. add trigger (`push`) from source screen
4. add return behavior (`pop`, `popToRoot`, `pop(n)`) if needed

Validation:

1. screen is reachable
2. back navigation is correct
3. pop edge cases do not crash

### 5.3 Add tab bar / add a new tab

What to do:

1. extend `Tab`
2. add route enum and stack state for the new tab
3. add `NewTabRouting`
4. add extension with `push/pop/popToRoot`
5. register coordinator in `TabView`
6. add tab selection command if needed

Validation:

1. each tab has independent stack
2. tab switching does not lose state unexpectedly

### 5.4 Navigate to flow root

Option A (inside same flow):

1. call flow-specific `popToRoot()`

Option B (cross-flow):

1. add `NavigationCommand.openFlowRoot(...)`
2. implement state reset in command handler

### 5.5 Navigate back N screens

Implementation:

1. `let count = min(max(n, 0), stack.count)`
2. `guard count > 0 else { return }`
3. `stack.removeLast(count)`

Tests:

1. `n = 0`
2. `n < 0`
3. `n > count`

### 5.6 Add a flow-scoped common screen with parameters

Implementation:

1. add route case with associated values
2. use one reusable screen, for example `CommonXView(params:)`
3. map route in that flow coordinator
4. keep navigation API flow-scoped

Tests:

1. parameters reach the destination correctly
2. different inputs produce expected navigation outcomes

### 5.7 Add an app-global common screen

Implementation:

1. add global payload state to `AppRouter`
2. add `GlobalOverlayRouting` protocol
3. render at root as global sheet/fullScreenCover
4. if action triggers cross-flow transition, use `NavigationCommand`

Tests:

1. screen opens from any flow
2. screen dismisses correctly
3. action maps to expected command

### 5.8 Add analytics

Recommended minimum events:

1. `screen_view`
2. `route_push`
3. `route_pop`
4. `flow_switch`
5. `tab_switch`
6. `command_applied`

Where to emit:

1. routing extensions
2. command handler

Where not to emit:

1. ad-hoc from random places in SwiftUI `body`

### 5.9 Return to a specific screen

Inside one flow:

1. add helper like `popTo(where:)` or `popTo(routeID:)`
2. find target in stack
3. trim stack tail
4. no-op if target not found

Across flows:

1. represent target as `NavigationCommand`
2. apply via command handler

### 5.10 Deep links

Implementation:

1. parse URL -> typed intent
2. map intent -> `NavigationCommand` + optional route payload
3. use one entry point to apply deep link
4. use safe fallback for invalid links

### 5.11 State restoration

Implementation:

1. define serializable navigation snapshot
2. restore `flow`, `tab`, and route stacks on launch
3. handle payload version compatibility
4. fallback to root when restore is invalid

## 6. Recommended Folder Layout for a New Project

```text
Navigation/
  Core/
    AppRouter.swift
    NavigationContracts.swift
    AppRouter+CommandHandling.swift
    RootCoordinatorView.swift
  Flows/
    Onboarding/
      OnboardingRoute.swift
      OnboardingRouting.swift
      AppRouter+OnboardingRouting.swift
      OnboardingCoordinatorView.swift
    Home/
      HomeRoute.swift
      HomeRouting.swift
      AppRouter+HomeRouting.swift
      HomeCoordinatorView.swift
  Global/
    GlobalOverlayModels.swift
    AppRouter+GlobalOverlayRouting.swift
  Commands/
    NavigationCommand.swift
  Analytics/
    NavigationAnalyticsTracking.swift
```

## 7. Test Plan

### Unit (required)

1. push/pop/popToRoot/pop(n)
2. command handling
3. `SuccessAction -> NavigationCommand` mapping
4. no-op scenarios

### Integration (recommended)

1. coordinator route mapping
2. cross-flow transitions from user intents

### UI (targeted)

1. startup flow selection
2. onboarding happy path -> authorized
3. logout reset path

## 8. Definition of Done for Navigation Changes

1. model is added/updated (`Flow/Route/Command/Action`)
2. protocol contract is added/updated
3. router extension is added/updated
4. coordinators are updated
5. tests are added/updated
6. documentation is updated

## 9. Anti-patterns

1. mutating another flow's state from feature UI code
2. duplicating cross-flow logic in multiple places
3. storing heavy domain models inside route enums
4. unsafe pop logic without clamping
5. emitting duplicate analytics events for one transition
