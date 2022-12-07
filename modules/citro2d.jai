//
// Jai bindings for citro2d
// Created with help of Bindings_Generator
//

#import "libctru";
#import "citro3d";

C2D_DEFAULT_MAX_OBJECTS :: 4096;

C2D_DrawParams :: struct {
    pos:    struct {
        x: float;
        y: float;
        w: float;
        h: float;
    };
    center: struct {
        x: float;
        y: float;
    };
    depth:  float;
    angle:  float;
}

C2D_TintMode :: enum u8 {
    Solid :: 0;
    Mult  :: 1;
    Luma  :: 2;
}

C2D_Tint :: struct {
    color: u32; ///< RGB tint color and Alpha transparency
    blend: float; ///< Blending strength of the tint color (0.0~1.0)
}

C2D_Corner :: enum u8 {
    TopLeft  :: 0;
    TopRight :: 1;
    BotLeft  :: 2;
    BotRight :: 3;
}

C2D_Image :: struct {
    tex:    *C3D_Tex;
    subtex: *Tex3DS_SubTexture #align 4;
}

C2D_ImageTint :: struct {
    corners: [4] C2D_Tint;
}

/** @defgroup Helper Helper functions
 *  @{
 */

/** @brief Clamps a value between bounds
 *  @param[in] x The value to clamp
 *  @param[in] min The lower bound
 *  @param[in] max The upper bound
 *  @returns The clamped value
 */
C2D_Clamp :: inline (x: float, min: float, max: float) -> float {
    return ifx x <= min then min else (ifx x >= max then max else x);
}

/** @brief Converts a float to u8
 *  @param[in] x Input value (0.0~1.0)
 *  @returns Output value (0~255)
 */
C2D_FloatToU8 :: inline (x: float) -> u8 {
    return cast(u8)(255.0*C2D_Clamp(x, 0.0, 1.0)+0.5);
}

/** @brief Builds a 32-bit RGBA color value
 *  @param[in] r Red component (0~255)
 *  @param[in] g Green component (0~255)
 *  @param[in] b Blue component (0~255)
 *  @param[in] a Alpha component (0~255)
 *  @returns The 32-bit RGBA color value
 */
C2D_Color32 :: inline (r: u8, g: u8, b: u8, a: u8) -> u32 {
    return r | (g << cast(u32)8) | (b << cast(u32)16) | (a << cast(u32)24);
}

/** @brief Builds a 32-bit RGBA color value from float values
 *  @param[in] r Red component (0.0~1.0)
 *  @param[in] g Green component (0.0~1.0)
 *  @param[in] b Blue component (0.0~1.0)
 *  @param[in] a Alpha component (0.0~1.0)
 *  @returns The 32-bit RGBA color value
 */
C2D_Color32f :: inline (r: float, g: float, b: float, a: float) -> u32 {
    return C2D_Color32(C2D_FloatToU8(r),C2D_FloatToU8(g),C2D_FloatToU8(b),C2D_FloatToU8(a));
}

/** @brief Configures one corner of an image tint structure
 *  @param[in] tint Image tint structure
 *  @param[in] corner The corner of the image to tint
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_SetImageTint :: inline (tint: *C2D_ImageTint, corner: C2D_Corner, color: u32, blend: float) {
    tint.corners[corner].color = color;
    tint.corners[corner].blend = blend;
}

/** @brief Configures an image tint structure with the specified tint parameters applied to all corners
 *  @param[in] tint Image tint structure
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_PlainImageTint :: inline (tint: *C2D_ImageTint, color: u32, blend: float) {
    C2D_SetImageTint(tint, C2D_TopLeft,  color, blend);
    C2D_SetImageTint(tint, C2D_TopRight, color, blend);
    C2D_SetImageTint(tint, C2D_BotLeft,  color, blend);
    C2D_SetImageTint(tint, C2D_BotRight, color, blend);
}

/** @brief Configures an image tint structure to just apply transparency to the image
 *  @param[in] tint Image tint structure
 *  @param[in] alpha Alpha transparency value to apply to the image
 */
C2D_AlphaImageTint :: inline (tint: *C2D_ImageTint, alpha: float) {
    C2D_PlainImageTint(tint, C2D_Color32f(0.0, 0.0, 0.0, alpha), 0.0);
}

/** @brief Configures an image tint structure with the specified tint parameters applied to the top side (e.g. for gradients)
 *  @param[in] tint Image tint structure
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_TopImageTint :: inline (tint: *C2D_ImageTint, color: u32, blend: float) {
    C2D_SetImageTint(tint, C2D_TopLeft,  color, blend);
    C2D_SetImageTint(tint, C2D_TopRight, color, blend);
}

/** @brief Configures an image tint structure with the specified tint parameters applied to the bottom side (e.g. for gradients)
 *  @param[in] tint Image tint structure
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_BottomImageTint :: inline (tint: *C2D_ImageTint, color: u32, blend: float) {
    C2D_SetImageTint(tint, C2D_BotLeft,  color, blend);
    C2D_SetImageTint(tint, C2D_BotRight, color, blend);
}

/** @brief Configures an image tint structure with the specified tint parameters applied to the left side (e.g. for gradients)
 *  @param[in] tint Image tint structure
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_LeftImageTint :: inline (tint: *C2D_ImageTint, color: u32, blend: float) {
    C2D_SetImageTint(tint, C2D_TopLeft, color, blend);
    C2D_SetImageTint(tint, C2D_BotLeft, color, blend);
}

/** @brief Configures an image tint structure with the specified tint parameters applied to the right side (e.g. for gradients)
 *  @param[in] tint Image tint structure
 *  @param[in] color RGB tint color and Alpha transparency
 *  @param[in] blend Blending strength of the tint color (0.0~1.0)
 */
