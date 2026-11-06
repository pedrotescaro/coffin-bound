// ============================================================
// ENUMS GLOBAIS DO JOGO
// @description Estados e fases compartilhados pela máquina de movimento.
// Definidos em script para serem acessíveis por qualquer objeto.
// ============================================================

/// Estados do player: NORMAL/JUMP/FALL/DAMAGE compartilham a física humana.
/// As transições especiais controlam dash, parede, transformação e conclusão.
enum PlayerState {
    NORMAL,              // Forma humana apoiada: parado ou andando
    DASH,                // Dash em 8 direções (override total de velocidade)
    WALL_SLIDE,          // Escorregando/grudado na parede
    TRANSFORM_TO_HUMAN,  // Transição morcego → humano (congela input)
    BAT,                 // Forma morcego — voo livre, sem gravidade normal
    WIN,                 // Vitória — tocou o caixão, congela tudo
    JUMP,                // Forma humana em subida
    FALL,                // Forma humana em queda
    DAMAGE,              // Reação breve à luz; preserva o controle
    DEATH,               // Aguarda o controlador decidir o respawn
}

/// Fase interna da habilidade de morcego.
/// BAT continua sendo um único estado de movimento do player.
enum BatPhase {
    LAUNCH,              // Impulso inicial da transformação
    FLIGHT,              // Voo com inércia e perda gradual de sustentação
}

/// Páginas disponíveis no menu principal.
enum MenuPage {
    MAIN,
    OPTIONS,
}
