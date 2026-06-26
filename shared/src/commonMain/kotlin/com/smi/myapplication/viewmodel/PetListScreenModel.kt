package com.smi.myapplication.viewmodel

import cafe.adriel.voyager.core.model.ScreenModel
import cafe.adriel.voyager.core.model.screenModelScope
import com.smi.myapplication.data.Pet
import com.smi.myapplication.data.PetRepository
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

class PetListScreenModel : ScreenModel {
    val pets: StateFlow<List<Pet>> = PetRepository.getAllPets()
        .stateIn(screenModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
}
