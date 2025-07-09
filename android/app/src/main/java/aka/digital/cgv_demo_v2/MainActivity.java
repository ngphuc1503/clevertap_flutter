package aka.digital.cgv_demo_v2;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;
import android.location.Location;

import com.clevertap.android.sdk.CleverTapAPI;
import com.clevertap.android.sdk.InAppNotificationButtonListener;
import com.clevertap.android.sdk.InAppNotificationListener;
import com.clevertap.android.geofence.CTGeofenceAPI;
import com.clevertap.android.geofence.interfaces.CTGeofenceEventsListener;
import com.clevertap.android.geofence.interfaces.CTLocationUpdatesListener;
import com.clevertap.android.geofence.CTGeofenceSettings;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import org.json.JSONObject;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "deeplink_channel";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        CleverTapAPI cleverTapAPI = CleverTapAPI.getDefaultInstance(getApplicationContext());
        if (cleverTapAPI != null) {
            Log.d("[CleverTap]", "CleverTap instance initialized");

            CTGeofenceSettings ctGeofenceSettings = new CTGeofenceSettings.Builder()
                    .enableBackgroundLocationUpdates(true)
                    .setLogLevel(3)  // Verbose
                    .setLocationAccuracy((byte) 1)  // HIGH
                    .setLocationFetchMode((byte) 1) // CONTINUOUS
                    .setGeofenceMonitoringCount(20)
                    .setInterval(60 * 60 * 1000) // 1 giờ
                    .setFastestInterval(30 * 60 * 1000) // 30 phút
                    .setSmallestDisplacement(200.0f) // 200 mét
                    .setGeofenceNotificationResponsiveness(30000) // 30 giây
                    .build();

            CTGeofenceAPI.getInstance(getApplicationContext()).init(ctGeofenceSettings, cleverTapAPI);

            CTGeofenceAPI.getInstance(getApplicationContext())
                    .setOnGeofenceApiInitializedListener(() -> {
                        Log.d("[Geofence]", "CTGeofenceAPI initialized ✅");
                    });

            CTGeofenceAPI.getInstance(getApplicationContext())
                    .setCtGeofenceEventsListener(new CTGeofenceEventsListener() {
                        @Override
                        public void onGeofenceEnteredEvent(JSONObject jsonObject) {
                            Log.d("[Geofence]", "📍 Entered: " + jsonObject.toString());
                        }

                        @Override
                        public void onGeofenceExitedEvent(JSONObject jsonObject) {
                            Log.d("[Geofence]", "📍 Exited: " + jsonObject.toString());
                        }
                    });

            CTGeofenceAPI.getInstance(getApplicationContext())
                    .setCtLocationUpdatesListener(new CTLocationUpdatesListener() {
                        @Override
                        public void onLocationUpdates(Location location) {
                            Log.d("[Geofence]", "📡 Location update: " + location.getLatitude() + ", " + location.getLongitude());
                        }
                    });

            try {
                CTGeofenceAPI.getInstance(getApplicationContext()).triggerLocation();
            } catch (IllegalStateException e) {
                Log.e("[Geofence]", "Geofence SDK chưa được init đúng cách ❌", e);
            }
        }
    }


    @Override
    public void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);

        if (intent.getExtras() != null) {
            CleverTapAPI.getDefaultInstance(this).pushNotificationClickedEvent(intent.getExtras());

            String deeplink = intent.getExtras().getString("wzrk_dl");
            if (deeplink != null) {
                Log.d("[Deeplink]", "Received wzrk_dl: " + deeplink);

                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
                        .invokeMethod("onDeeplinkReceived", deeplink);
            }
        }
        setIntent(intent);
    }

    private void createCustomNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            String channelId = "Custom_Channel";
            String channelName = "Custom_Channel";
            String channelDescription = "Custom_Channel";

            Uri soundUri = Uri.parse("android.resource://" + getPackageName() + "/raw/lmao");

            AudioAttributes audioAttributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build();

            NotificationChannel channel = new NotificationChannel(
                    channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_HIGH
            );
            channel.setDescription(channelDescription);
            channel.enableLights(true);
            channel.enableVibration(true);
            channel.setSound(soundUri, audioAttributes);

            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
                Log.d("[NotificationChannel]", "Custom_Channel with sound created");
            }
        }
    }
}

