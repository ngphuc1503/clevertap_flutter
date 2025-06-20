package aka.digital.cgv_demo_v2;

import io.flutter.app.FlutterApplication;
import com.clevertap.android.sdk.ActivityLifecycleCallback;
import com.clevertap.android.sdk.CleverTapAPI;

public class MyApplication extends FlutterApplication {

    @Override
    public void onCreate() {
        // Đăng ký CleverTap lifecycle callback
        ActivityLifecycleCallback.register(this);

        super.onCreate();
    }
}
