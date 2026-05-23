import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from 'src/prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import * as bcrypt from 'bcryptjs';
import { LoginDto } from './dto/login.dto';

@Injectable()
export class AuthService {
    constructor(private prisma: PrismaService, private jwt: JwtService) {}

    //register
    async register(registerDto: RegisterDto) {
        
        const existingUser = await this.prisma.user.findUnique({
            where: {
                email: registerDto.email,
            },
        });

        if (existingUser) {
            throw new ConflictException('User already exists');
        }

        const hashedPassword = await bcrypt.hash(registerDto.password, 10);

        const user = await this.prisma.user.create({
            data: {
                username: registerDto.username,
                email: registerDto.email,
                password: hashedPassword,
                currency: 'IDR',
            },
        });

        

        return {
            id: user.id,
            username: user.username,
            email: user.email,
            currency: user.currency,
        }
    }

    //login
    async login(loginDto: LoginDto) {
        const user = await this.prisma.user.findUnique({
            where: {
                email: loginDto.email,
            },
        });

        if (!user) {
            throw new UnauthorizedException('Invalid credentials');
        }

        const isPasswordValid = await bcrypt.compare(loginDto.password, user.password);

        if (!isPasswordValid) {
            throw new UnauthorizedException('Invalid credentials');
        }

        const jwt_token = await this.jwt.signAsync({ sub: user.id, username: user.username });

        return { 
            access_token: jwt_token 
        };
    }
}
