package com.erp.security;

import com.erp.domain.User;
import com.erp.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.stream.Collectors;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String login) throws UsernameNotFoundException {
        // Recherche par login (colonne 'login' dans la table utilisateurs)
        User user = userRepository.findByLogin(login)
            .orElseThrow(() -> new UsernameNotFoundException("Utilisateur non trouvé: " + login));

        // Vérification si l'utilisateur est actif
        if (user.getActive() == null || !user.getActive()) {
            throw new UsernameNotFoundException("Utilisateur désactivé: " + login);
        }

        return new org.springframework.security.core.userdetails.User(
            user.getLogin(),
            user.getPassword(),
            getAuthorities(user)
        );
    }

    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            return java.util.Collections.emptyList();
        }
        return user.getRoles().stream()
            .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getCode()))
            .collect(Collectors.toList());
    }
}
