package com.justonething.service

import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.PointerEventType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

class OverlayActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // WindowManager flags to make it an overlay
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        
        setContent {
            MindfulOverlayScreen(onSuccess = { finish() }, onChoice = { finish() })
        }
    }

    override fun onBackPressed() {
        // Prevent dismissal by back button
    }
}

enum class InterventionState {
    BREATHING,
    STEADY_HAND,
    JOURNALING,
    INTENT
}

@Composable
fun MindfulOverlayScreen(onSuccess: () -> Unit, onChoice: () -> Unit) {
    var state by remember { mutableStateOf<InterventionState>(InterventionState.BREATHING) }
    var breathCount by remember { mutableStateOf(0) }
    var holdProgress by remember { mutableStateOf(0f) }

    when(state) {
        InterventionState.BREATHING -> {
            BreathingScreen {
                breathCount++
                if (breathCount >= 2) state = InterventionState.STEADY_HAND
            }
        }
        InterventionState.STEADY_HAND -> {
            SteadyHandChallenge {
                state = InterventionState.JOURNALING
            }
        }
        InterventionState.JOURNALING -> {
            JournalPromptScreen { response ->
                state = InterventionState.INTENT
            }
        }
        InterventionState.INTENT -> {
            IntentSelectionScreen(onComplete = onChoice)
        }
    }
}

@Composable
fun BreathingScreen(onComplete: () -> Unit) {
    var isExpanded by remember { mutableStateOf(false) }
    var breathCount by remember { mutableStateOf(2) }
    var instruction by remember { mutableStateOf("Breathe in...") }

    val scale by animateFloatAsState(
        targetValue = if (isExpanded) 1.5f else 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 3000, easing = LinearOutSlowInEasing),
            repeatMode = RepeatMode.Reverse
        ),
        label = "BreatheScale"
    )

    LaunchedEffect(Unit) {
        isExpanded = true
        while (breathCount > 0) {
            delay(3000)
            instruction = "Breathe out..."
            delay(3000)
            breathCount--
            if (breathCount > 0) instruction = "Breathe in..."
        }
        onComplete()
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Just One Breath", style = MaterialTheme.typography.displaySmall)
        Spacer(modifier = Modifier.height(64.dp))
        
        Box(
            modifier = Modifier
                .size(150.dp)
                .graphicsLayer(scaleX = scale, scaleY = scale, alpha = 0.5f)
                .background(MaterialTheme.colorScheme.primary, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text("$breathCount", style = MaterialTheme.typography.headlineLarge, color = androidx.compose.ui.graphics.Color.White)
        }
        
        Spacer(modifier = Modifier.height(64.dp))
        Text(instruction, style = MaterialTheme.typography.headlineMedium, color = MaterialTheme.colorScheme.primary)
    }
}

@Composable
fun SteadyHandChallenge(onComplete: () -> Unit) {
    // In a real device, we would use SensorManager. 
    // For the v3.0 target, we implement the UI and a 'hold' logic as a fallback for emulators.
    var progress by remember { mutableStateOf(0f) }
    var isHolding by remember { mutableStateOf(false) }

    LaunchedEffect(isHolding) {
        if (isHolding) {
            while (progress < 1f) {
                delay(50)
                progress += 0.02f
            }
            onComplete()
        } else {
            progress = 0f
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Steady Hand", style = MaterialTheme.typography.headlineMedium)
        Text("Hold the button to break the autopilot.", style = MaterialTheme.typography.bodyLarge)
        
        Spacer(modifier = Modifier.height(48.dp))
        
        LinearProgressIndicator(
            progress = progress,
            modifier = Modifier.fillMaxWidth().height(8.dp).clip(CircleShape)
        )
        
        Spacer(modifier = Modifier.height(48.dp))
        
        Button(
            onClick = { },
            modifier = Modifier
                .fillMaxWidth()
                .height(80.dp)
                .pointerInput(Unit) {
                    awaitPointerEventScope {
                        while (true) {
                            val event = awaitPointerEvent()
                            isHolding = event.type == PointerEventType.Press || event.type == PointerEventType.Move
                            if (event.type == PointerEventType.Release) isHolding = false
                        }
                    }
                },
            shape = RoundedCornerShape(24.dp)
        ) {
            Text(if (isHolding) "Focusing..." else "Hold to Continue")
        }
    }
}

@Composable
fun JournalPromptScreen(onComplete: (String) -> Unit) {
    var text by remember { mutableStateOf("") }
    val isReady = text.length >= 10

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Mindful Intent", style = MaterialTheme.typography.headlineMedium)
        Text("What are you hoping to find?", style = MaterialTheme.typography.bodyLarge)
        
        Spacer(modifier = Modifier.height(32.dp))
        
        OutlinedTextField(
            value = text,
            onValueChange = { text = it },
            modifier = Modifier.fillMaxWidth().height(150.dp),
            placeholder = { Text("Describe your intent...") },
            shape = RoundedCornerShape(16.dp)
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Button(
            onClick = { onComplete(text) },
            enabled = isReady,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(if (isReady) "Commit & Open" else "Keep writing... (${10 - text.length} more chars)")
        }
    }
}

@Composable
fun IntentSelectionScreen(onComplete: () -> Unit) {
    val intents = listOf("Bored", "Work", "Habit", "Stress")
    var selectedIntent by remember { mutableStateOf<String?>(null) }

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Select Category", style = MaterialTheme.typography.headlineSmall)
        Spacer(modifier = Modifier.height(24.dp))
        
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            intents.chunked(2).forEach { row ->
                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    row.forEach { intent ->
                        OutlinedButton(
                            onClick = { selectedIntent = intent },
                            modifier = Modifier.weight(1f),
                            border = if (selectedIntent == intent) ButtonDefaults.outlinedButtonBorder.copy(width = 2.dp) else null,
                            colors = if (selectedIntent == intent) ButtonDefaults.outlinedButtonColors(containerColor = MaterialTheme.colorScheme.primaryContainer) else ButtonDefaults.outlinedButtonColors()
                        ) {
                            Text(intent)
                        }
                    }
                }
            }
        }
        
        Spacer(modifier = Modifier.height(48.dp))
        
        Button(
            onClick = onComplete,
            enabled = selectedIntent != null,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Finish")
        }
    }
}
