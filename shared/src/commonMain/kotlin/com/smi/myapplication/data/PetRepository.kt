package com.smi.myapplication.data

import app.cash.sqldelight.coroutines.asFlow
import app.cash.sqldelight.coroutines.mapToList
import app.cash.sqldelight.coroutines.mapToOneOrNull
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

object PetRepository {
    private var db: PetDatabase? = null

    fun init(driverFactory: DatabaseDriverFactory) {
        db = PetDatabase(driverFactory.createDriver())
        if (db!!.petDatabaseQueries.countAll().executeAsOne() == 0L) {
            seedData()
        }
    }

    private fun seedData() {
        val pets = listOf(
            listOf("Max", "https://images.dog.ceo/breeds/labrador/n02099712_7749.jpg", 3, "Labrador", "Jugar a la pelota, nadar, correr", "Dorado", 28.5),
            listOf("Luna", "https://images.dog.ceo/breeds/husky/n02110185_3589.jpg", 2, "Husky", "Salir a caminar, morder juguetes", "Gris y blanco", 22.0),
            listOf("Simba", "https://cataas.com/cat/2lo2luOySDGPFCng", 5, "Persa", "Dormir al sol, comer atún", "Naranja", 4.5),
            listOf("Bella", "https://images.dog.ceo/breeds/poodle-toy/n02113624_9229.jpg", 1, "Poodle Toy", "Jugar con la cuerda, dar la pata", "Blanco", 3.2),
            listOf("Milo", "https://cataas.com/cat/2R4fwl2tPwmSwvp1", 4, "Siamés", "Trepar muebles, mirar por la ventana", "Cremita y marrón", 3.8)
        )
        pets.forEach { p ->
            db!!.petDatabaseQueries.insert(
                name = p[0] as String,
                image_url = p[1] as String,
                age = (p[2] as Int).toLong(),
                breed = p[3] as String,
                likes = p[4] as String,
                color = p[5] as String,
                weight = p[6] as Double
            )
        }
    }

    fun getAllPets(): Flow<List<Pet>> = db!!.petDatabaseQueries.selectAll()
        .asFlow().mapToList(Dispatchers.Default)
        .map { list -> list.map { it.toPet() } }

    fun getPetById(id: Long): Flow<Pet?> = db!!.petDatabaseQueries.selectById(id)
        .asFlow().mapToOneOrNull(Dispatchers.Default)
        .map { it?.toPet() }
}

private fun PetEntity.toPet() = Pet(
    id = id,
    name = name,
    imageUrl = image_url,
    age = age.toInt(),
    breed = breed,
    likes = likes,
    color = color,
    weight = weight
)
