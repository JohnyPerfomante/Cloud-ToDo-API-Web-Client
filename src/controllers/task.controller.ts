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
