# SwiftUI Navigation Guide

Этот документ не про текущее состояние конкретного экрана, а про то, как с нуля собрать масштабируемую навигацию в новом проекте SwiftUI.

Цели:

1. единый источник правды для navigation state
2. безопасные и предсказуемые переходы внутри flow и между flow
3. простое расширение (новые flow, табы, common-экраны, deeplink, analytics)
4. тестируемость навигации на уровне unit/integration

## 1. Базовая модель архитектуры

Архитектура состоит из 4 слоёв:

1. `Models` (типы навигации)
- `Flow`
- `Tab`
- `Route`-типы по фичам
- `OverlayPayload`/`SuccessPayload`
- `NavigationCommand`
- `NavigationAction` (опционально)

2. `Router State`
- единый `AppRouter` c `@Published` state

3. `Routing Contracts`
- протоколы по flow (`OnboardingRouting`, `ProfileRouting`, etc.)
- протоколы для глобальных сценариев (`GlobalOverlayRouting`, `NavigationCommandHandling`)

4. `Coordinator Layer`
- root coordinator выбирает flow
- flow coordinators мапят route -> screen
- coordinators вызывают методы routing-протоколов

## 2. Типовые сущности и интерфейсы

### 2.1 `Flow`
Назначение: верхнеуровневый режим приложения.

```swift
enum Flow: Equatable {
    case onboarding
    case authorized
    case maintenance
}
```

### 2.2 `Tab`
Назначение: активный таб в авторизованной части.

```swift
enum Tab: Hashable {
    case home
    case profile
    case settings
}
```

### 2.3 Route-типы
Назначение: стек навигации в рамках конкретного flow/tab.

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
Назначение: кросс-flow переходы и reset-операции.

```swift
enum NavigationCommand: Equatable {
    case goToAuthorized(tab: Tab)
    case logoutToOnboarding
    case openFlowRoot(flow: Flow)
}
```

### 2.5 `OverlayPayload` (или `SuccessPayload`)
Назначение: глобальные экраны/оверлеи, доступные из любого flow.

```swift
struct SuccessPayload: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let primaryAction: SuccessAction
}
```

### 2.6 `AppRouter`
Назначение: единый navigation state.

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

### 2.7 Routing-протоколы
Назначение: ограничить API фичи только нужными операциями.

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
Назначение: UI-композиция и привязка к state.

- `RootCoordinator`: switch по `flow`, глобальные sheet/fullScreenCover.
- `FlowCoordinator`: `NavigationStack(path:)` + `navigationDestination`.

### 2.9 `NavigationAnalyticsTracking`
Назначение: централизованная аналитика переходов.

```swift
protocol NavigationAnalyticsTracking: AnyObject {
    func track(_ event: NavigationEvent)
}
```

## 3. Контракты и инварианты

1. `AppRouter` — единственный источник navigation state.
2. Внутрифлоу-операции не мутируют state чужих flow.
3. Кросс-flow переходы делаются только через `NavigationCommand`.
4. `pop(n)` безопасен для любых `n` (включая `n <= 0` и `n > stack.count`).
5. Глобальные оверлеи рендерятся на root-уровне.
6. Слой UI не содержит бизнес-логики переходов между flow.

## 4. Bootstrap нового проекта (пошагово)

1. Определи `Flow`, `Tab`, route-типы по фичам.
2. Создай `AppRouter` с `@Published` state для каждого flow/tab/overlay.
3. Создай routing-протоколы по фичам.
4. Реализуй протоколы в `AppRouter` через extension по одному flow на файл.
5. Добавь `NavigationCommand` и `NavigationCommandHandling` для кросс-flow.
6. Реализуй `RootCoordinator`.
7. Реализуй `FlowCoordinator` для каждого flow/tab.
8. Добавь common/global overlays (sheet/fullScreenCover).
9. Добавь unit-тесты роутера и command handler.
10. Добавь аналитику переходов в routing layer.

## 5. Playbook: как добавлять кейсы

Ниже типовые изменения, которые покрывают большинство задач.

### 5.1 Добавление нового flow

Что добавить:

1. новый кейс в `Flow`
2. route-тип(ы) flow
3. state в `AppRouter` (`[NewFlowRoute]`, модалки)
4. `NewFlowRouting` протокол
5. `AppRouter+NewFlowRouting.swift`
6. `NewFlowCoordinator`
7. ветку в `RootCoordinator` switch
8. (опционально) команды в `NavigationCommand`

