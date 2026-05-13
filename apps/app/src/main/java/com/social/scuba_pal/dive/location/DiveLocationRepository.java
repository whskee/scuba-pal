package com.social.scuba_pal.dive.location;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DiveLocationRepository extends JpaRepository<DiveLocation, Long> {
    List<DiveLocation> findByCityIgnoreCaseOrderByPopularityScoreDesc(String city);
    Page<DiveLocation> findByCityIgnoreCaseOrderByPopularityScoreDesc(String city, Pageable pageable);
}
