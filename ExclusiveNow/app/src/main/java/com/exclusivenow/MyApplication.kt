package com.exclusivenow

import android.app.Application

class MyApplication : Application() {

    override fun onCreate() {
        super.onCreate()

        // OneSignal Initialization
        //OneSignal.initWithContext(this)
        //OneSignal.setAppId("1571d09d-037e-47f7-bae9-8cc58852e4e6")
    }
}