Проверки:

1. flow открывается из root
2. reset из этого flow корректен
3. чужие стеки не ломаются

### 5.2 Добавление нового экрана во flow

Что сделать:

1. добавить кейс в route enum
2. добавить destination в coordinator switch
3. добавить trigger (`push`) из текущего экрана
4. добавить возврат (`pop`, `popToRoot`, `pop(n)` по необходимости)

Проверки:

1. экран достижим
2. back-навигация корректна
3. edge-cases pop не приводят к крэшу

### 5.3 Добавление tab bar / нового таба

Что сделать:

1. расширить `Tab`
2. добавить route enum и stack state для нового таба
3. добавить `NewTabRouting`
4. добавить extension с `push/pop/popToRoot`
5. подключить coordinator в `TabView`
6. добавить команду выбора таба (при необходимости)

Проверки:

1. отдельный стек у каждого таба
2. переключение табов не теряет state непредсказуемо

### 5.4 Переход в начало flow

Вариант A (внутри flow):

1. вызвать `popToRoot()` нужного flow

Вариант B (кросс-flow):

1. добавить `NavigationCommand.openFlowRoot(...)`
2. реализовать state-reset в command handler

### 5.5 Переход на N экранов назад

Реализация:

1. `let count = min(max(n, 0), stack.count)`
2. `guard count > 0 else { return }`
3. `stack.removeLast(count)`

Тесты:

1. `n = 0`
2. `n < 0`
3. `n > count`

### 5.6 Добавление common-экрана внутри flow с параметрами

Реализация:

1. кейс route с associated values
2. один reusable экран `CommonXView(params:)`
3. destination mapping в этом flow coordinator
4. только flow-level routing API

Тесты:

1. параметры доходят до экрана
2. разные входные параметры дают корректные экраны

### 5.7 Добавление common-экрана для всего приложения

Реализация:

1. добавить global payload state в `AppRouter`
2. добавить протокол `GlobalOverlayRouting`
3. рендерить экран в `RootCoordinator` как global sheet/fullScreenCover
4. если экран вызывает кросс-flow переход, использовать `NavigationCommand`

Тесты:

1. экран открывается из любого flow
2. корректно закрывается
3. action приводит к ожидаемому command

### 5.8 Добавление аналитики

Рекомендованный минимум событий:

1. `screen_view`
2. `route_push`
3. `route_pop`
4. `flow_switch`
5. `tab_switch`
6. `command_applied`

Где отправлять:

1. в routing extension
2. в command handler

Где не отправлять:

1. в случайных местах в `body` SwiftUI view

### 5.9 Возврат на определенный экран

Внутри flow:

1. добавить helper `popTo(where:)` или `popTo(routeID:)`
2. найти таргет в стеке
3. удалить хвост стека
4. если не найден, no-op

Кросс-flow:

1. описать target через `NavigationCommand`
2. применить через command handler

### 5.10 Deep links

Реализация:

1. parser URL -> typed intent
2. mapper intent -> `NavigationCommand` + route payload
3. единая entrypoint-функция применения deeplink
4. safe fallback при невалидном линке

### 5.11 State restoration

Реализация:

1. сериализуемый snapshot navigation state
2. восстановление `flow`, `tab`, стеков на старте
3. совместимость версий payload
4. fallback в root при ошибке восстановления

## 6. Рекомендуемая структура файлов в новом проекте

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

## 7. Тестовый план

### Unit (обязательно)

1. push/pop/popToRoot/pop(n)
2. command handling
3. mapping `SuccessAction -> NavigationCommand`
4. no-op сценарии

### Integration (желательно)

1. coordinator route mapping
2. cross-flow actions from user intents

### UI (точечно)

1. startup flow
2. happy path onboarding -> authorized
3. logout reset

## 8. Definition of Done для навигационных изменений

1. добавлен/обновлен model (`Flow/Route/Command/Action`)
2. добавлен/обновлен protocol contract
3. добавлен/обновлен router extension
4. обновлены coordinators
5. добавлены тесты
6. обновлена документация

## 9. Антипаттерны

1. мутировать state другого flow из UI-кода фичи
2. дублировать кросс-flow логику в нескольких местах
3. хранить тяжёлые доменные модели в route enum
4. делать небезопасный `pop` без clamping
5. отправлять analytics из множества слоев для одного перехода
