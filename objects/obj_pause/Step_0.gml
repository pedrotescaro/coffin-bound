/// @description Alterna a pausa e processa as escolhas do menu suspenso.
// ============================================================
// obj_pause — EVENTO STEP
// Alterna o estado de pausa e gerencia as escolhas do jogador
// ============================================================

// Teclas de controle
var _key_pause   = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("P"));
var _key_up      = keyboard_check_pressed(vk_down)   || keyboard_check_pressed(ord("S"));
var _key_down    = keyboard_check_pressed(vk_up)     || keyboard_check_pressed(ord("W"));
var _key_select  = keyboard_check_pressed(vk_space)  || keyboard_check_pressed(vk_enter);

var _is_game_room = (room != rm_menu);

// Alterna Pausa ao pressionar ESC apenas durante as salas de jogo
if (_key_pause && _is_game_room) {
    global.is_paused = !global.is_paused;
    
    if (global.is_paused) {
        selected = 0;
        selectLerp = 0;
        // Congela as instâncias do jogo para pausar a física
        instance_deactivate_all(true);
        if (object_exists(obj_gameboy)) instance_activate_object(obj_gameboy);
        // Inputs precisa permanecer ativo para continuar atualizando teclado e controle.
        if (object_exists(__InputUpdateController)) instance_activate_object(__InputUpdateController);
    } else {
        // Descongela todas as instâncias para continuar o jogo
        instance_activate_all();
    }
}

// Lógica de navegação no menu suspenso de pausa
if (global.is_paused) {
    // Oscilação do cursor
    cursorLevitate = dsin(cursorTime) * 3;
    cursorTime += leviRate;

    var _vert = _key_up - _key_down;
    if (_vert != 0) {
        selected = clamp(selected + _vert, 0, array_length(pause_menu) - 1);
    }
    selectLerp = lerp(selectLerp, selected, lerpAmt);

    // Confirmação de Escolha
    if (_key_select) {
        switch (selected) {
            case 0: // JOGAR (CONTINUAR)
                global.is_paused = false;
                instance_activate_all();
                break;
                
            case 1: // RECOMECAR (REINICIAR SALA)
                global.is_paused = false;
                instance_activate_all();
                room_restart();
                break;
                
            case 2: // MENU (VOLTAR PARA O MENU PRINCIPAL)
                global.is_paused = false;
                instance_activate_all();
                room_goto(rm_menu);
                break;
        }
    }
}
