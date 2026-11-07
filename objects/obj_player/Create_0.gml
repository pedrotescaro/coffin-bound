/// @description Inicializa estado, física, recursos, parâmetros visuais e HUD do player.
// ============================================================
// obj_player — EVENTO CREATE
// Inicializa todas as variáveis do vampiro/morcego
// Organizado por categoria, comentado em português
// ============================================================

// REGULA A RESOLUÇÃO DA GUI PARA 480x270 (Alinha 1:1 com a sala e ajusta a escala no viewport!)
cb_gui_apply();

// ===== STATE MACHINE =====
state = PlayerState.NORMAL;   // Estado inicial
prev_state = state;           // Estado do frame anterior (para detectar transições)

// ===== FÍSICA GERAL =====
hsp = 0;                      // Velocidade horizontal (pixels/frame)
vsp = 0;                      // Velocidade vertical (pixels/frame)
grv = 0.3;                    // Gravidade (aceleração vertical por frame)
max_vsp = 10;                 // Terminal velocity — velocidade máxima de queda

// ===== MOVIMENTO HORIZONTAL (HUMANO) =====
walk_spd = 3;                 // Velocidade máxima de caminhada
accel_ground = 0.55;          // Aceleração no chão em pixels/frame²
accel_air = 0.28;             // Controle no ar em pixels/frame²
friction_ground = 0.45;       // Desaceleração sem input no chão
friction_air = 0.12;          // Preserva parte da inércia no ar
jump_spd = -6;                // Velocidade inicial do pulo (negativo = sobe)

// ===== JUICE / PROGRAMMAÇÃO DE ANIMAÇÃO (Squish & Stretch) =====
xscale_draw = 1;
yscale_draw = 1;
angle_draw = 0;

// Somente apresentação: estes valores nunca participam da hitbox ou da física.
visual_landed = false;
visual_was_on_ground = true;
visual_recover_rate = 0.15;
visual_angle_recover_rate = 0.2;
visual_jump_squash_x = 0.7;
visual_jump_stretch_y = 1.35;
visual_air_stretch_x = 0.86;
visual_air_stretch_y = 1.16;
visual_fall_squash_x = 1.12;
visual_fall_squash_y = 0.90;
visual_fall_tilt = 7;
visual_land_squash_x = 1.30;
visual_land_squash_y = 0.70;
visual_dash_duration = 7;
visual_dash_timer = 0;
visual_dash_direction = 0;
visual_dash_stretch = 1.28;
visual_dash_squash = 0.78;
visual_dash_tilt = 10;

// ===== DASH =====
can_dash = true;              // Se pode dar dash (reseta ao tocar o chão)
dash_spd = 7.5;               // Velocidade do dash (pixels/frame)
dash_duration = 9;            // Duração em frames (~150ms a 60 FPS)
dash_timer = 0;               // Contador regressivo do dash ativo
dash_hsp = 0;                 // Componente horizontal do dash (calculado no início)
dash_vsp = 0;                 // Componente vertical do dash

// ===== WALL SLIDE & WALL JUMP =====
wall_slide_spd = 2;           // Velocidade de escorregada na parede
wall_jump_hsp = 5;            // Força horizontal do wall jump
wall_jump_vsp = -6;           // Força vertical do wall jump (negativo = sobe)
wall_jump_timer = 0;          // Bloqueia input horizontal após wall jump
wall_stick_timer = 0;         // Timer de "grude" na parede (countdown)
wall_stick_max = 15;          // 15 frames (~0.25s) para deslizar naturalmente

// ===== COYOTE TIME & JUMP BUFFER =====
coyote_frames = 6;            // 100 ms de tolerância a 60 FPS
coyote_counter = 0;           // Countdown de coyote time
buffer_frames = 6;            // Frames de tolerância do input de pulo
buffer_counter = 0;           // Countdown de jump buffer

// ===== MORCEGO — RECURSO E HABILIDADE DE MOVIMENTAÇÃO =====
bat_energy_max = 100;         // Energia máxima do morcego
bat_energy = bat_energy_max;  // Começa cheio
bat_activation_cost = 20;     // Custo único para usar a habilidade; não limita o voo ativo
bat_recharge_rate = 0.33;     // Recarrega por frame como humano (≈5s do zero ao máximo)
bat_min_to_transform = 20;    // Precisa de pelo menos 20% de energia para transformar

