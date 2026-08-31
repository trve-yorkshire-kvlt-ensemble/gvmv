shader_type canvas_item;

// The 3x1 texture containing the new colors
uniform sampler2D palette_tex : filter_nearest;

// The original 3 colors used on the candle body in the sprite sheet
uniform vec4 base_dark : source_color;
uniform vec4 base_mid : source_color;
uniform vec4 base_light : source_color;

// How closely the color needs to match to be swapped
uniform float precision : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);

    // UV coordinates for the center of each pixel in a 3x1 texture
    // (1/6 ≈ 0.166, 3/6 = 0.5, 5/6 ≈ 0.833)
    if (distance(current_color.rgb, base_dark.rgb) < precision) {
        current_color.rgb = texture(palette_tex, vec2(0.166, 0.5)).rgb;
    }
    else if (distance(current_color.rgb, base_mid.rgb) < precision) {
        current_color.rgb = texture(palette_tex, vec2(0.5, 0.5)).rgb;
    }
    else if (distance(current_color.rgb, base_light.rgb) < precision) {
        current_color.rgb = texture(palette_tex, vec2(0.833, 0.5)).rgb;
    }

    COLOR = current_color;
}