#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// MARK: - Random helpers

float random(float2 st) {
    return fract(sin(dot(st.xy, float2(12.9898, 78.233))) * 43758.5453123);
}

// MARK: - Scanline effect

[[ stitchable ]] half4 crtScanlineEffect(
    float2 position,
    half4 color,
    float4 bounds,
    float time,
    float scanlineIntensity,
    float curvature,
    float aberrationStrength,
    float vignetteStrength,
    float noiseIntensity
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;

    // Barrel distortion / screen curvature
    float dist = length(centered);
    float curve = 1.0 + curvature * dist * dist;
    float2 warped = centered * curve + 0.5;

    // Chromatic aberration at edges
    float2 aberrationOffset = centered * aberrationStrength * dist;

    float2 redUV = warped + aberrationOffset * 1.2;

    (void)redUV;

    // Sample with border clamping
    half4 sampleRed = color;
    half4 sampleGreen = color;
    half4 sampleBlue = color;

    // Only apply chromatic split if within bounds
    if (redUV.x >= 0.0 && redUV.x <= 1.0 && redUV.y >= 0.0 && redUV.y <= 1.0) {
        // We can't truly sample at offset positions in colorEffect,
        // so we approximate by tinting based on edge distance
        float edgeDist = smoothstep(0.0, 0.5, dist);
        float redShift = edgeDist * aberrationStrength * 0.3;
        float blueShift = edgeDist * aberrationStrength * 0.2;

        sampleRed.r += redShift;
        sampleBlue.b += blueShift;
    }

    half4 result = half4(
        clamp(sampleRed.r, half(0.0), half(1.0)),
        clamp(sampleGreen.g, half(0.0), half(1.0)),
        clamp(sampleBlue.b, half(0.0), half(1.0)),
        color.a
    );

    // Scanlines
    float scanline = sin(uv.y * bounds.w * 1.5 + time * 0.5) * 0.5 + 0.5;
    scanline = pow(scanline, 2.0);
    float scanlineMask = mix(1.0, scanline, scanlineIntensity);
    result.rgb *= half3(scanlineMask);

    // Subtle horizontal line interference
    float interference = sin(uv.y * 300.0 + time * 2.0) * 0.02 * scanlineIntensity;
    result.rgb += half3(interference);

    // Vignette
    float vignette = 1.0 - dist * vignetteStrength;
    vignette = smoothstep(0.0, 1.0, vignette);
    result.rgb *= half3(vignette);

    // Film grain noise
    float grain = random(uv + fract(time)) * noiseIntensity;
    result.rgb += half3(grain);

    // Subtle phosphor glow bleed (horizontal blur approximation)
    float glow = sin(uv.x * bounds.z * 0.8) * 0.015;
    result.rgb += half3(glow);

    return result;
}

// MARK: - CRT layer effect (for use with layerEffect)

[[ stitchable ]] half4 crtLayerEffect(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float time,
    float scanlineIntensity,
    float curvature,
    float aberrationStrength,
    float vignetteStrength,
    float noiseIntensity
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;

    // Barrel distortion
    float dist = length(centered);
    float curve = 1.0 + curvature * dist * dist;
    float2 warped = centered * curve + 0.5;

    // Sample the layer at warped coordinates
    half4 color = layer.sample(warped * bounds.zw);

    // Chromatic aberration by sampling RGB channels at slight offsets
    float2 aberrationOffset = centered * aberrationStrength * dist * 8.0;

    half4 redChannel = layer.sample((warped + float2(aberrationOffset.x * 0.5, 0.0)) * bounds.zw);
    half4 blueChannel = layer.sample((warped - float2(aberrationOffset.x * 0.5, 0.0)) * bounds.zw);

    half4 result = half4(redChannel.r, color.g, blueChannel.b, color.a);

    // Scanlines
    float scanline = sin(uv.y * bounds.w * 1.5) * 0.5 + 0.5;
    scanline = pow(scanline, 2.0);
    float scanlineMask = mix(1.0, scanline, scanlineIntensity);
    result.rgb *= half3(scanlineMask);

    // Horizontal interference lines
    float interference = sin(uv.y * 250.0 + time * 1.5) * 0.015 * scanlineIntensity;
    result.rgb += half3(interference);

    // Vignette
    float vignette = 1.0 - dist * vignetteStrength;
    vignette = smoothstep(0.0, 1.0, vignette);
    result.rgb *= half3(vignette);

    // Noise
    float grain = random(uv + fract(time * 0.1)) * noiseIntensity;
    result.rgb += half3(grain);

    // Phosphor grid (subtle dot pattern)
    float2 phosphorUV = uv * float2(bounds.z * 0.5, bounds.w * 0.5);
    float phosphor = sin(phosphorUV.x * 3.14159) * sin(phosphorUV.y * 3.14159);
    phosphor = pow(abs(phosphor), 0.5);
    result.rgb *= half3(mix(0.92, 1.0, phosphor * scanlineIntensity));

    // Screen edge darkening
    float2 edgeDist = abs(centered) * 2.0;
    float edgeDarken = 1.0 - smoothstep(0.7, 1.0, max(edgeDist.x, edgeDist.y)) * 0.15;
    result.rgb *= half3(edgeDarken);

    return result;
}

