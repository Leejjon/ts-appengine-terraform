import express, {Application} from 'express';
import { createRequestHandler } from "@remix-run/express";

import {type ServerBuild} from "@remix-run/server-runtime";
import path from "node:path";
import fs from "node:fs";
import url from "node:url";

const app: Application = express();
const port = process.env.PORT || 8080;

// http://expressjs.com/en/advanced/best-practice-security.html#at-a-minimum-disable-x-powered-by-header
app.disable("x-powered-by");

const BUILD_PATH = path.resolve("./build/index.js");
const VERSION_PATH = path.resolve("./build/version.txt");

// Remix fingerprints its assets so we can cache forever.
app.use(
    "/build",
    express.static("public/build", { immutable: true, maxAge: "1y" })
);

// Everything else (like favicon.ico) is cached for an hour. You may want to be
// more aggressive with this caching.
app.use(express.static("public", { maxAge: "1h" }));

const initialBuild: ServerBuild = await reimportServer();

app.all("*", createRequestHandler({
    build: initialBuild,
    mode: initialBuild.mode,
}));

app.listen(port, function () {
    console.log(`App is listening on port ${port} !`);
});

/**
 * @returns {Promise<ServerBuild>}
 */
async function reimportServer() {
    const stat = fs.statSync(BUILD_PATH);

    // convert build path to URL for Windows compatibility with dynamic `import`
    const BUILD_URL = url.pathToFileURL(BUILD_PATH).href;

    // use a timestamp query parameter to bust the import cache
    return import(BUILD_URL + "?t=" + stat.mtimeMs);
}
