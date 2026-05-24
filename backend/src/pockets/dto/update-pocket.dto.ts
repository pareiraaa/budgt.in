import { PartialType } from "@nestjs/mapped-types";
import { CreatePocketDto } from "./create-pocket.dto";

export class UpdatePocketDto extends PartialType(CreatePocketDto) {}