C2D_RightImageTint :: inline (tint: *C2D_ImageTint, color: u32, blend: float) {
    C2D_SetImageTint(tint, C2D_TopRight, color, blend);
    C2D_SetImageTint(tint, C2D_BotRight, color, blend);
}

/** @} */

/** @brief Initialize citro2d
*  @param[in] maxObjects Maximum number of 2D objects that can be drawn per frame.
*  @remarks Pass C2D_DEFAULT_MAX_OBJECTS as a starting point.
*  @returns true on success, false on failure
*/
C2D_Init :: (maxObjects: size_t) -> bool #foreign libcitro2d;

/** @brief Deinitialize citro2d */
C2D_Fini :: () -> void #foreign libcitro2d;

/** @brief Prepares the GPU for rendering 2D content
*  @remarks This needs to be done only once in the program if citro2d is the sole user of the GPU.
*/
C2D_Prepare :: () -> void #foreign libcitro2d;

/** @brief Ensures all 2D objects so far have been drawn */
C2D_Flush :: () -> void #foreign libcitro2d;

/** @brief Configures the size of the 2D scene.
*  @param[in] width The width of the scene, in pixels.
*  @param[in] height The height of the scene, in pixels.
*  @param[in] tilt Whether the scene is tilted like the 3DS's sideways screens.
*/
C2D_SceneSize :: (width: u32, height: u32, tilt: bool) -> void #foreign libcitro2d;

/** @brief Resets the model transformation matrix. */
C2D_ViewReset :: () -> void #foreign libcitro2d;

/** @brief Saves the current model transformation matrix.
* @param[out] matrix Pointer to save the current matrix to
*/
C2D_ViewSave :: (matrix: *C3D_Mtx) -> void #foreign libcitro2d;

/** @brief Restores a previously saved model transformation matrix.
* @param[in] matrix Pointer to matrix to restor
*/
C2D_ViewRestore :: (matrix: *C3D_Mtx) -> void #foreign libcitro2d;

/** @brief Translates everything drawn via the model matrix.
* @param[in] x Translation in the x direction
* @param[in] y Translation in the y direction
*/
C2D_ViewTranslate :: (x: float, y: float) -> void #foreign libcitro2d;

/** @brief Rotates everything drawn via the model matrix.
* @param[in] rotation Rotation in the counterclockwise direction in radians
*/
C2D_ViewRotate :: (rotation: float) -> void #foreign libcitro2d;

/** @brief Shears everything drawn via the model matrix.
* @param[in] x Shear factor in the x direction
* @param[in] y Shear factor in the y direction
*/
C2D_ViewShear :: (x: float, y: float) -> void #foreign libcitro2d;

/** @brief Scales everything drawn via the model matrix.
* @param[in] x Scale factor in the x direction
* @param[in] y Scale factor in the y direction
*/
C2D_ViewScale :: (x: float, y: float) -> void #foreign libcitro2d;

/** @brief Helper function to create a render target for a screen
*  @param[in] screen Screen (GFX_TOP or GFX_BOTTOM)
*  @param[in] side Side (GFX_LEFT or GFX_RIGHT)
*  @returns citro3d render target object
*/
C2D_CreateScreenTarget :: (screen: gfxScreen_t, side: gfx3dSide_t) -> *C3D_RenderTarget #foreign libcitro2d;

/** @brief Helper function to clear a rendertarget using the specified color
*  @param[in] target Render target to clear
*  @param[in] color 32-bit RGBA color value to fill the target with
*/
C2D_TargetClear :: (target: *C3D_RenderTarget, color: u32) -> void #foreign libcitro2d;

/** @brief Helper function to begin drawing a 2D scene on a render target
 *  @param[in] target Render target to draw the 2D scene to
 */
C2D_SceneBegin :: inline (target: *C3D_RenderTarget) {
    C2D_Flush();
    C3D_FrameDrawOn(target);
    C2D_SceneTarget(target);
}

/** @brief Configures the fading color
*  @param[in] color 32-bit RGBA color value to be used as the fading color (0 by default)
*  @remark The alpha component of the color is used as the strength of the fading color.
*          If alpha is zero, the fading color has no effect. If it is the highest value,
*          the rendered pixels will all have the fading color. Everything inbetween is
*          rendered as a blend of the original pixel color and the fading color.
*/
C2D_Fade :: (color: u32) -> void #foreign libcitro2d;

/** @brief Configures the formula used to calculate the tinted texture color
*  @param[in] mode Tinting mode
*  @remark Texture tinting works by linearly interpolating between the regular texture color
*          and the tinted texture color according to the blending strength parameter.
*          This function can be used to change how the tinted texture color is precisely
*          calculated, refer to \ref C2D_TintMode for a list of available tinting modes.
*/
C2D_SetTintMode :: (mode: C2D_TintMode) -> void #foreign libcitro2d;

/** @brief Draws an image using the GPU (variant accepting C2D_DrawParams)
*  @param[in] img Handle of the image to draw
*  @param[in] params Parameters with which to draw the image
*  @param[in] tint Tint parameters to apply to the image (optional, can be null)
*  @returns true on success, false on failure
*/
C2D_DrawImage :: (img: C2D_Image, params: *C2D_DrawParams, tint: *C2D_ImageTint) -> bool #foreign libcitro2d;

