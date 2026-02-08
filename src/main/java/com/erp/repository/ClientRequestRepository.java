package com.erp.repository;

import com.erp.domain.ClientRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ClientRequestRepository extends JpaRepository<ClientRequest, Long> {
    List<ClientRequest> findByCustomerIdOrderByDateCreationDesc(Long customerId);

    List<ClientRequest> findByRequestTypeInOrderByDateCreationDesc(List<String> types);
}
