package com.example.investment.user;

import java.util.List;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserService {

    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public List<User> findAll() {
        return repository.findAll();
    }

    public User findById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }

    public User create(UserRequest request) {
        ensureEmailAvailable(request.email(), null);
        User user = new User();
        apply(user, request);
        return save(user);
    }

    public User update(Long id, UserRequest request) {
        User user = findById(id);
        ensureEmailAvailable(request.email(), id);
        apply(user, request);
        return save(user);
    }

    public void delete(Long id) {
        User user = findById(id);
        repository.delete(user);
    }

    private void apply(User user, UserRequest request) {
        user.setName(request.name().trim());
        user.setEmail(request.email().trim().toLowerCase());
    }

    private void ensureEmailAvailable(String email, Long currentId) {
        String normalizedEmail = email.trim();
        boolean emailExists = currentId == null
                ? repository.existsByEmailIgnoreCase(normalizedEmail)
                : repository.existsByEmailIgnoreCaseAndIdNot(normalizedEmail, currentId);
        if (emailExists) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already in use");
        }
    }

    private User save(User user) {
        try {
            return repository.save(user);
        } catch (DataIntegrityViolationException exception) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Email is already in use", exception);
        }
    }
}