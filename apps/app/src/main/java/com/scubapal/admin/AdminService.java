package com.scubapal.admin;

import org.springframework.stereotype.Service;

import com.scubapal.dive.location.DiveLocationRepository;
import com.scubapal.dive.shop.DiveShopRepository;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.notification.NotificationRepository;
import com.scubapal.social.post.PostRepository;

@Service
public class AdminService {

    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final DiveLocationRepository diveLocationRepository;
    private final DiveShopRepository diveShopRepository;
    private final NotificationRepository notificationRepository;

    public AdminService(UserRepository userRepository,
                        PostRepository postRepository,
                        DiveLocationRepository diveLocationRepository,
                        DiveShopRepository diveShopRepository,
                        NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.postRepository = postRepository;
        this.diveLocationRepository = diveLocationRepository;
        this.diveShopRepository = diveShopRepository;
        this.notificationRepository = notificationRepository;
    }

    public AdminStatsView getStats() {
        return new AdminStatsView(
                userRepository.count(),
                postRepository.count(),
                diveLocationRepository.count(),
                diveShopRepository.count(),
                notificationRepository.count()
        );
    }
}
