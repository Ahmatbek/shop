package kg.shop.controller;

import jakarta.validation.Valid;
import kg.shop.dto.Dtos.AuthResponse;
import kg.shop.dto.Dtos.LoginRequest;
import kg.shop.dto.Dtos.RegisterRequest;
import kg.shop.entity.AppUser;
import kg.shop.repo.UserRepository;
import kg.shop.security.JwtService;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final JwtService jwt;

    public AuthController(UserRepository users, PasswordEncoder encoder, JwtService jwt) {
        this.users = users;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    @PostMapping("/register")
    public AuthResponse register(@Valid @RequestBody RegisterRequest req) {
        String email = req.email().trim().toLowerCase();
        if (users.existsByEmail(email)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Пользователь с таким email уже существует");
        }
        AppUser user = users.save(new AppUser(req.name().trim(), email, encoder.encode(req.password())));
        return new AuthResponse(jwt.generateToken(user.getEmail()), user.getName(), user.getEmail());
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest req) {
        String email = req.email().trim().toLowerCase();
        AppUser user = users.findByEmail(email)
                .filter(u -> encoder.matches(req.password(), u.getPasswordHash()))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Неверный email или пароль"));
        return new AuthResponse(jwt.generateToken(user.getEmail()), user.getName(), user.getEmail());
    }
}
