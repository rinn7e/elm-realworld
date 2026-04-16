# Elm Code Conventions

## Table of Contents

- [Task Scope and Refactoring](#task-scope-and-refactoring)
- [Import Organization](#import-organization)
- [TEA Child Msg Interception](#tea-child-msg-interception)
- [File Structure and Splitting](#file-structure-and-splitting)
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

## TEA Child Msg Interception

When a parent component needs to intercept or respond to specific messages from its child components, use the `updateAndCmd` pattern defined in `Package.Prelude`. This keeps the child message handling clean and modular by avoiding nested `case` or `if` blocks for simple interception logic.

Example:

```elm
        ChildMsg subMsg ->
            Child.update subMsg model.childModel
                |> Tuple.mapBoth (\m -> { model | childModel = m }) (Cmd.map ChildMsg)
                |> updateAndCmd
                    (\m ->
                        case subMsg of
                            Child.Type.SpecificMsgToIntercept ->
                                ( { m | someParentField = True }, Cmd.none )

                            _ ->
                                ( m, Cmd.none )
                    )
```

---

## File Structure and Splitting

### Modular Pages

Each page should follow a mirrored modular structure:

1.  `Type.elm` - Defines the page-specific `Model` and `Msg`.
2.  `Update.elm` - Defines the `init` and `update` logic.
3.  `View.elm` - Defines the view functions.

### Shared Logic

- **Api**: Handlers and Types are separated into `src/Api/Handler/` and `src/Api/Type/`.
- **Component**: Reusable components go in `src/Component/` or `src/Component.elm`.

---

## UI Styling Guidelines

The project primarily uses Tailwind CSS via square-bracket notation for explicit values.

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
