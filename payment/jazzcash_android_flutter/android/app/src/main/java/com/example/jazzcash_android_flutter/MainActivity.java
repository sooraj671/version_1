package com.example.jazzcash_android_flutter;

import io.flutter.embedding.android.FlutterActivity;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends FlutterActivity {
  

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        TextView price = (TextView)findViewById(R.id.priceTextView);
        Button payment_button = (Button)findViewById(R.id.payment_button);

        payment_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(MainActivity.this, PaymentActivity.class);
                //startActivity(new Intent(MainActivity.this, PaymentActivity.class));
                i.putExtra("price", price.getText().toString());

                startActivityForResult(i, 0);
                //startActivity(i);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // Check that it is the SecondActivity with an OK result
        if (requestCode == 0 && resultCode == RESULT_OK) {
            // Get String data from Intent
            String ResponseCode = data.getStringExtra("pp_ResponseCode");
            System.out.println("DateFn: ResponseCode:" + ResponseCode);
            if(ResponseCode.equals("000")) {
                Toast.makeText(getApplicationContext(), "Payment Success", Toast.LENGTH_SHORT).show();
            }
            else
            {
                Toast.makeText(getApplicationContext(), "Payment Failed", Toast.LENGTH_SHORT).show();
            }
        }
    }
}