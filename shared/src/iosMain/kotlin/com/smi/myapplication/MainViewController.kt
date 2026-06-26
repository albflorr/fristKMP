package com.smi.myapplication

import androidx.compose.ui.window.ComposeUIViewController
import com.smi.myapplication.data.DatabaseDriverFactory
import com.smi.myapplication.data.PetRepository

fun MainViewController() = ComposeUIViewController {
    PetRepository.init(DatabaseDriverFactory())
    App()
}