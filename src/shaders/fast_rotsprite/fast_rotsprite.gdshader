
shader_type canvas_item;

const vec4 background = vec4(1., 1., 1., 0.);

uniform float pixel_scale: hint_range(0.0, 1.0) = 1.0;

float dist(vec4 c1, vec4 c2) {
	return (c1 == c2) ? 0.0 : abs(c1.r - c2.r) + abs(c1.g - c2.g) + abs(c1.b - c2.b);
}

bool similar(vec4 c1, vec4 c2, vec4 input) {
	return (c1 == c2 || (dist(c1, c2) <= dist(input, c2) && dist(c1, c2) <= dist(input, c1)));
}

bool different(vec4 c1, vec4 c2, vec4 input) {
	return !similar(c1, c2, input);
}

// rotsprite 3x enlargement algorithm:
// suppose we are looking at input pixel cE which is surrounded by 8 other 
// pixels:
//  cA cB cC
//  cD cE cF
//  cG cH cI
// and for that 1 input pixel cE we want to output 4 pixels oA, oB, oC, and oD:
//  E0 E1 E2
//  E3 E4 E5
//  E6 E7 E8
vec4 scale3x(sampler2D tex, vec2 uv, vec2 pixel_size) {
	vec4 cE = texture(tex, uv);
	cE = cE.a == 0.0 ? background : cE;
	
	vec4 cD = texture(tex, uv + pixel_size * vec2(-1., .0));
	cD = cD.a == 0.0 ? background : cD;
	vec4 cF = texture(tex, uv + pixel_size * vec2(1., .0));
	cF = cF.a == 0.0 ? background : cF;
	vec4 cH = texture(tex, uv + pixel_size * vec2(.0, 1.));
	cH = cH.a == 0.0 ? background : cH;
	vec4 cB = texture(tex, uv + pixel_size * vec2(.0, -1.));
	cB = cB.a == 0.0 ? background : cB;
	vec4 cA = texture(tex, uv + pixel_size * vec2(-1., -1.));
	cA = cA.a == 0.0 ? background : cA;
	vec4 cI = texture(tex, uv + pixel_size * vec2(1., 1.));
	cI = cI.a == 0.0 ? background : cI;
	vec4 cG = texture(tex, uv + pixel_size * vec2(-1., 1.));
	cG = cG.a == 0.0 ? background : cG;
	vec4 cC = texture(tex, uv + pixel_size * vec2(1., -1.));
	cC = cC.a == 0.0 ? background : cC;
	
	if (different(cD,cF, cE)
     && different(cH,cB, cE)
     && ((similar(cE, cD, cE) || similar(cE, cH, cE) || similar(cE, cF, cE) || similar(cE, cB, cE) ||
         ((different(cA, cI, cE) || similar(cE, cG, cE) || similar(cE, cC, cE)) &&
          (different(cG, cC, cE) || similar(cE, cA, cE) || similar(cE, cI, cE))))))
    {
		vec2 unit = uv - (floor(uv / pixel_size) * pixel_size);
		vec2 pixel_3_size = pixel_size / 3.0;
		
		// E0
		if (unit.x < pixel_3_size.x && unit.y < pixel_3_size.y) {
			return similar(cB, cD, cE) ? cB : cE;
		}
		
		
		// E1
		if (unit.x < pixel_3_size.x * 2.0 && unit.y < pixel_3_size.y) {
			return (similar(cB, cD, cE) && different(cE, cC, cE))
				|| (similar(cB, cF, cE) && different(cE, cA, cE)) ? cB : cE;
		}
		
		// E2
		if (unit.y < pixel_3_size.y) {
			return similar(cB, cF, cE) ? cB : cE;
		}
		
		// E3
		if (unit.x < pixel_3_size.x && unit.y < pixel_3_size.y * 2.0) {
			return (similar(cB, cD, cE) && different(cE, cG, cE)
				|| (similar(cH, cD, cE) && different(cE, cA, cE))) ? cD : cE;
		}
		
		// E5
		if (unit.x >= pixel_3_size.x * 2.0 && unit.x < pixel_3_size.x * 3.0 && unit.y < pixel_3_size.y * 2.0) {
			return (similar(cB, cF, cE) && different(cE, cI, cE))
				|| (similar(cH, cF, cE) && different(cE, cC, cE)) ? cF : cE;
		}
		
		// E6
		if (unit.x < pixel_3_size.x && unit.y >= pixel_3_size.y * 2.0) {
			return similar(cH, cD, cE) ? cH : cE;
		}
		
		// E7
		if (unit.x < pixel_3_size.x * 2.0 && unit.y >= pixel_3_size.y * 2.0) {
			return (similar(cH, cD, cE) && different(cE, cI, cE))
				|| (similar(cH, cF, cE) && different(cE, cG, cE)) ? cH : cE;
		}
		
		// E8
		if (unit.y >= pixel_3_size.y * 2.0) {
			return similar(cH, cF, cE) ? cH : cE;
		}
    }
	
	return cE;
}

void fragment() {
	COLOR = scale3x(TEXTURE, UV, TEXTURE_PIXEL_SIZE * pixel_scale);
}