// Tempo de fadiga da habilidade (todos os valores em frames)
bat_flight_duration = 180;    // 3 s até atingir velocidade e gravidade finais
bat_flight_timer = 0;
bat_fatigue = 0;              // 0 = asas fortes; 1 = exaustão máxima
bat_fatigue_lerp = 0.08;      // Suaviza a resposta da física ao esgotamento
bat_phase = BatPhase.LAUNCH;

// Impulso inicial
bat_launch_speed = 8;
bat_launch_frames = 10;
bat_launch_timer = 0;
bat_launch_control_accel = 0.04;

// Voo com inércia, desaceleração e perda gradual de sustentação
bat_speed_start = 4.5;        // Velocidade alvo logo após o impulso
bat_speed_end = 1.5;          // Velocidade alvo no fim do voo
bat_control_accel = 0.08;     // Quanto menor, maior a inércia para virar
bat_gravity_start = 0.01;     // Quase sustentação no início
bat_gravity_end = 0.38;       // Queda forte na exaustão
bat_max_fall_speed = 6;
bat_lift_fresh = 0.22;        // Sustentação ao segurar para cima com stamina alta
bat_lift_tired = 0.06;        // Sustentação residual na exaustão
bat_wing_speed_fresh = 1.0;   // Animação das asas com stamina alta
bat_wing_speed_tired = 0.25;  // Animação das asas na exaustão
bat_wing_speed = bat_wing_speed_fresh;

// Margem após a ativação: evita pouso/cancelamento injusto junto ao chão
bat_landing_grace_frames = 6;
bat_landing_grace_timer = 0;

// ===== TRANSFORMAÇÃO =====
transform_duration = 10;      // Frames da transição
transform_timer = 0;          // Countdown da animação de transição

// ===== COLISÃO =====
mask_index = spr_vampire_idle;
// Espelhamento é só visual; image_xscale permanece 1 para estabilizar a máscara.
image_xscale = 1;
facing_dir = 1;

// ===== FLAGS DE DETECÇÃO =====
on_ground = false;            // True se há chão 1px abaixo
on_wall = 0;                  // -1=esquerda, 0=sem parede, 1=direita
move_input = 0;               // -1=esquerda, 0=parado, 1=direita

// ===== PALETA GAMEBOY VERDE =====
COLOR_GB_DARKEST = make_color_rgb(15,56,15);   // #0f380f - Fundo escuro
COLOR_GB_DARK    = make_color_rgb(15,56,15);   // #306230 - Sombra/Card
COLOR_GB_LIGHT   = make_color_rgb(139,172,15); // #8bac0f - Verde Médio
COLOR_GB_BRIGHT  = make_color_rgb(155,188,15); // #9bbc0f - Verde Brilhante

// ===== CORES E HUD MODERNO =====
COLOR_HUD_BG     = make_color_rgb(15,56,15);    // Fundo escuro fosco
COLOR_HUD_BORDER = make_color_rgb(48,98,48);    // Borda elegante
COLOR_HP_FILL    = make_color_rgb(139,172,15);  // Vermelho Rubí vibrante
COLOR_HP_BG      = make_color_rgb(15,56,15);    // Trilho HP escuro
COLOR_VOO_FILL   = make_color_rgb(155,188,15);   // Ciano / Esmeralda brilhante
COLOR_VOO_BG     = make_color_rgb(48,98,48);    // Trilho VOO escuro

// ===== SISTEMA DE VIDA (HP) =====
max_hp = 100;
hp = max_hp;
display_hp = max_hp;          // Suavizado para barras fluidas
hp_damage_trail = max_hp;     // Rastro de dano / sangramento atrasado
display_bat = bat_energy_max; // Suavizado para barras fluidas
light_damage_rate = 0.6;      // Dano por frame quando exposto a luz/vela
light_damage_radius = 54;     // Raio de alcance da luz da vela
flash_hit = 0;                // Timer de piscar ao levar dano
damage_pulse = 0;             // Pulso de calor/fogo
burn_particles = [];          // Partículas de queima

// ===== VITÓRIA =====
level_won = false;
win_timer = 0;

// ===== DEBUG =====
show_debug = false;
suppress_action_press = true;

// Reset único usado também pelos checkpoints; os parâmetros acima são preservados.
player_reset(x, y);
