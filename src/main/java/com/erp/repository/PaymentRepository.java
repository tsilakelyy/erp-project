package com.erp.repository;

import com.erp.domain.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByFactureIdIn(List<Long> factureIds);
    Optional<Payment> findByNumero(String numero);
}
