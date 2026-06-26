package com.smi.myapplication

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import cafe.adriel.voyager.navigator.Navigator
import cafe.adriel.voyager.transitions.SlideTransition

@Composable
fun App() {
    MaterialTheme {
        Navigator(screen = MainScreen()) { navigator ->
            SlideTransition(navigator)
        }
    }
}