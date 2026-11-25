package com.kisansetu.modules.notification;

import java.util.List;
import java.util.Map;

public interface NotificationService {
    void sendSms(String phone, String message);
    void sendPushNotification(String userId, String title, String body);
    List<Map<String, Object>> getRecentNotifications();
}
