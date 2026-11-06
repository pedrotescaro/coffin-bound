// ============================================================
// ENUMS GLOBAIS DO JOGO
// @description Estados e fases compartilhados pela máquina de movimento.
// Definidos em script para serem acessíveis por qualquer objeto.
// ============================================================

/// Estados do player — representa o MODO DE MOVIMENTO ativo
/// Inspirado no design do Celeste (Matt Thorson):
/// Cada estado muda a FÍSICA, não é micro-estado de animação.
/// A animação é determinada por condições dentro de cada estado.
enum PlayerState {
    NORMAL,              // Idle, corrida, pulo, queda (sub-determinado por condições)
    DASH,                // Dash em 8 direções (override total de velocidade)
    WALL_SLIDE,          // Escorregando/grudado na parede
    TRANSFORM_TO_HUMAN,  // Transição morcego → humano (congela input)
    BAT,                 // Forma morcego — voo livre, sem gravidade normal
    WIN,                 // Vitória — tocou o caixão, congela tudo
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
