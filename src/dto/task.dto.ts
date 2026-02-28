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
