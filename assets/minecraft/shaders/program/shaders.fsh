#version 150

uniform sampler2D McSampler;
uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

uniform float Time;
uniform vec2 InSize;

// GLOWING SHADER
vec4 glowing(float rIn, float gIn, float bIn){
	// get Cur Texel
	vec4 CurTexel = texture(DiffuseSampler, texCoord);
	float total = 0.0;
	vec4 outColor = vec4(0.0, 0.0, 0.0, 0.0);
	if(CurTexel.a <= 0.1) {
		// check for glowing pixels in a radius to determine transparency
		float Radius = 5.0;
		float count = 0.0;
		for(float r = -Radius; r <= Radius; r += 1.0) {
			vec4 CheckTexel1 = texture(DiffuseSampler, texCoord + oneTexel * r * vec2(3.0, 3.0));
			if(CheckTexel1.a > 0.1) {
				count = count + 1.0;
				outColor = outColor + CheckTexel1;
			} else {
				vec4 CheckTexel2 = texture(DiffuseSampler, texCoord + oneTexel * r * vec2(-3.0, 3.0));
				if(CheckTexel2.a > 0.1) {
					count = count + 1.0;
					outColor = outColor + CheckTexel2;
				} else {
					vec4 CheckTexel3 = texture(DiffuseSampler, texCoord + oneTexel * r * vec2(3.0, -3.0));
					if(CheckTexel3.a > 0.1) {
						count = count + 1.0;
						outColor = outColor + CheckTexel3;
					} else {
						vec4 CheckTexel4 = texture(DiffuseSampler, texCoord + oneTexel * r * vec2(-3.0, -3.0));
						if(CheckTexel4.a > 0.1) {
							count = count + 1.0;
							outColor = outColor + CheckTexel4;
						}
					}
				}
			} 
		}
		total = count / 11.0;
		// determine color
		if(outColor.r > outColor.g && outColor.r > outColor.b) {
			return vec4(1.0, 0.33, 0.33, total);
		} else if (outColor.g > outColor.r && outColor.g > outColor.b) {
			return vec4(0.33, 1.0, 0.33, total);
		} else if (outColor.b > outColor.r && outColor.b > outColor.g) {
			return vec4(0.33, 0.33, 1.0, total);
		} else {
			return vec4(1.0, 1.0, 0.33, total);
		}
	} else { 
		// for areas that arent glowing
		return vec4(0.0, 0.0, 0.0, 0.0);
	}
}


// Player Blur
vec4 pblur() {
	vec2 BlurDir = vec2(2.0, 2.0);
	float Radius = 5.0;
	vec4 blurred = vec4(0.0);
	float totalStrength = 0.0;
	float totalAlpha = 0.0;
	float totalSamples = 0.0;
	float count = 0.0;
	for(float r = -Radius; r <= Radius; r += 1.0) {
		vec4 FinalTexel = texture(DiffuseSampler, texCoord + oneTexel * r * BlurDir);
		if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
			vec4 sampleValue = texture(McSampler, texCoord + oneTexel * r * BlurDir);
			// Accumulate average alpha
			totalAlpha = totalAlpha + sampleValue.a;
			totalSamples = totalSamples + 1.0;

			// Accumulate smoothed blur
			float strength = 1.0 - abs(r / Radius);
			totalStrength = totalStrength + strength;
			blurred = blurred + sampleValue;
			
			count = count + 1.0;
		}
	}
	if(count > 0.0) {
		return vec4(blurred.rgb / count, 0.5);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
}

// Recolor
vec4 recolor() {
	vec4 FinalTexel = texture(DiffuseSampler, texCoord);
	if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
		vec4 sampleValue = texture(McSampler, texCoord);
		return vec4(sampleValue.b + 0.1, sampleValue.r - 0.2, sampleValue.g * 0.5, 1.0);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
}

// Recolor #2
vec4 recolor2() {
	vec4 FinalTexel = texture(DiffuseSampler, texCoord);
	if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
		vec4 sampleValue = texture(McSampler, texCoord);
		return vec4(sampleValue.g, sampleValue.b, sampleValue.r, 1.0);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
}

// Recolor #3
vec4 recolor3() {
	vec4 FinalTexel = texture(DiffuseSampler, texCoord);
	if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
		vec4 sampleValue = texture(McSampler, texCoord);
		return vec4(sampleValue.b - 0.1, sampleValue.g, sampleValue.b + 0.1, 1.0);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
}



