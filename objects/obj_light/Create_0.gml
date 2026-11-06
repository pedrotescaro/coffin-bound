/// @description Inicializa o volume de luz e as partículas usadas na iluminação ambiental.
// ============================================================
// obj_light — EVENTO CREATE
// Luz Translúcida Volumétrica de Masmorra / Janela
// ============================================================

light_radius = 64;            // Raio de iluminação e área de dano
light_intensity = 0.6;        // Intensidade geral de opacidade
flicker = 0;                  // Oscilação suave do raio
pulse_timer = random(100);    // Timer com offset aleatório para cada janela

// Partículas de poeira luminosa flutuando no feixe
light_particles = [];
for (var i = 0; i < 12; i++) {
    array_push(light_particles, {
        px: x + random_range(-light_radius * 0.6, light_radius * 0.6),
        py: y + random_range(-light_radius * 0.6, light_radius * 0.6),
        speed_y: random_range(-0.35, -0.12),
        speed_x: random_range(-0.08, 0.08),
        alpha: random_range(0.2, 0.6),
        size: (i % 3 == 0) ? 2 : 1
    });
}
