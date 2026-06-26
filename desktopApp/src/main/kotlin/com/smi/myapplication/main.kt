package com.smi.myapplication

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import com.smi.myapplication.data.DatabaseDriverFactory
import com.smi.myapplication.data.PetRepository

fun main() = application {
    PetRepository.init(DatabaseDriverFactory())

    Window(
        onCloseRequest = ::exitApplication,
        title = "Mis Mascotas",
    ) {
        App()
    }
}