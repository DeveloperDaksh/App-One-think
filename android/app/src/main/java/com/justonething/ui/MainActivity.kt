package com.justonething.ui

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            JustOneThingTheme {
                MainDashboard()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainDashboard() {
    Scaffold(
        topBar = {
            CenterAlignedTopAppBar(
                title = { Text("Just One Thing") }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).padding(16.dp)) {
            // Stats Section
            Card(modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Impulse Control Rate", style = MaterialTheme.typography.labelSmall)
                    Text("85%", style = MaterialTheme.typography.displayMedium)
                }
            }
            
            Spacer(modifier = Modifier.height(24.dp))
            
            Text("Blocked Apps", style = MaterialTheme.typography.titleMedium)
            // App selection list would go here
            Button(onClick = { /* Launch App Picker */ }, modifier = Modifier.fillMaxWidth()) {
                Text("Select Apps")
            }
        }
    }
}

@Composable
fun JustOneThingTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = androidx.compose.ui.graphics.Color(0xFF569E69),
            secondary = androidx.compose.ui.graphics.Color(0xFF8BAE90)
        ),
        content = content
    )
}
