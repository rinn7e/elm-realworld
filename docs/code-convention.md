# Elm Code Conventions

## Table of Contents

- [Task Scope and Refactoring](#task-scope-and-refactoring)
- [Import Organization](#import-organization)
- [Control Flow](#control-flow)
- [Functional Programming](#functional-programming)
- [No Side Effects](#no-side-effects)
- [Custom Types (ADTs)](#custom-types-adts)
- [TEA Child Msg Interception](#tea-child-msg-interception)
- [File Structure and Splitting](#file-structure-and-splitting)
  - [Elm Modules](#elm-modules)
  - [Dependency Order and Hierarchy](#dependency-order-and-hierarchy)
- [UI Styling Guidelines](#ui-styling-guidelines)

---

## Task Scope and Refactoring

Prefer not to update or refactor code outside of the specific task or feature that is assigned to you. Keep your changes focused on the current objective to prevent unintended side effects and scope creep.

---

## Import Organization

All imports should be grouped into three sections for clarity and consistency:

1.  **Standard Libraries** – internal Elm modules (e.g. `Html`, `Http`).
2.  **Package Modules** – our custom wrapper modules under `Package/`.
3.  **Local Modules** – our application modules (e.g. `Api/`, `Page/`, `Type.elm`).

Each section is then sorted alphabetically.

Example:

```elm
import Html exposing (..)
import Html.Attributes exposing (..)
import Http

import Package.Prelude exposing (cn)

import Api.Type.Article exposing (Article)
import Type exposing (Model, Msg(..))
```

---

## Control Flow

In Elm, control flow is primarily managed via `case` expressions and `if` expressions. Avoid complex nested logic where possible.

### If Expressions

Always use the full `if ... then ... else ...` structure. There is no "early return" in Elm.

```elm
-- ✅ Correct
foo x =
    if x == 0 then
        "zero"
    else
        "non-zero"
```

---

## Functional Programming

Use standard Elm functions (like those in `List`, `Maybe`, `Result`, `Dict`) instead of trying to use imperative patterns.

```elm
-- ✅ Correct
List.map (\x -> x + 1) myList
```

---

## No Side Effects

Elm is purely functional. All side effects (API calls, storage access) must be performed via `Cmd`. Never attempt to perform side effects directly in `update` or `view`.

---

## Custom Types (ADTs)

When dealing with Custom Types, always use a `case` expression to handle all possible variants. This ensures completeness and type safety.

```elm
-- ✅ Correct
case model.page of
    HomePage ->
        renderHome model

    ArticlePage slug ->
        renderArticle slug model
```

---

## TEA Child Msg Interception

When a parent component needs to intercept or respond to specific messages from its child components, use the `updateAndCmd` pattern defined in `Package.Prelude`.

---

## File Structure and Splitting

### Elm Modules

Each page should follow a mirrored modular structure:

1.  `Type.elm` - Defines the page-specific `Model` and `Msg`.
2.  `Update.elm` - Defines the `init` and `update` logic.
3.  `View.elm` - Defines the view functions.

### Directory Naming

- **Folder names** must use **PascalCase** for modules (e.g., `src/Data/Route/`).
- **File names** must correspond to module names (e.g., `Parser.elm`).

---

## UI Styling Guidelines

The project mainly uses Tailwind CSS via square-bracket notation for explicit values.

-   **Do not** use margin classes. Use a parent element with padding or flex/grid gap instead.
-   **Prefer** explicit pixel values (`px`) using square brackets (e.g., `w-[304px]` instead of `w-76`).
-   **Do not** use `h-screen`, use `h-full` or `h-dvh`.
-   **Must** use mobile-first conventions:
    -   Define mobile styles first.
    -   Override for desktop using `lg:` prefix.
    -   Avoid `max-lg:` or any `max-` breakpoints.
-   **Use multi-line classes** for complex layouts using the `cn` helper from `Package.Prelude`.

Example:

```elm
div
    [ cn
        [ "flex flex-col gap-[24px]" -- shared
        , "lg:flex-row lg:gap-[48px]" -- desktop
        ]
    ]
    [ ... ]
```
