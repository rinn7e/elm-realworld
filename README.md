# Elm RealWorld App 🌳✨

An implementation of the [RealWorld](https://github.com/gothinkster/realworld) spec (Medium clone) built using **Elm**, **Vite**, and **TailwindCSS** (with **DaisyUI**).

This project sets up a modern development environment with fast Hot Module Replacement (HMR) and strict compile-time safety.

---

## 🛠️ Prerequisites

Make sure you have [Node.js](https://nodejs.org/) installed on your machine.

---

## 🚀 Getting Started

Follow these simple steps to set up and run the project locally:

### 1. Install Dependencies
Run the following command in the project root directory. This will install all npm packages and automatically configure the correct Elm toolchain (`elm`, `elm-format`, `elm-json`, `elm-test-rs`) via `elm-tooling`:

```bash
npm install
```

### 2. Start the Development Server
Launch the local Vite server with active HMR:

```bash
npm run dev
```

Once started, open your browser and navigate to the local server URL (usually `http://localhost:5173`).

---

## 📋 Available Commands

Here are the commands you can run in this project:

| Command | Action |
| :--- | :--- |
| `npm run dev` | Starts the Vite development server with Hot Module Replacement (HMR). |
| `npm run build` | Builds the optimized production bundle into the `dist/` directory. |
| `npm run serve` | Previews the built production site locally. |
| `npm run lint` | Runs code quality checks on your Elm code using `elm-review`. |
| `npm run test` | Executes the test suite using `elm-test-rs`. |
| `npm run upgrade` | Upgrades Elm dependencies across the project and review directories. |

---

## 🎨 Technology Stack

* **Frontend:** [Elm](https://elm-lang.org/) (Purely functional, 0 runtime exceptions)
* **Build Tool:** [Vite](https://vitejs.dev/) with `vite-plugin-elm` for fast builds and reloads.
* **Styling:** [TailwindCSS](https://tailwindcss.com/) & [DaisyUI](https://daisyui.com/) for modern, responsive, and themeable UI components.
* **Tooling:** Managed by `elm-tooling` to ensure consistent compiler and formatting tools.