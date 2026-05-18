import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { CreateCategoryDto } from './dto/createCategory.dto';
import { UpdateCategoryDto } from './dto/updateCategory.dto';

@Injectable()
export class CategoriesService {
    constructor(private prisma: PrismaService) {}

    //create category
    async createCategory(dto: CreateCategoryDto, userId: number) {
        const category = await this.prisma.category.create({
            data: {
                categoryName: dto.categoryName,
                type: dto.type,
                userId: userId,
            },
        });
        return {
            id: category.id,
            categoryName: category.categoryName,
            type: category.type,
        };
    }

    //get categories
    async getCategories(userId: number) {
        const categories = await this.prisma.category.findMany({
            where: {
                userId: userId,
            },
        });
        return categories.map((category) => ({
            id: category.id,
            categoryName: category.categoryName,
            type: category.type,
        }));
    }

    //get category by id
    async getCategoryById(id: number, userId: number) {
        const category = await this.validateCategory(id, userId);
        
        return {
            id: category.id,
            categoryName: category.categoryName,
            type: category.type,
        };
    }

    //update category
    async updateCategory(id: number, userId: number, dto: UpdateCategoryDto) {
        await this.validateCategory(id, userId);

        await this.prisma.category.update({
            where: {
                id: id,
            },
            data: {
                categoryName: dto.categoryName,
                type: dto.type,
            },
        });

        return {
            message: 'Category updated successfully',
        };
    }

    //delete category
    async deleteCategory(id: number, userId: number) {
        await this.validateCategory(id, userId);

        await this.prisma.category.delete({
            where: {
                id: id,
            },
        });

        return {
            message: 'Category deleted successfully',
        };
    }     
    
    //validation
    private async validateCategory(categoryId: number, userId: number) {
        const category = await this.prisma.category.findFirst({
            where: {
                id: categoryId,
                userId: userId,
            },
        });

        if (!category) {
            throw new NotFoundException('Category not found');
        }

        return {
            id: category.id,
            categoryName: category.categoryName,
            type: category.type,
        };
    }
}
