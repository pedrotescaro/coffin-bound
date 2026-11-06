/// @description Inicializa estado global, opções e variáveis visuais do menu de pausa.
// ============================================================
// obj_pause — EVENTO CREATE
// Sistema de Pausa Persistente In-Game com Estética GameBoy
// ============================================================

global.is_paused = false;

// Opções do Mini Menu de Pausa
pause_menu[0] = "JOGAR";       // Continuar o jogo
pause_menu[1] = "RECOMECAR";    // Reiniciar a fase atual
pause_menu[2] = "MENU";        // Voltar para o Menu Principal

// Navegação e Lerp
selected = 0;
selectLerp = 0;
lerpAmt = 0.25;

// Animação de Levitação do Cursor
cursorLevitate = 0;
cursorTime = 0;
leviRate = 1.5;

// Cores Oficiais GameBoy Verde
selectedCol     = make_color_rgb(155, 188, 15); // Verde Brilhante #9bbc0f
notSelectedCol  = make_color_rgb(15, 56, 15);   // Verde Escuro #0f380f
titleCol        = make_color_rgb(255, 255, 255); // Branco