/** @brief Draws an image using the GPU (variant accepting position/scaling)
 *  @param[in] img Handle of the image to draw
 *  @param[in] x X coordinate at which to place the top left corner of the image
 *  @param[in] y Y coordinate at which to place the top left corner of the image
 *  @param[in] depth Depth value to draw the image with
 *  @param[in] tint Tint parameters to apply to the image (optional, can be null)
 *  @param[in] scaleX Horizontal scaling factor to apply to the image (optional, by default 1.0); negative values apply a horizontal flip
 *  @param[in] scaleY Vertical scaling factor to apply to the image (optional, by default 1.0); negative values apply a vertical flip
 */
C2D_DrawImageAt :: inline (img: C2D_Image, x: float, y: float, depth: float,
    tint: *C2D_ImageTint = null,
    scaleX: float = 1.0, scaleY: float = 1.0) -> bool
{
    params: C2D_DrawParams =
    .{
        .{ x, y, scaleX*img.subtex.width, scaleY*img.subtex.height },
        .{ 0.0, 0.0 },
        depth, 0.0
    };
    return C2D_DrawImage(img, *params, tint);
}

/** @brief Draws an image using the GPU (variant accepting position/scaling/rotation)
 *  @param[in] img Handle of the image to draw
 *  @param[in] x X coordinate at which to place the center of the image
 *  @param[in] y Y coordinate at which to place the center of the image
 *  @param[in] depth Depth value to draw the image with
 *  @param[in] angle Angle (in radians) to rotate the image by, counter-clockwise
 *  @param[in] tint Tint parameters to apply to the image (optional, can be null)
 *  @param[in] scaleX Horizontal scaling factor to apply to the image (optional, by default 1.0); negative values apply a horizontal flip
 *  @param[in] scaleY Vertical scaling factor to apply to the image (optional, by default 1.0); negative values apply a vertical flip
 */
C2D_DrawImageAtRotated :: inline (img: C2D_Image, x: float, y: float, depth: float, angle: float,
    tint: *C2D_ImageTint = null,
    scaleX: float = 1.0, scaleY: float = 1.0) -> bool
{
    params: C2D_DrawParams =
    .{
        .{ x, y, scaleX*img.subtex.width, scaleY*img.subtex.height },
        .{ (scaleX*img.subtex.width)/2.0, (scaleY*img.subtex.height)/2.0 },
        depth, angle
    };
    return C2D_DrawImage(img, *params, tint);
}

/** @brief Draws a plain triangle using the GPU
*  @param[in] x0 X coordinate of the first vertex of the triangle
*  @param[in] y0 Y coordinate of the first vertex of the triangle
*  @param[in] clr0 32-bit RGBA color of the first vertex of the triangle
*  @param[in] x1 X coordinate of the second vertex of the triangle
*  @param[in] y1 Y coordinate of the second vertex of the triangle
*  @param[in] clr1 32-bit RGBA color of the second vertex of the triangle
*  @param[in] x2 X coordinate of the third vertex of the triangle
*  @param[in] y2 Y coordinate of the third vertex of the triangle
*  @param[in] clr2 32-bit RGBA color of the third vertex of the triangle
*  @param[in] depth Depth value to draw the triangle with
*/
C2D_DrawTriangle :: (x0: float, y0: float, clr0: u32, x1: float, y1: float, clr1: u32, x2: float, y2: float, clr2: u32, depth: float) -> bool #foreign libcitro2d;

/** @brief Draws a plain line using the GPU
*  @param[in] x0 X coordinate of the first vertex of the line
*  @param[in] y0 Y coordinate of the first vertex of the line
*  @param[in] clr0 32-bit RGBA color of the first vertex of the line
*  @param[in] x1 X coordinate of the second vertex of the line
*  @param[in] y1 Y coordinate of the second vertex of the line
*  @param[in] clr1 32-bit RGBA color of the second vertex of the line
*  @param[in] thickness Thickness, in pixels, of the line
*  @param[in] depth Depth value to draw the line with
*/
C2D_DrawLine :: (x0: float, y0: float, clr0: u32, x1: float, y1: float, clr1: u32, thickness: float, depth: float) -> bool #foreign libcitro2d;

/** @brief Draws a plain rectangle using the GPU
*  @param[in] x X coordinate of the top-left vertex of the rectangle
*  @param[in] y Y coordinate of the top-left vertex of the rectangle
*  @param[in] z Z coordinate (depth value) to draw the rectangle with
*  @param[in] w Width of the rectangle
*  @param[in] h Height of the rectangle
*  @param[in] clr0 32-bit RGBA color of the top-left corner of the rectangle
*  @param[in] clr1 32-bit RGBA color of the top-right corner of the rectangle
*  @param[in] clr2 32-bit RGBA color of the bottom-left corner of the rectangle
*  @param[in] clr3 32-bit RGBA color of the bottom-right corner of the rectangle
*/
C2D_DrawRectangle :: (x: float, y: float, z: float, w: float, h: float, clr0: u32, clr1: u32, clr2: u32, clr3: u32) -> bool #foreign libcitro2d;

