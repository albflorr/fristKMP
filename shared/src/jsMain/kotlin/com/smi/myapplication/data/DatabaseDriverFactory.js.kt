package com.smi.myapplication.data

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.js.JsSqliteDriver

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        return JsSqliteDriver("pet_database.db", onInit = { PetDatabase.Schema.create(it) })
    }
}
