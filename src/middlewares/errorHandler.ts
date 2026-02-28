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
