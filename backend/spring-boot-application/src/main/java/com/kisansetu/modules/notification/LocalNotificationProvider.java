package com.kisansetu.modules.notification;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

@Service
public class LocalNotificationProvider implements NotificationService {

    private static final Logger log = LoggerFactory.getLogger(LocalNotificationProvider.class);
    private final List<Map<String, Object>> notificationHistory = new CopyOnWriteArrayList<>();

    @Override
    public void sendSms(String phone, String message) {
        log.info("[LOCAL NOTIFICATION PROVIDER - SMS] To: {} | Content: '{}'", phone, message);
        notificationHistory.add(Map.of(
                "type", "SMS",
                "recipient", phone,
                "message", message,
                "timestamp", Instant.now().toString()
        ));
    }

    @Override
    public void sendPushNotification(String userId, String title, String body) {
        log.info("[LOCAL NOTIFICATION PROVIDER - PUSH] User: {} | Title: '{}' | Body: '{}'", userId, title, body);
        notificationHistory.add(Map.of(
                "type", "PUSH",
                "recipient", userId,
                "title", title,
                "body", body,
                "timestamp", Instant.now().toString()
        ));
    }

    @Override
    public List<Map<String, Object>> getRecentNotifications() {
        List<Map<String, Object>> copy = new ArrayList<>(notificationHistory);
        Collections.reverse(copy);
        return copy.subList(0, Math.min(copy.size(), 50));
    }
}