// Purple Blur
vec4 forcefield() {
	vec2 BlurDir = vec2(2.0, 2.0);
	float Radius = 2.0;
	vec4 blurred = vec4(0.0);
	float totalStrength = 0.0;
	float totalAlpha = 0.0;
	float totalSamples = 0.0;
	float count = 0.0;
	for(float r = -Radius; r <= Radius; r += 1.0) {
		vec4 FinalTexel = texture(DiffuseSampler, texCoord + oneTexel * r * BlurDir);
		if(FinalTexel.r > 0.1 || FinalTexel.g > 0.1 || FinalTexel.b > 0.1) {
			vec4 sampleValue = texture(McSampler, texCoord + oneTexel * r * BlurDir);
			// Accumulate average alpha
			totalAlpha = totalAlpha + sampleValue.a;
			totalSamples = totalSamples + 1.0;

			// Accumulate smoothed blur
			float strength = 1.0 - abs(r / Radius);
			totalStrength = totalStrength + strength;
			blurred = blurred + sampleValue;
			
			count = count + 1.0;
		}
	}
	if(count > 0.0) {
		return vec4((blurred.rgb + (vec3(1.0, 0.0, 1.0) * 2.0)) / count, 0.5);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
}

// Fire Aura
vec4 fireAura() {
	vec4 FinalTexel = texture(DiffuseSampler, texCoord);
	vec2 BlurDir1 = vec2(5.0, 5.0 + (abs(Time - 0.5) * 5.0));
	vec2 BlurDir2 = vec2(-5.0, 5.0 + (abs(Time - 0.5) * 5.0));
	float Radius = 20.0 + (abs(Time - 0.5) * 5.0);
	float count = 0.0;
	float value = 0.0;
	bool found = false;
	for(float r = -Radius; r <= Radius; r += 1.5) {
		vec4 FinalTexel1 = texture(DiffuseSampler, texCoord + oneTexel * r * BlurDir1);
		if(FinalTexel1.r > 0.1 || FinalTexel1.g > 0.1 || FinalTexel1.b > 0.1) {
			count = count + 1.0;
			value = value + 1.0;
			found = true;
		} else {
			count = count + 0.5;
			value = value - 0.1;
		}
		vec4 FinalTexel2 = texture(DiffuseSampler, texCoord + oneTexel * r * BlurDir2);
		if(FinalTexel2.r > 0.1 || FinalTexel2.g > 0.1 || FinalTexel2.b > 0.1) {
			count = count + 1.0;
			value = value + 1.0;
			found = true;
		} else {
			count = count + 0.5;
			value = value - 0.1;
		}
	}
	if(found) {
		float opacity = value / count;
		if(opacity > 0.5) opacity = 0.5;
		return vec4(1.0, 0.2 + ( texCoord.y / 2.0), 0.2, opacity);
	} else {
		return vec4(1.0, 1.0, 1.0, 0.0);
	}
	
}


/*
// Main Function
*/
void main() {
    
    vec4 InTexel = texture(DiffuseSampler, texCoord);
	vec3 InData = vec3(0.0);
	
	if(InTexel.a > 0.5) {
		InData = InTexel.rgb;
	} else {
		 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/20.0), 0.0));
		 if(InTexel.a > 0.5) {
			InData = InTexel.rgb;
		} else {
			 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/20.0), 0.0));
			 if(InTexel.a > 0.5) {
				InData = InTexel.rgb;
			} else {
				 InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*(InSize.y/20.0)));
				 if(InTexel.a > 0.5) {
					InData = InTexel.rgb;
				} else {
					 InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*-(InSize.y/20.0)));
					 if(InTexel.a > 0.5) {
						InData = InTexel.rgb;
					} else {
						 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/40.0), oneTexel.y*(InSize.y/40.0)));
						  if(InTexel.a > 0.5) {
							InData = InTexel.rgb;
						} else {
							 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/40.0), oneTexel.y*(InSize.y/40.0)));
							 if(InTexel.a > 0.5) {
								InData = InTexel.rgb;
							} else {
								 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/40.0), oneTexel.y*-(InSize.y/40.0)));
								 if(InTexel.a > 0.5) {
									InData = InTexel.rgb;
								} else {
									 InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/40.0), oneTexel.y*-(InSize.y/40.0)));
									 if(InTexel.a > 0.5) {
										InData = InTexel.rgb;
									} else {
										InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/40.0), 0.0));
										if(InTexel.a > 0.5) {
											InData = InTexel.rgb;
										} else {
											InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/40.0), 0.0));
											if(InTexel.a > 0.5) {
												InData = InTexel.rgb;
											} else {
												InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*(InSize.y/40.0)));
												if(InTexel.a > 0.5) {
													InData = InTexel.rgb;
												} else {
													InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*-(InSize.y/40.0)));
													if(InTexel.a > 0.5) {
														InData = InTexel.rgb;
													} else {
														InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/80.0), 0.0));
														if(InTexel.a > 0.5) {
															InData = InTexel.rgb;
														} else {
															InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/80.0), 0.0));
															if(InTexel.a > 0.5) {
																InData = InTexel.rgb;
															} else {
																InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*(InSize.y/80.0)));
																if(InTexel.a > 0.5) {
																	InData = InTexel.rgb;
																} else {
																	InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*-(InSize.y/80.0)));
																	if(InTexel.a > 0.5) {
																		InData = InTexel.rgb;
																	} else {
																		InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/160.0), 0.0));
																		if(InTexel.a > 0.5) {
																			InData = InTexel.rgb;
																		} else {
																			InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/160.0), 0.0));
																			if(InTexel.a > 0.5) {
																				InData = InTexel.rgb;
																			} else {
																				InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*(InSize.y/160.0)));
																				if(InTexel.a > 0.5) {
																					InData = InTexel.rgb;
																				} else {
																					InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*-(InSize.y/160.0)));
																					if(InTexel.a > 0.5) {
																						InData = InTexel.rgb;
																					} else {
																						InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*(InSize.x/320.0), 0.0));
																						if(InTexel.a > 0.5) {
																							InData = InTexel.rgb;
																						} else {
																							InTexel = texture(DiffuseSampler, texCoord + vec2(oneTexel.x*-(InSize.x/320.0), 0.0));
																							if(InTexel.a > 0.5) {
																								InData = InTexel.rgb;
																							} else {
																								InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*(InSize.y/320.0)));
																								if(InTexel.a > 0.5) {
																									InData = InTexel.rgb;
																								} else {
																									InTexel = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y*-(InSize.y/320.0)));
																									if(InTexel.a > 0.5) {
																										InData = InTexel.rgb;
																									} else {
																										
																									}
																								}
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	
    

    if(InTexel == InTexel) {

		//  Detect Color
        if (InData == vec3(0.33333333, 1.0, 1.0)) { 
			// Aqua
            fragColor = pblur();
        } else if (InData == vec3(0.33333333, 0.33333333, 1.0)) { 
			// Blue
           fragColor =  glowing(0.33, 0.33, 1.0);
        } else if (InData == vec3(0.0, 0.66666666, 0.66666666)) { 
			// Dark Aqua
            fragColor = recolor();
        } else if (InData == vec3(0.0, 0.0, 0.66666666)) { 
			// Dark Blue
			fragColor = glowing(0.0, 0.0, 0.66);
        } else if (InData == vec3(0.33333333, 0.33333333, 0.33333333)) { 
			// Dark Gray
           fragColor = recolor2();
        } else if (InData == vec3(0.0, 0.66666666, 0.0)) { 
			// Dark Green
           fragColor =  glowing(0.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.0, 0.66666666)) { 
			// Dark Purple
            fragColor =  forcefield();
        } else if (InData == vec3(0.66666666, 0.0, 0.0)) { 
			// Dark Red
            fragColor = fireAura();
        } else if (InData == vec3(1.0, 0.66666666, 0.0)) { 
			// Gold
            fragColor = glowing(1.0, 0.66, 0.0);
        } else if (InData == vec3(0.66666666, 0.66666666, 0.66666666)) { 
			//Gray
           fragColor = glowing(0.66, 0.66, 0.66);
        } else if (InData == vec3(0.33333333, 1.0, 0.33333333)) { 
			// Green
            fragColor = glowing(0.33, 1.0, 0.33);
        } else if (InData == vec3(1.0, 0.33333333, 1.0)) { 
			// Light Purple
			 fragColor = recolor3();
        } else if (InData == vec3(1.0, 0.33333333, 0.33333333)) { 
			// Red
			fragColor = glowing(1.0, 0.33, 0.33);
        } else if (InData == vec3(1.0, 1.0, 1.0)) { 
			// White
           fragColor = glowing(1.0, 1.0, 1.0);
        } else if (InData == vec3(1.0, 1.0, 0.33333333)) { 
		   // Yellow
            fragColor = glowing(1.0, 1.0, 0.33);
        } else { 
			// No Color (Black) - UNUSED
            fragColor = vec4(0.0, 0.0, 0.0, 0.0); 
        }

    }
    
}