/** @brief Draws a plain rectangle using the GPU (with a solid color)
 *  @param[in] x X coordinate of the top-left vertex of the rectangle
 *  @param[in] y Y coordinate of the top-left vertex of the rectangle
 *  @param[in] z Z coordinate (depth value) to draw the rectangle with
 *  @param[in] w Width of the rectangle
 *  @param[in] h Height of the rectangle
 *  @param[in] clr 32-bit RGBA color of the rectangle
 */
C2D_DrawRectSolid :: inline (
    x: float, y: float, z: float, w: float, h: float,
    clr: u32) -> bool
{
    return C2D_DrawRectangle(x,y,z,w,h,clr,clr,clr,clr);
}

/** @brief Draws a ellipse using the GPU (with a solid color)
 *  @param[in] x X coordinate of the top-left vertex of the ellipse
 *  @param[in] y Y coordinate of the top-left vertex of the ellipse
 *  @param[in] z Z coordinate (depth value) to draw the ellipse with
 *  @param[in] w Width of the ellipse
 *  @param[in] h Height of the ellipse
 *  @param[in] clr 32-bit RGBA color of the ellipse
 *  @note Switching to and from "circle mode" internally requires an expensive state change. As such, the recommended usage of this feature is to draw all non-circular objects first, then draw all circular objects.
*/
C2D_DrawEllipseSolid :: inline (
    x: float, y: float, z: float, w: float, h: float,
    clr: u32) -> bool
{
    return C2D_DrawEllipse(x,y,z,w,h,clr,clr,clr,clr);
}

/** @brief Draws a circle (an ellipse with identical width and height) using the GPU
 *  @param[in] x X coordinate of the center of the circle
 *  @param[in] y Y coordinate of the center of the circle
 *  @param[in] z Z coordinate (depth value) to draw the ellipse with
 *  @param[in] radius Radius of the circle
 *  @param[in] clr0 32-bit RGBA color of the top-left corner of the ellipse
 *  @param[in] clr1 32-bit RGBA color of the top-right corner of the ellipse
 *  @param[in] clr2 32-bit RGBA color of the bottom-left corner of the ellipse
 *  @param[in] clr3 32-bit RGBA color of the bottom-right corner of the ellipse
 *  @note Switching to and from "circle mode" internally requires an expensive state change. As such, the recommended usage of this feature is to draw all non-circular objects first, then draw all circular objects.
*/
C2D_DrawCircle :: inline (
    x: float, y: float, z: float, radius: float,
    clr0: u32, clr1: u32, clr2: u32, clr3: u32) -> bool
{
    return C2D_DrawEllipse(
        x - radius,y - radius,z,radius*2,radius*2,
        clr0,clr1,clr2,clr3);
}

/** @brief Draws a circle (an ellipse with identical width and height) using the GPU (with a solid color)
 *  @param[in] x X coordinate of the center of the circle
 *  @param[in] y Y coordinate of the center of the circle
 *  @param[in] z Z coordinate (depth value) to draw the ellipse with
 *  @param[in] radius Radius of the circle
 *  @param[in] clr 32-bit RGBA color of the ellipse
 *  @note Switching to and from "circle mode" internally requires an expensive state change. As such, the recommended usage of this feature is to draw all non-circular objects first, then draw all circular objects.
*/
C2D_DrawCircleSolid :: inline (
    x: float, y: float, z: float, radius: float,
    clr: u32) -> bool
{
    return C2D_DrawCircle(x,y,z,radius,clr,clr,clr,clr);
}

/** @brief Draws an ellipse using the GPU
*  @param[in] x X coordinate of the top-left vertex of the ellipse
*  @param[in] y Y coordinate of the top-left vertex of the ellipse
*  @param[in] z Z coordinate (depth value) to draw the ellipse with
*  @param[in] w Width of the ellipse
*  @param[in] h Height of the ellipse
*  @param[in] clr0 32-bit RGBA color of the top-left corner of the ellipse
*  @param[in] clr1 32-bit RGBA color of the top-right corner of the ellipse
*  @param[in] clr2 32-bit RGBA color of the bottom-left corner of the ellipse
*  @param[in] clr3 32-bit RGBA color of the bottom-right corner of the ellipse
*  @note Switching to and from "circle mode" internally requires an expensive state change. As such, the recommended usage of this feature is to draw all non-circular objects first, then draw all circular objects.
*/
C2D_DrawEllipse :: (x: float, y: float, z: float, w: float, h: float, clr0: u32, clr1: u32, clr2: u32, clr3: u32) -> bool #foreign libcitro2d;

C2D_Font :: *C2D_Font_s;

/** @brief Load a font from a file
* @param[in] filename Name of the font file (.bcfnt)
* @returns Font handle
* @retval NULL Error
*/
C2D_FontLoad :: (filename: *u8) -> C2D_Font #foreign libcitro2d;

/** @brief Load a font from memory
* @param[in] data Data to load
* @param[in] size Size of the data to load
* @returns Font handle
* @retval NULL Error
*/
C2D_FontLoadFromMem :: (data: *void, size: size_t) -> C2D_Font #foreign libcitro2d;

/** @brief Load a font from file descriptor
* @param[in] fd File descriptor used to load data
* @returns Font handle
* @retval NULL Error
*/
C2D_FontLoadFromFD :: (fd: s32) -> C2D_Font #foreign libcitro2d;

/** @brief Load font from stdio file handle
*  @param[in] f File handle used to load data
*  @returns Font handle
*  @retval NULL Error
*/
C2D_FontLoadFromHandle :: (f: *FILE) -> C2D_Font #foreign libcitro2d;

