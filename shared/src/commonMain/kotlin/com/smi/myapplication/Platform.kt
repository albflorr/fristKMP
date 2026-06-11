package com.smi.myapplication

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform