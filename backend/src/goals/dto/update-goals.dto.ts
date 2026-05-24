import { PartialType } from "@nestjs/mapped-types";
import { CreateGoalDto } from "./create-goals.dto";

export class UpdateGoalDto extends PartialType(CreateGoalDto) {}