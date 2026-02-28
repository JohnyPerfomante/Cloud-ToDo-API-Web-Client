import express from "express";
import cors from "cors";
import { taskController } from "./controllers/task.controller";
import { errorHandler } from "./middlewares/errorHandler";

export const app = express();
app.use(cors());
app.use(express.json());

app.get("/health", (_, res) => res.json({ status: "ok" }));

app.post("/api/tasks", taskController.create);
app.get("/api/tasks", taskController.list);
app.get("/api/tasks/:id", taskController.get);
app.patch("/api/tasks/:id", taskController.patch);
app.delete("/api/tasks/:id", taskController.delete);

app.use(errorHandler);