/** @brief Load corresponding font from system archive
*  @param[in] region Region to get font from
*  @returns Font handle
*  @retval NULL Error
*  @remark JPN, USA, EUR, and AUS all use the same font.
*/
C2D_FontLoadSystem :: (region: CFG_Region) -> C2D_Font #foreign libcitro2d;

/** @brief Free a font
* @param[in] font Font handle
*/
C2D_FontFree :: (font: C2D_Font) -> void #foreign libcitro2d;

/** @brief Set a font's texture filter
* @param[in] font Font handle
* @param[in] magFilter the magnification filter
* @param[in] minFilter the minification filter
*/
C2D_FontSetFilter :: (font: C2D_Font, magFilter: GPU_TEXTURE_FILTER_PARAM, minFilter: GPU_TEXTURE_FILTER_PARAM) -> void #foreign libcitro2d;

/** @brief Find the glyph index of a codepoint, or returns the default
* @param[in] font Font to search, or NULL for system font
* @param[in] codepoint Codepoint to search for
* @returns Glyph index
* @retval font->cfnt->finf.alterCharIndex The codepoint does not exist in the font
*/
C2D_FontGlyphIndexFromCodePoint :: (font: C2D_Font, codepoint: u32) -> s32 #foreign libcitro2d;

/** @brief Get character width info for a given index
* @param[in] font Font to read from, or NULL for system font
* @param[in] glyphIndex Index to get the width of
* @returns Width info for glyph
*/
C2D_FontGetCharWidthInfo :: (font: C2D_Font, glyphIndex: s32) -> *charWidthInfo_s #foreign libcitro2d;

/** @brief Calculate glyph position of given index
* @param[in] font Font to read from, or NULL for system font
* @param[out] out Glyph position
* @param[in] glyphIndex Index to get position of
* @param[in] flags Misc flags
* @param[in] scaleX Size to scale in X
* @param[in] scaleY Size to scale in Y
*/
C2D_FontCalcGlyphPos :: (font: C2D_Font, out: *fontGlyphPos_s, glyphIndex: s32, flags: u32, scaleX: float, scaleY: float) -> void #foreign libcitro2d;

/** @brief Get the font info structure associated with the font
* @param[in] font Font to read from, or NULL for the system font
* @returns FINF associated with the font
*/
C2D_FontGetInfo :: (font: C2D_Font) -> *FINF_s #foreign libcitro2d;

C2D_TextBuf_s :: struct {}
C2D_TextBuf :: *C2D_TextBuf_s;

/// Text object.
C2D_Text :: struct {
    buf:   C2D_TextBuf; ///< Buffer associated with the text.
    begin: size_t; ///< Reserved for internal use.
    end:   size_t; ///< Reserved for internal use.
    width: float; ///< Width of the text in pixels, according to 1x scale metrics.
    lines: u32; ///< Number of lines in the text.
    words: u32; ///< Number of words in the text.
    font:  C2D_Font; ///< Font used to draw the text, or NULL for system font
}

C2D :: enum u8 {
    AtBaseline     :: 1;
    WithColor      :: 2;
    AlignLeft      :: 0;
    AlignRight     :: 4;
    AlignCenter    :: 8;
    AlignJustified :: 12;
    AlignMask      :: 12;
    WordWrap       :: 16;
}

/** @brief Creates a new text buffer.
*  @param[in] maxGlyphs Maximum number of glyphs that can be stored in the buffer.
*  @returns Text buffer handle (or NULL on failure).
*/
C2D_TextBufNew :: (maxGlyphs: size_t) -> C2D_TextBuf #foreign libcitro2d;

/** @brief Resizes a text buffer.
*  @param[in] buf Text buffer to resize.
*  @param[in] maxGlyphs Maximum number of glyphs that can be stored in the buffer.
*  @returns New text buffer handle (or NULL on failure).
*  @remarks If successful, old text buffer handle becomes invalid.
*/
C2D_TextBufResize :: (buf: C2D_TextBuf, maxGlyphs: size_t) -> C2D_TextBuf #foreign libcitro2d;

/** @brief Deletes a text buffer.
*  @param[in] buf Text buffer handle.
*  @remarks This also invalidates all text objects previously created with this buffer.
*/
C2D_TextBufDelete :: (buf: C2D_TextBuf) -> void #foreign libcitro2d;

/** @brief Clears all stored text in a buffer.
*  @param[in] buf Text buffer handle.
*/
C2D_TextBufClear :: (buf: C2D_TextBuf) -> void #foreign libcitro2d;

/** @brief Retrieves the number of glyphs stored in a text buffer.
*  @param[in] buf Text buffer handle.
*  @returns The number of glyphs.
*/
C2D_TextBufGetNumGlyphs :: (buf: C2D_TextBuf) -> size_t #foreign libcitro2d;

/** @brief Parses and adds a single line of text to a text buffer.
*  @param[out] text Pointer to text object to store information in.
*  @param[in] buf Text buffer handle.
*  @param[in] str String to parse.
*  @param[in] lineNo Line number assigned to the text (used to calculate vertical position).
*  @remarks Whitespace doesn't add any glyphs to the text buffer and is thus "free".
*  @returns On success, a pointer to the character on which string processing stopped, which
*           can be a newline ('\n'; indicating that's where the line ended), the null character
*           ('\0'; indicating the end of the string was reached), or any other character
*           (indicating the text buffer is full and no more glyphs can be added).
*           On failure, NULL.
*/
C2D_TextParseLine :: (text: *C2D_Text, buf: C2D_TextBuf, str: *u8, lineNo: u32) -> *u8 #foreign libcitro2d;

