import { prisma } from "../config/prisma";

export const taskRepository = {
  create: (data: any) => prisma.task.create({ data }),
  findAll: (skip: number, take: number) =>
    prisma.task.findMany({ skip, take, orderBy: { createdAt: "desc" } }),
  count: () => prisma.task.count(),
  findById: (id: string) => prisma.task.findUnique({ where: { id } }),
  update: (id: string, data: any) =>
    prisma.task.update({ where: { id }, data }),
  delete: (id: string) =>
    prisma.task.delete({ where: { id } })
};