// MARK: - Distortion effect (for use with distortionEffect)

[[ stitchable ]] float2 crtDistortionEffect(
    float2 position,
    float4 bounds,
    float curvature
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;
    float dist = length(centered);
    float curve = 1.0 + curvature * dist * dist;
    float2 warped = centered * curve + 0.5;
    return warped * bounds.zw;
}

// MARK: - Glass Refraction Effect

[[ stitchable ]] half4 glassRefractionEffect(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float time,
    float intensity
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;

    // Subtle wave distortion
    float wave = sin(centered.x * 8.0 + time * 1.5) * 0.003;
    wave += sin(centered.y * 6.0 + time * 1.2) * 0.003;
    float2 distortedUV = uv + centered * wave * intensity;

    // Sample layer at distorted position
    half4 color = layer.sample(distortedUV * bounds.zw);

    // Chromatic split for glass edges
    float edgeDist = length(centered);
    float2 chromaticOffset = centered * edgeDist * 0.008 * intensity;

    half4 redChannel = layer.sample((distortedUV + float2(chromaticOffset.x, 0.0)) * bounds.zw);
    half4 blueChannel = layer.sample((distortedUV - float2(chromaticOffset.x, 0.0)) * bounds.zw);

    half4 result = half4(redChannel.r, color.g, blueChannel.b, color.a);

    // Frosted glass brightness boost
    float brightness = 1.0 + edgeDist * 0.05 * intensity;
    result.rgb *= half3(brightness);

    // Specular highlight
    float specular = pow(1.0 - edgeDist, 3.0) * 0.08 * intensity;
    result.rgb += half3(specular);

    return result;
}

// MARK: - Holographic Card Effect

[[ stitchable ]] half4 holographicCardEffect(
    float2 position,
    SwiftUI::Layer layer,
    float4 bounds,
    float time,
    float intensity
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;

    // Diagonal sheen
    float sheen = sin((centered.x + centered.y) * 12.0 + time * 2.0) * 0.5 + 0.5;
    sheen = pow(sheen, 4.0);

    // Sample base color
    half4 color = layer.sample(position);

    // Add iridescent shift (subtle monochrome variation)
    float shift = sin(time * 0.5 + centered.x * 4.0) * 0.03 * intensity;
    color.rgb += half3(shift);

    // Apply sheen as brightness pulse
    color.rgb += half3(sheen * 0.06 * intensity);

    return color;
}

// MARK: - Attachment Wave Distortion (for use with distortionEffect)

[[ stitchable ]] float2 attachmentWaveDistortion(
    float2 position,
    float4 bounds,
    float time,
    float intensity
) {
    float2 uv = position / bounds.zw;
    float2 centered = uv - 0.5;
    float dist = length(centered);

    // Subtle wave displacement
    float wave = sin(uv.x * 10.0 + time * 2.0) * 1.2;
    wave += cos(uv.y * 8.0 + time * 1.5) * 1.2;

    // Reduce displacement at edges to avoid clipping
    float edgeFade = 1.0 - smoothstep(0.3, 0.5, dist);

    return position + centered * wave * intensity * edgeFade;
}

// MARK: - Attachment Shimmer Effect (for use with colorEffect)

[[ stitchable ]] half4 attachmentShimmerEffect(
    float2 position,
    half4 color,
    float time,
    float intensity
) {
    // Use pixel position directly for wave patterns
    float sheen = sin((position.x + position.y) * 0.05 + time * 2.5) * 0.5 + 0.5;
    sheen = pow(sheen, 5.0);

    // Subtle edge brightness using normalized approximate distance
    float edgeGlow = 0.0;

    // Combine
    half3 glow = half3((sheen * 0.15 + edgeGlow) * intensity);

    return half4(color.rgb + glow, color.a);
}
