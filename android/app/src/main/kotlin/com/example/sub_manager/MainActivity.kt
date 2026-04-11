package com.example.sub_manager

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.sub_manager/usage"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "getUsageStats" -> {
                    if (!hasUsageStatsPermission()) {
                        result.error("PERMISSION_DENIED", "Usage stats permission not granted", null)
                        return@setMethodCallHandler
                    }
                    val stats = getUsageStats()
                    result.success(stats)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getUsageStats(): Map<String, Long> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val currentTime = System.currentTimeMillis()
        
        val cal = Calendar.getInstance()
        cal.add(Calendar.DAY_OF_YEAR, -30) // Last 30 days
        val startTime = cal.timeInMillis

        // 1. Get historical data using queryUsageStats
        val queryUsageStats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            currentTime
        )
        
        val statsMap = mutableMapOf<String, Long>()
        
        // Find the start of today to split historical vs real-time tracking
        val todayCal = Calendar.getInstance()
        todayCal.set(Calendar.HOUR_OF_DAY, 0)
        todayCal.set(Calendar.MINUTE, 0)
        todayCal.set(Calendar.SECOND, 0)
        todayCal.set(Calendar.MILLISECOND, 0)
        val startOfToday = todayCal.timeInMillis

        for (usageStats in queryUsageStats) {
            // Only add historical data (buckets starting before today)
            // Today's bucket might be delayed/incomplete, so we calculate it manually below.
            if (usageStats.firstTimeStamp < startOfToday) {
                val totalTime = usageStats.totalTimeInForeground
                if (totalTime > 0) {
                    statsMap[usageStats.packageName] = (statsMap[usageStats.packageName] ?: 0L) + totalTime
                }
            }
        }

        // 2. Add real-time data for TODAY using queryEvents
        val events = usageStatsManager.queryEvents(startOfToday, currentTime)
        val startTimes = mutableMapOf<String, Long>()
        val event = android.app.usage.UsageEvents.Event()

        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            val packageName = event.packageName
            val timestamp = event.timeStamp
            
            // ACTIVITY_RESUMED = 1, ACTIVITY_PAUSED = 2
            if (event.eventType == android.app.usage.UsageEvents.Event.ACTIVITY_RESUMED) {
                startTimes[packageName] = timestamp
            } else if (event.eventType == android.app.usage.UsageEvents.Event.ACTIVITY_PAUSED) {
                // If we see a pause without a start, assume it started at the beginning of the query window
                val start = startTimes[packageName] ?: startOfToday
                val duration = timestamp - start
                if (duration > 0) {
                    statsMap[packageName] = (statsMap[packageName] ?: 0L) + duration
                }
                startTimes.remove(packageName)
            }
        }

        // Add the in-progress time for apps that are currently resumed (in the foreground)
        for ((packageName, start) in startTimes) {
            val duration = currentTime - start
            if (duration > 0) {
                statsMap[packageName] = (statsMap[packageName] ?: 0L) + duration
            }
        }

        return statsMap
    }
}
