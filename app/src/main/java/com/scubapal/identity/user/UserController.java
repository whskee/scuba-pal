package com.scubapal.identity.user;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.scubapal.identity.auth.RegisterRequest;
import com.scubapal.shared.MessageResponse;

import java.util.List;

@Tag(name = "User Management", description = "Endpoints for managing user accounts")
@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    public ResponseEntity<UserView> create(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.register(request));
    }

    @GetMapping
    public List<UserView> getAll() {
        return userService.getAllUsers();
    }

    @GetMapping("/{id}")
    public UserView getById(@PathVariable Long id) {
        return userService.getUser(id);
    }

    @PutMapping("/{id}")
    public UserView update(@PathVariable Long id, @Valid @RequestBody RegisterRequest request) {
        return userService.updateUser(id, request);
    }

    @DeleteMapping("/{id}")
    public MessageResponse delete(@PathVariable Long id) {
        userService.deleteUser(id);
        return new MessageResponse("User deactivated");
    }
}
