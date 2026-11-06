/// @description Inicializa flicker e cooldown da vela que recarrega o dash.
// === CONFIGURAÇÃO DA VELA ===

// Salva escala original para efeito de flicker
base_xscale = image_xscale;
base_yscale = image_yscale;

// Efeito de flicker (piscar da chama)
flicker_timer = 0;
flicker_speed = irandom_range(3, 8); // Cada vela pisca diferente

// Recarregar dash do player ao tocar (como gemas do Celeste!)
is_active = true;
respawn_timer = 0;
respawn_time = 180; // 3 segundos para reaparecer (60 FPS * 3)
