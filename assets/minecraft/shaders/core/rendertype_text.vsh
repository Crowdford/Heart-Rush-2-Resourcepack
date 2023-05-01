#version 150

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
	
	// delete sidebar numbers
	if(	Position.z == 0.0 && // check if the depth is correct (0 for gui texts)
			gl_Position.x >= 0.95 && gl_Position.y >= -0.35 && // check if the position matches the sidebar
			vertexColor.g == 84.0/255.0 && vertexColor.g == 84.0/255.0 && vertexColor.r == 252.0/255.0 && // check if the color is the sidebar red color
			gl_VertexID <= 3 // check if it's the first character of a string
		) gl_Position = ProjMat * ModelViewMat * vec4(ScreenSize + 100.0, 0.0, 0.0); // move the vertices offscreen, idk if this is a good solution for that but vec4(0.0) doesnt do the trick for everyone
        
    // NoShadow behavior (https://github.com/PuckiSilver/NoShadow)
    if (Color.xyz == vec3(78/255., 92/255., 36/255.) && (Position.z == 0.03 || Position.z == 0.06 || Position.z == 0.12)) {
        vertexColor.rgb = texelFetch(Sampler2, UV2 / 16, 0).rgb; // remove color from no shadow marker
    } else if (Color.xyz == vec3(19/255., 23/255., 9/255.) && Position.z == 0) {
        gl_Position = vec4(2,2,2,1); // move shadow off screen
    }
}