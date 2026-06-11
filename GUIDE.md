# Guía de cambios — Navegación Voyager en Compose Multiplatform

Esta guía documenta paso a paso todos los cambios realizados para agregar navegación con **Voyager** al proyecto **MyApplication** (Kotlin Multiplatform + Compose).

---

## Paso 1: Agregar la versión de Voyager en `gradle/libs.versions.toml`

**Archivo:** `gradle/libs.versions.toml`

En la sección `[versions]`:

```toml
voyager = "1.1.0-beta02"
```

En la sección `[libraries]`:

```toml
voyager-navigator = { module = "cafe.adriel.voyager:voyager-navigator", version.ref = "voyager" }
voyager-transitions = { module = "cafe.adriel.voyager:voyager-transitions", version.ref = "voyager" }
```

**Qué hace:** Declara la librería Voyager y sus dos módulos que usaremos: `voyager-navigator` (navegación) y `voyager-transitions` (animaciones entre pantallas).

---

## Paso 2: Agregar dependencias en `shared/build.gradle.kts`

**Archivo:** `shared/build.gradle.kts`

Dentro de `commonMain.dependencies {}`:

```kotlin
implementation(libs.voyager.navigator)
implementation(libs.voyager.transitions)
```

**Qué hace:** Hace que Voyager esté disponible en el módulo `shared` para todas las plataformas (Android, iOS, Desktop, Web).

---

## Paso 3: Crear `MainScreen.kt` — Pantalla principal

**Archivo nuevo:** `shared/src/commonMain/kotlin/com/smi/myapplication/MainScreen.kt`

```kotlin
package com.smi.myapplication

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.safeContentPadding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import cafe.adriel.voyager.core.screen.Screen
import cafe.adriel.voyager.navigator.LocalNavigator
import cafe.adriel.voyager.navigator.Navigator
import cafe.adriel.voyager.navigator.currentOrThrow

class MainScreen : Screen {
    @Composable
    override fun Content() {
        val navigator: Navigator = LocalNavigator.currentOrThrow
        Column(
            modifier = Modifier
                .background(MaterialTheme.colorScheme.primaryContainer)
                .safeContentPadding()
                .fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Button(onClick = { navigator.push(SecondScreen()) }) {
                Text("Navegación simple!")
            }
        }
    }
}
```

**Qué hace:**
- `MainScreen` implementa `Screen` de Voyager.
- Obtiene el `Navigator` mediante `LocalNavigator.currentOrThrow` para poder navegar.
- El botón "Navegación simple!" ejecuta `navigator.push(SecondScreen())`, que apila la segunda pantalla con animación.

---

## Paso 4: Crear `SecondScreen.kt` — Segunda pantalla

**Archivo nuevo:** `shared/src/commonMain/kotlin/com/smi/myapplication/SecondScreen.kt`

```kotlin
package com.smi.myapplication

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import cafe.adriel.voyager.core.screen.Screen
import cafe.adriel.voyager.navigator.LocalNavigator
import cafe.adriel.voyager.navigator.Navigator
import cafe.adriel.voyager.navigator.currentOrThrow

class SecondScreen : Screen {
    @Composable
    override fun Content() {
        val navigator: Navigator = LocalNavigator.currentOrThrow
        Column(
            modifier = Modifier.fillMaxSize().background(Color.Blue),
            verticalArrangement = Arrangement.SpaceAround
        ) {
            Text("Segunda Pantalla", fontSize = 26.sp, color = Color.White)
            Button(onClick = { navigator.pop() }) {
                Text("Volver")
            }
        }
    }
}
```

**Qué hace:**
- `SecondScreen` también es un `Screen` de Voyager.
- Fondo azul con los elementos distribuidos con `SpaceAround`.
- El botón "Volver" ejecuta `navigator.pop()`, que desapila la pantalla y regresa a la anterior.

---

## Paso 5: Modificar `App.kt` — Integrar el Navigator

**Archivo:** `shared/src/commonMain/kotlin/com/smi/myapplication/App.kt`

Se reemplaza **todo el contenido** del archivo:

```kotlin
package com.smi.myapplication

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import cafe.adriel.voyager.navigator.Navigator
import cafe.adriel.voyager.transitions.SlideTransition

@Composable
@Preview
fun App() {
    MaterialTheme {
        Navigator(screen = MainScreen()) { navigator ->
            SlideTransition(navigator)
        }
    }
}
```

**Qué hace:**
- `Navigator(screen = MainScreen())` establece `MainScreen` como pantalla raíz.
- `SlideTransition(navigator)` envuelve el contenido en una transición slide al navegar entre pantallas.
- Se elimina todo el contenido anterior (botón de greeting, imagen, etc.) que ahora vive en `MainScreen`.

---

## Resumen de archivos modificados/creados

| Archivo | Acción | Propósito |
|---------|--------|-----------|
| `gradle/libs.versions.toml` | Modificado | Agregar versión y librerías de Voyager |
| `shared/build.gradle.kts` | Modificado | Agregar dependencias de Voyager |
| `shared/.../MainScreen.kt` | **Creado** | Pantalla principal con botón a SecondScreen |
| `shared/.../SecondScreen.kt` | **Creado** | Segunda pantalla con botón de regreso |
| `shared/.../App.kt` | Modificado | Reemplazar contenido por Navigator + SlideTransition |

---

## Orden para replicar

1. Editar `gradle/libs.versions.toml`
2. Editar `shared/build.gradle.kts`
3. Crear `shared/src/commonMain/kotlin/com/smi/myapplication/MainScreen.kt`
4. Crear `shared/src/commonMain/kotlin/com/smi/myapplication/SecondScreen.kt`
5. Modificar `shared/src/commonMain/kotlin/com/smi/myapplication/App.kt`
6. Sincronizar Gradle y ejecutar

## Verificar funcionamiento

Al ejecutar la app:
- Se ve la pantalla principal (MainScreen) con un botón "Navegación simple!"
- Al presionar el botón, navega a SecondScreen con animación slide
- SecondScreen muestra "Segunda Pantalla" en azul con un botón "Volver"
- Al presionar "Volver", regresa a MainScreen

---

*Generado a partir de los cambios registrados en `GUIA_CAMBIOS.md`*