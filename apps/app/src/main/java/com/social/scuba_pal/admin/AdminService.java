package com.social.scuba_pal.admin;

import com.social.scuba_pal.dive.location.DiveLocationRepository;
import com.social.scuba_pal.dive.shop.DiveShopRepository;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.notification.NotificationRepository;
import com.social.scuba_pal.social.post.PostRepository;

import org.springframework.stereotype.Service;

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
