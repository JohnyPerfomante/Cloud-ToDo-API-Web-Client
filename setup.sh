#!/bin/bash

mkdir -p src/{config,controllers,services,repositories,dto,middlewares,utils}
mkdir -p prisma
mkdir -p frontend
mkdir -p .github/workflows
mkdir -p tests

cat > package.json << 'PKG'
{
  "name": "cloud-todo-mvp",
  "version": "1.0.0",
  "scripts": {
    "dev": "ts-node-dev --respawn src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "test": "jest",
    "migrate": "prisma migrate dev",
    "generate": "prisma generate"
  },
  "dependencies": {
    "@prisma/client": "^5.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.4.0",
    "express": "^4.18.2",
    "uuid": "^9.0.0",
    "zod": "^3.22.4"
  },
  "devDependencies": {
    "@types/express": "^4.17.17",
    "@types/node": "^20.0.0",
    "jest": "^29.7.0",
    "prisma": "^5.0.0",
    "ts-jest": "^29.1.1",
    "ts-node-dev": "^2.0.0",
    "typescript": "^5.4.0"
  }
}
PKG

cat > tsconfig.json << 'TS'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "outDir": "dist",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true
  }
}
TS

cat > prisma/schema.prisma << 'PRISMA'
generator client {
  provider = "prisma-client-js"
}
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
enum Status { NEW IN_PROGRESS DONE }
enum Priority { LOW MEDIUM HIGH }
model Task {
  id        String   @id @default(uuid())
  title     String
  description String?
  status    Status   @default(NEW)
  priority  Priority @default(MEDIUM)
  dueDate   DateTime?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  @@index([status])
  @@index([priority])
}
PRISMA

cat > src/app.ts << 'APP'
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
APP

cat > src/server.ts << 'SERVER'
import { app } from "./app";
app.listen(3000, () => console.log("Server started on port 3000"));
SERVER

cat > src/middlewares/errorHandler.ts << 'ERR'
import { Request, Response, NextFunction } from "express";
import { ZodError } from "zod";

export function errorHandler(err: any, _: Request, res: Response, __: NextFunction) {
  if (err instanceof ZodError) {
    return res.status(400).json({
      code: "VALIDATION_ERROR",
      message: "Validation failed",
      details: err.errors
    });
  }
  return res.status(500).json({
    code: "INTERNAL_ERROR",
    message: "Unexpected error",
    details: []
  });
}
ERR

cat > src/dto/task.dto.ts << 'DTO'
import { z } from "zod";
export const createTaskSchema = z.object({
  title: z.string().min(3).max(120),
  description: z.string().max(500).optional(),
  priority: z.enum(["LOW","MEDIUM","HIGH"]).optional(),
  dueDate: z.string().datetime().optional()
});
export const patchTaskSchema = z.object({
  status: z.enum(["NEW","IN_PROGRESS","DONE"]).optional(),
  priority: z.enum(["LOW","MEDIUM","HIGH"]).optional()
});
DTO

cat > src/controllers/task.controller.ts << 'CTRL'
import { Request, Response } from "express";
import { createTaskSchema, patchTaskSchema } from "../dto/task.dto";
let tasks: any[] = [];

export const taskController = {
  create(req: Request, res: Response) {
    const dto = createTaskSchema.parse(req.body);
    const task = { id: Date.now().toString(), ...dto, status: "NEW" };
    tasks.push(task);
    res.status(201).json(task);
  },
  list(_: Request, res: Response) {
    res.json({ items: tasks, total: tasks.length, limit: 10, offset: 0 });
  },
  get(req: Request, res: Response) {
    const task = tasks.find(t => t.id === req.params.id);
    if (!task) return res.status(404).json({ code:"NOT_FOUND",message:"Not found",details:[] });
    res.json(task);
  },
  patch(req: Request, res: Response) {
    const dto = patchTaskSchema.parse(req.body);
    const task = tasks.find(t => t.id === req.params.id);
    if (!task) return res.status(404).json({ code:"NOT_FOUND",message:"Not found",details:[] });
    Object.assign(task, dto);
    res.json(task);
  },
  delete(req: Request, res: Response) {
    tasks = tasks.filter(t => t.id !== req.params.id);
    res.status(204).send();
  }
};
CTRL

cat > Dockerfile << 'DOCKER'
FROM node:20-alpine
WORKDIR /app
COPY package*.json .
RUN npm install
COPY . .
CMD ["npm","run","dev"]
DOCKER

cat > docker-compose.yml << 'YML'
version: "3.9"
services:
  api:
    build: .
    ports:
      - "3000:3000"
YML

chmod +x setup.sh
