/// @description Reduz a opacidade do rastro do dash e o destrói ao terminar.
// Faz o rastro ficar transparente aos poucos
image_alpha -= 0.05;

// Quando ficar totalmente invisível, se autodestrói para não pesar o jogo
if (image_alpha <= 0) {
    instance_destroy();
}
