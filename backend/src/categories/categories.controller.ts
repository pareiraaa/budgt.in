import { Body, Controller, Delete, Get, Param, Post, Put, Request, UseGuards} from '@nestjs/common';
import { CategoriesService } from './categories.service';
import { CreateCategoryDto } from './dto/createCategory.dto';
import { JwtAuthGuard } from 'src/auth/jwt-auth.guard';
import { UpdateCategoryDto } from './dto/updateCategory.dto';

@UseGuards(JwtAuthGuard)
@Controller('categories')
export class CategoriesController {
    constructor(private categoriesService: CategoriesService) {}

    //create category
    @Post()
    async createCategory(@Body() dto: CreateCategoryDto, @Request() req) {
        return this.categoriesService.createCategory(dto, req.user.id);
    }   

    //get all categories
    @Get()
    async getAllCategories(@Request() req) {
        return this.categoriesService.getCategories(req.user.id);
    }

    //get category by id
    @Get(':id')
    async getCategoryById(@Param('id') id: string, @Request() req) {
        return this.categoriesService.getCategoryById(+id, req.user.id);
    }

    //update category
    @Put(':id')
    async updateCategory(@Param('id') id: string, @Request() req, @Body() dto: UpdateCategoryDto) {
        return this.categoriesService.updateCategory(+id, req.user.id, dto);
    }

    //delete category
    @Delete(':id')
    async deleteCategory(@Param('id') id: string, @Request() req) {
        return this.categoriesService.deleteCategory(+id, req.user.id);  
    }   
}
