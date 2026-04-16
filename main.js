import "@fontsource/chenla/index.css"
import "./src/assets/style.css";
import { Elm } from "./src/Main.elm";

const TOKEN_KEY = 'realworld_token';

if (process.env.NODE_ENV === "development") {
    const ElmDebugTransform = await import("elm-debug-transformer")
    ElmDebugTransform.register({
        simple_mode: true
    })
}

const root = document.querySelector("#app");
const token = localStorage.getItem(TOKEN_KEY);

const app = Elm.Main.init({
    node: root,
    flags: {
        token: token
    }
});


app.ports.saveToken.subscribe((token) => {
    localStorage.setItem(TOKEN_KEY, token);
});

app.ports.removeToken.subscribe(() => {
    localStorage.removeItem(TOKEN_KEY);
});
