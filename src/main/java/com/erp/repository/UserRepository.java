package com.erp.repository;

import com.erp.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // Recherche par login (colonne 'login' dans la table utilisateurs)
    Optional<User> findByLogin(String login);
}