/** @brief Parses and adds a single line of text to a text buffer.
*  @param[out] text Pointer to text object to store information in.
*  @param[in] font Font to get glyphs from, or null for system font
*  @param[in] buf Text buffer handle.
*  @param[in] str String to parse.
*  @param[in] lineNo Line number assigned to the text (used to calculate vertical position).
*  @remarks Whitespace doesn't add any glyphs to the text buffer and is thus "free".
*  @returns On success, a pointer to the character on which string processing stopped, which
*           can be a newline ('\n'; indicating that's where the line ended), the null character
*           ('\0'; indicating the end of the string was reached), or any other character
*           (indicating the text buffer is full and no more glyphs can be added).
*           On failure, NULL.
*/
C2D_TextFontParseLine :: (text: *C2D_Text, font: C2D_Font, buf: C2D_TextBuf, str: *u8, lineNo: u32) -> *u8 #foreign libcitro2d;

/** @brief Parses and adds arbitrary text (including newlines) to a text buffer.
*  @param[out] text Pointer to text object to store information in.
*  @param[in] buf Text buffer handle.
*  @param[in] str String to parse.
*  @remarks Whitespace doesn't add any glyphs to the text buffer and is thus "free".
*  @returns On success, a pointer to the character on which string processing stopped, which
*           can be the null character ('\0'; indicating the end of the string was reached),
*           or any other character (indicating the text buffer is full and no more glyphs can be added).
*           On failure, NULL.
*/
C2D_TextParse :: (text: *C2D_Text, buf: C2D_TextBuf, str: *u8) -> *u8 #foreign libcitro2d;

/** @brief Parses and adds arbitrary text (including newlines) to a text buffer.
*  @param[out] text Pointer to text object to store information in.
*  @param[in] font Font to get glyphs from, or null for system font
*  @param[in] buf Text buffer handle.
*  @param[in] str String to parse.
*  @remarks Whitespace doesn't add any glyphs to the text buffer and is thus "free".
*  @returns On success, a pointer to the character on which string processing stopped, which
*           can be the null character ('\0'; indicating the end of the string was reached),
*           or any other character (indicating the text buffer is full and no more glyphs can be added).
*           On failure, NULL.
*/
C2D_TextFontParse :: (text: *C2D_Text, font: C2D_Font, buf: C2D_TextBuf, str: *u8) -> *u8 #foreign libcitro2d;

/** @brief Optimizes a text object in order to be drawn more efficiently.
*  @param[in] text Pointer to text object.
*/
C2D_TextOptimize :: (text: *C2D_Text) -> void #foreign libcitro2d;

/** @brief Retrieves the total dimensions of a text object.
*  @param[in] text Pointer to text object.
*  @param[in] scaleX Horizontal size of the font. 1.0 corresponds to the native size of the font.
*  @param[in] scaleY Vertical size of the font. 1.0 corresponds to the native size of the font.
*  @param[out] outWidth (optional) Variable in which to store the width of the text.
*  @param[out] outHeight (optional) Variable in which to store the height of the text.
*/
C2D_TextGetDimensions :: (text: *C2D_Text, scaleX: float, scaleY: float, outWidth: *float, outHeight: *float) -> void #foreign libcitro2d;

/** @brief Draws text using the GPU.
*  @param[in] text Pointer to text object.
*  @param[in] flags Text drawing flags.
*  @param[in] x Horizontal position to draw the text on.
*  @param[in] y Vertical position to draw the text on. If C2D_AtBaseline is not specified (default), this
*               is the top left corner of the block of text; otherwise this is the position of the baseline
*               of the first line of text.
*  @param[in] z Depth value of the text. If unsure, pass 0.0.
*  @param[in] scaleX Horizontal size of the font. 1.0 corresponds to the native size of the font.
*  @param[in] scaleY Vertical size of the font. 1.0 corresponds to the native size of the font.
*  @remarks The default 3DS system font has a glyph height of 30px, and the baseline is at 25px.
*/
C2D_DrawText :: (text: *C2D_Text, flags: u32, x: float, y: float, z: float, scaleX: float, scaleY: float, __args: ..Any) -> void #foreign libcitro2d;

C2D_SpriteSheet_s :: struct {}
C2D_SpriteSheet :: *C2D_SpriteSheet_s;

/** @brief Load a sprite sheet from file
*  @param[in] filename Name of the sprite sheet file (.t3x)
*  @returns Sprite sheet handle
*  @retval NULL Error
*/
C2D_SpriteSheetLoad :: (filename: *u8) -> C2D_SpriteSheet #foreign libcitro2d;

/** @brief Load a sprite sheet from memory
*  @param[in] data Data to load
*  @param[in] size Size of the data to load
*  @returns Sprite sheet handle
*  @retval NULL Error
*/
C2D_SpriteSheetLoadFromMem :: (data: *void, size: size_t) -> C2D_SpriteSheet #foreign libcitro2d;

/** @brief Load sprite sheet from file descriptor
*  @param[in] fd File descriptor used to load data
*  @returns Sprite sheet handle
*  @retval NULL Error
*/
C2D_SpriteSheetFromFD :: (fd: s32) -> C2D_SpriteSheet #foreign libcitro2d;

