import { Body, Controller, Get, Post, UseGuards, Request} from '@nestjs/common';
import { AuthService } from './auth.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './jwt-auth.guard';

@Controller('auth')
export class AuthController {
    constructor(private auth: AuthService) {}

    //register
    @Post('register')
    async register(@Body() registerDto: RegisterDto) {
        return this.auth.register(registerDto);
    }    

    //login
    @Post('login')
    async login(@Body() loginDto: LoginDto) {
        return this.auth.login(loginDto);
    }

    //profile
    @UseGuards(JwtAuthGuard)
    @Get('profile')
    async profile(@Request() req) {
        return {
            id: req.user.id,
            username: req.user.username,
            email: req.user.email,
            currency: req.user.currency,
            
        };
        // req.user;
    }
}
