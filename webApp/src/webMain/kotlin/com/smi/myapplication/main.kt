package com.smi.myapplication

import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.ComposeViewport
import com.smi.myapplication.data.DatabaseDriverFactory
import com.smi.myapplication.data.PetRepository

@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    PetRepository.init(DatabaseDriverFactory())

    ComposeViewport {
        App()
    }
}