/** @brief Load sprite sheet from stdio file handle
*  @param[in] f File handle used to load data
*  @returns Sprite sheet handle
*  @retval NULL Error
*/
C2D_SpriteSheetLoadFromHandle :: (f: *FILE) -> C2D_SpriteSheet #foreign libcitro2d;

/** @brief Free a sprite sheet
*  @param[in] sheet Sprite sheet handle
*/
C2D_SpriteSheetFree :: (sheet: C2D_SpriteSheet) -> void #foreign libcitro2d;

/** @brief Retrieves the number of sprites in the specified sprite sheet
*  @param[in] sheet Sprite sheet handle
*  @returns Number of sprites
*/
C2D_SpriteSheetCount :: (sheet: C2D_SpriteSheet) -> size_t #foreign libcitro2d;

/** @brief Retrieves the specified image from the specified sprite sheet
*  @param[in] sheet Sprite sheet handle
*  @param[in] index Index of the image to retrieve
*  @returns Image object
*/
C2D_SpriteSheetGetImage :: (sheet: C2D_SpriteSheet, index: size_t) -> C2D_Image #foreign libcitro2d;

C2D_Sprite :: struct {
    image:  C2D_Image;
    params: C2D_DrawParams;
}

/** @defgroup Sprite Sprite functions
 *  @{
 */

/** @brief Initializes a sprite from an image
 *  @param[in] Pointer to sprite
 *  @param[in] image Image to use
 */
C2D_SpriteFromImage :: inline (sprite: *C2D_Sprite, image: C2D_Image) {
    sprite.image           = image;
    sprite.params.pos.x    = 0.0;
    sprite.params.pos.y    = 0.0;
    sprite.params.pos.w    = image.subtex.width;
    sprite.params.pos.h    = image.subtex.height;
    sprite.params.center.x = 0.0;
    sprite.params.center.y = 0.0;
    sprite.params.angle    = 0.0;
    sprite.params.depth    = 0.0;
}

/** @brief Initializes a sprite from an image stored in a sprite sheet
 *  @param[in] Pointer to sprite
 *  @param[in] sheet Sprite sheet handle
 *  @param[in] index Index of the image inside the sprite sheet
 */
C2D_SpriteFromSheet :: inline (sprite: *C2D_Sprite, sheet: C2D_SpriteSheet, index: size_t) {
    C2D_SpriteFromImage(sprite, C2D_SpriteSheetGetImage(sheet, index));
}

/** @brief Scale sprite (relative)
 *  @param[in] sprite Pointer to sprite
 *  @param[in] x      X scale (negative values flip the sprite horizontally)
 *  @param[in] y      Y scale (negative values flip the sprite vertically)
 */
C2D_SpriteScale :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    sprite.params.pos.w *= x;
    sprite.params.pos.h *= y;
    sprite.params.center.x *= x;
    sprite.params.center.y *= x;
}

/** @brief Rotate sprite (relative)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] radians Amount to rotate in radians
 */
C2D_SpriteRotate :: inline (sprite: *C2D_Sprite, radians: float) {
    sprite.params.angle += radians;
}

/** @brief Rotate sprite (relative)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] degrees Amount to rotate in degrees
 */
C2D_SpriteRotateDegrees :: inline (sprite: *C2D_Sprite, degrees: float) {
    C2D_SpriteRotate(sprite, C3D_AngleFromDegrees(degrees));
}

/** @brief Move sprite (relative)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] x       X translation
 *  @param[in] y       Y translation
 */
C2D_SpriteMove :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    sprite.params.pos.x += x;
    sprite.params.pos.y += y;
}

/** @brief Scale sprite (absolute)
 *  @param[in] sprite Pointer to sprite
 *  @param[in] x      X scale (negative values flip the sprite horizontally)
 *  @param[in] y      Y scale (negative values flip the sprite vertically)
 */
C2D_SpriteSetScale :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    oldCenterX: float = sprite.params.center.x / sprite.params.pos.w;
    oldCenterY: float = sprite.params.center.y / sprite.params.pos.h;
    sprite.params.pos.w = x*sprite.image.subtex.width;
    sprite.params.pos.h = y*sprite.image.subtex.height;
    sprite.params.center.x = fabsf(oldCenterX*sprite.params.pos.w);
    sprite.params.center.y = fabsf(oldCenterY*sprite.params.pos.h);
}

/** @brief Rotate sprite (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] radians Amount to rotate in radians
 */
C2D_SpriteSetRotation :: inline (sprite: *C2D_Sprite, radians: float) {
    sprite.params.angle = radians;
}

/** @brief Rotate sprite (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] degrees Amount to rotate in degrees
 */
C2D_SpriteSetRotationDegrees :: inline (sprite: *C2D_Sprite, degrees: float) {
    C2D_SpriteSetRotation(sprite, C3D_AngleFromDegrees(degrees));
}

/** @brief Set the center of a sprite in values independent of the sprite size (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] x       X position of the center (0.0 through 1.0)
 *  @param[in] y       Y position of the center (0.0 through 1.0)
 */
C2D_SpriteSetCenter :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    sprite.params.center.x = x*sprite.params.pos.w;
    sprite.params.center.y = y*sprite.params.pos.h;
}

/** @brief Set the center of a sprite in terms of pixels (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] x       X position of the center (in pixels)
 *  @param[in] y       Y position of the center (in pixels)
 */
C2D_SpriteSetCenterRaw :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    sprite.params.center.x = x;
    sprite.params.center.y = y;
}

