'use strict';

import express, {Request, Response} from "express";
import {Datastore} from "@google-cloud/datastore";

const app = express();
const router = express.Router();

router.post("/create", async (req: Request, res: Response) => {
    res.contentType('application/json');
    try {
        const datastore = new Datastore();

        res.status(200);
        res.send({});
    } catch (error) {
        res.status(200);
        res.send({message: error.toString()});
    }
});

router.get("/query", async (req: Request, res: Response) => {
    res.contentType('application/json');
    res.status(200);
    res.send({});
});

app.use(router);

// Start the server
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
    console.log(`App listening on port ${PORT}`);
    console.log('Press Ctrl+C to quit.');
});
