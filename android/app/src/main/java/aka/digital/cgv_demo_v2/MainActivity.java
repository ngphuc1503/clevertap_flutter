package aka.digital.cgv_demo_v2;

import android.content.Intent;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import com.clevertap.android.sdk.CleverTapAPI;
import android.util.Log;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    @Override
    public void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);

        if (intent.getExtras() != null) {
            CleverTapAPI.getDefaultInstance(this).pushNotificationClickedEvent(intent.getExtras());
        
            String deeplink = intent.getExtras().getString("wzrk_dl");
            if (deeplink != null) {
                Log.d("[Deeplink]", "Received wzrk_dl: " + deeplink);

                new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "deeplink_channel")
                    .invokeMethod("onDeeplinkReceived", deeplink);
            }
        }

        setIntent(intent);
    }
}