/** @brief Move sprite (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] x       X position
 *  @param[in] y       Y position
 */
C2D_SpriteSetPos :: inline (sprite: *C2D_Sprite, x: float, y: float) {
    sprite.params.pos.x = x;
    sprite.params.pos.y = y;
}

/** @brief Sets the depth level of a sprite (absolute)
 *  @param[in] sprite  Pointer to sprite
 *  @param[in] depth   Depth value
 */
C2D_SpriteSetDepth :: inline (sprite: *C2D_Sprite, depth: float) {
    sprite.params.depth = depth;
}

/** @brief Draw sprite
 *  @param[in] sprite Sprite to draw
 */
C2D_DrawSprite :: inline (sprite: *C2D_Sprite) -> bool {
    return C2D_DrawImage(sprite.image, *sprite.params, null);
}

/** @brief Draw sprite with color tinting
 *  @param[in] sprite Sprite to draw
 *  @param[in] tint Color tinting parameters to apply to the sprite
 */
C2D_DrawSpriteTinted :: inline (sprite: *C2D_Sprite, tint: *C2D_ImageTint) -> bool {
    return C2D_DrawImage(sprite.image, *sprite.params, tint);
}

/** @} */

//
// citro2d internals
//

C2Di_Vertex :: struct {
    pos:      [3] float;
    texcoord: [2] float;
    ptcoord:  [2] float;
    color:    u32;
}

C2Di_Context :: struct {
    shader:        *DVLB_s;
    program:       shaderProgram_s #align 4;
    attrInfo:      C3D_AttrInfo;
    bufInfo:       C3D_BufInfo;
    ptBlend:       C3D_ProcTex;
    ptCircle:      C3D_ProcTex;
    ptBlendLut:    C3D_ProcTexLut;
    ptCircleLut:   C3D_ProcTexLut;
    sceneW:        u32;
    sceneH:        u32;
    vtxBuf:        *C2Di_Vertex;
    idxBuf:        *u16 #align 4;
    vtxBufSize:    size_t;
    vtxBufPos:     size_t;
    idxBufSize:    size_t;
    idxBufPos:     size_t;
    idxBufLastPos: size_t;
    flags:         u32;
    projMtx:       C3D_Mtx;
    mdlvMtx:       C3D_Mtx;
    curTex:        *C3D_Tex;
    fadeClr:       u32;
}

C2DiF :: enum_flags u32 {
    Active          :: 1;
    DirtyProj       :: 2;
    DirtyMdlv       :: 4;
    DirtyTex        :: 8;
    DirtyMode       :: 16;
    DirtyFade       :: 32;

    Mode_Shift      :: 8;
    Mode_Mask       :: 0xf << Mode_Shift;
    Mode_Solid      :: 0   << Mode_Shift;
    Mode_Circle     :: 1   << Mode_Shift;
    Mode_Text       :: 2   << Mode_Shift;
    Mode_ImageSolid :: 3   << Mode_Shift;
    Mode_ImageMult  :: 4   << Mode_Shift;
    Mode_ImageLuma  :: 5   << Mode_Shift;

    ProcTex_Shift  :: 12;
    ProcTex_Mask   :: 0xf << ProcTex_Shift;
    ProcTex_None   :: 0   << ProcTex_Shift;
    ProcTex_Blend  :: 1   << ProcTex_Shift;
    ProcTex_Circle :: 2   << ProcTex_Shift;

    TintMode_Shift :: 16;
    TintMode_Mask  :: 0xf << TintMode_Shift;

    DirtyAny :: DirtyProj | DirtyMdlv | DirtyTex | DirtyMode | DirtyFade;
}

C2D_Font_s :: struct {
    cfnt:        *CFNT_s;
    glyphSheets: *C3D_Tex #align 4;
    textScale:   float;
}

C2Di_GetContext :: inline () -> *C2Di_Context {
    __C2Di_Context: C2Di_Context #elsewhere;
    return *__C2Di_Context;
}

C2Di_SetMode :: inline (mode: u32) -> void {
    ctx := C2Di_GetContext();
    mode &= C2DiF_Mode_Mask;
    if (ctx.flags & .Mode_Mask) != mode {
        ctx.flags = .DirtyMode | (ctx.flags &~ .Mode_Mask) | mode;
    }
}

C2Di_SetTex :: inline (tex: *C3D_Tex) -> void {
    ctx := C2Di_GetContext();
    if tex != ctx.curTex {
        ctx.flags |= .DirtyTex;
        ctx.curTex = tex;
    }
}

C2Di_Quad :: struct {
    topLeft:  [2] float;
    topRight: [2] float;
    botLeft:  [2] float;
    botRight: [2] float;
}

C2Di_CalcQuad :: (quad_t: *C2Di_Quad, params: *C2D_DrawParams) -> void #foreign libcitro2d;
C2Di_AppendTri :: () -> void #foreign libcitro2d;
C2Di_AppendQuad :: () -> void #foreign libcitro2d;
C2Di_AppendVtx :: (x: float, y: float, z: float, u: float, v: float, ptx: float, pty: float, color: u32) -> void #foreign libcitro2d;
C2Di_FlushVtxBuf :: () -> void #foreign libcitro2d;
C2Di_Update :: () -> void #foreign libcitro2d;

#scope_file

libctru :: #foreign_system_library,no_dll "libctru";
libcitro3d :: #foreign_system_library,no_dll "libcitro3d";
libcitro2d :: #foreign_system_library,no_dll "libcitro2d";
