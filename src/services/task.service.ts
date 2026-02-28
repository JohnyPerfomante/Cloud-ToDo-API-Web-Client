import { taskRepository } from "../repositories/task.repository";

export const taskService = {
  async create(data: any) {
    return taskRepository.create(data);
  },

  async list(page: number, limit: number) {
    const skip = (page - 1) * limit;
    const [items, total] = await Promise.all([
      taskRepository.findAll(skip, limit),
      taskRepository.count()
    ]);
    return { items, total };
  },

  async get(id: string) {
    const task = await taskRepository.findById(id);
    if (!task) throw new Error("NOT_FOUND");
    return task;
  },

  async update(id: string, data: any) {
    return taskRepository.update(id, data);
  },

  async delete(id: string) {
    return taskRepository.delete(id);
  }
};