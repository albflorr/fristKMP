package com.smi.myapplication.data

import app.cash.sqldelight.db.SqlDriver
import app.cash.sqldelight.driver.wasm.WasmSqliteDriver

actual class DatabaseDriverFactory {
    actual fun createDriver(): SqlDriver {
        return WasmSqliteDriver("pet_database.db")
    }
}
