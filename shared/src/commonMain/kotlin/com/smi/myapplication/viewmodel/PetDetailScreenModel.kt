package com.smi.myapplication.viewmodel

import cafe.adriel.voyager.core.model.ScreenModel
import cafe.adriel.voyager.core.model.screenModelScope
import com.smi.myapplication.data.Pet
import com.smi.myapplication.data.PetRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class PetDetailScreenModel(petId: Long) : ScreenModel {
    val pet: StateFlow<Pet?> = PetRepository.getPetById(petId)
        .stateIn(screenModelScope, SharingStarted.WhileSubscribed(5000), null)
}
