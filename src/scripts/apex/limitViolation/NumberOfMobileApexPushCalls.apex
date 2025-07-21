for (Integer i = 0; i < 11; i++) {
    Messaging.PushNotification mPushNotification = new Messaging.PushNotification();
    Map<String, Object> androidPayload = new Map<String, Object>();
    mPushNotification.setPayload(androidPayload);
    mPushNotification.send('Test', new Set<String>());
}
