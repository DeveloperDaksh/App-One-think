package com.justonething.data

import androidx.room.Entity
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "blocked_apps")
data class BlockedApp(
    @PrimaryKey val bundleId: String,
    val displayName: String,
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "usage_events")
data class UsageEvent(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val timestamp: Long = System.currentTimeMillis(),
    val appBundleId: String,
    val outcome: String, // SUCCESS or CHOICE
    val intent: String? = null
)
