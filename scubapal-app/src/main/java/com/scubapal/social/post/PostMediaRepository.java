package com.scubapal.social.post;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostMediaRepository extends JpaRepository<PostMedia, Long> {
    List<PostMedia> findByPostIdOrderByDisplayOrderAscIdAsc(Long postId);
}
