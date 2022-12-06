//
// Jai bindings for citro3d
// Created with help of Bindings_Generator
//

#import,file "libctru.jai";
#import "Math";

M_PI  :: 3.14159265358979;
M_TAU :: 6.28318530717958647692528676655900576;

/**
 * @brief Convert an angle from revolutions to radians
 * @param[in_] _angle Proportion of a full revolution
 * @return Angle in_ radians
 */
C3D_Angle :: inline (_angle: $T) -> T {
    return _angle * M_TAU;
}

/**
 * @brief Convert an angle from degrees to radians
 * @param[in_] _angle Angle in_ degrees
 * @return Angle in_ radians
 */
C3D_AngleFromDegrees :: inline (_angle: $T) -> T {
    return _angle * M_TAU / 360.0;
}

C3D_AspectRatioTop :: 400.0 / 240.0;
C3D_AspectRatioBot :: 320.0 / 240.0;

C3D_MTXSTACK_SIZE :: 8;

C3D_FVUNIF_COUNT :: 96;
C3D_IVUNIF_COUNT :: 4;

C3D_DEFAULT_CMDBUF_SIZE :: 0x40000;

C3D_IVec :: u32;

IVec_Pack :: inline (x: u8, y: u8, z: u8, w: u8) -> C3D_IVec {
    return cast(u32)x | (cast(u32)y << 8) | (cast(u32)z << 16) | (cast(u32)w << 24);
}

/**
* @struct C3D_FVec
* @brief Float vector
*
* Matches PICA layout
*/
C3D_FVec :: union {
    /**
    * @brief Vector access
    */
    struct {
        w: float; ///< W-component
        z: float; ///< Z-component
        y: float; ///< Y-component
        x: float; ///< X-component
    }
    /**
    * @brief Quaternion access
    */
    struct {
        r: float; ///< Real component
        k: float; ///< K-component
        j: float; ///< J-component
        i: float; ///< I-component
    }
    /**
    * @brief Raw access
    */
    c: [4] float;
}

/**
* @struct C3D_FQuat
* @brief Float quaternion. See @ref C3D_FVec.
*/
C3D_FQuat :: C3D_FVec;

/**
* @struct C3D_Mtx
* @brief Row-major 4x4 matrix
*/
C3D_Mtx :: union {
    r: [4] C3D_FVec; ///< Rows are vectors
    m: [16] float; ///< Raw access
}

/**
 * @name Vector Math
 * @{
 */

/**
 * @brief Create a new FVec4
 * @param[in_] x X-component
 * @param[in_] y Y-component
 * @param[in_] z Z-component
 * @param[in_] w W-component
 * @return New FVec4
 */
FVec4_New :: inline (x: float, y: float, z: float, w: float) -> C3D_FVec {
    return .{w=w, z=z, y=y, x=x};
}

/**
 * @brief Add two FVec4s
 * @param[in_] lhs Augend
 * @param[in_] rhs Addend
 * @return lhs+rhs (sum)
 */
FVec4_Add :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> C3D_FVec {
    // component-wise addition
    return FVec4_New(lhs.x+rhs.x, lhs.y+rhs.y, lhs.z+rhs.z, lhs.w+rhs.w);
}

/**
 * @brief Subtract two FVec4s
 * @param[in_] lhs Minuend
 * @param[in_] rhs Subtrahend
 * @return lhs-rhs (difference)
 */
FVec4_Subtract :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> C3D_FVec {
    // component-wise subtraction
    return FVec4_New(lhs.x-rhs.x, lhs.y-rhs.y, lhs.z-rhs.z, lhs.w-rhs.w);
}

/**
 * @brief Negate a FVec4
 * @note This is equivalent to `FVec4_Scale(v, -1)`
 * @param[in_] v Vector to negate
 * @return -v
 */
FVec4_Negate :: inline (v: C3D_FVec) -> C3D_FVec {
    // component-wise negation
    return FVec4_New(-v.x, -v.y, -v.z, -v.w);
}

/**
 * @brief Scale a FVec4
 * @param[in_] v Vector to scale
 * @param[in_] s Scale factor
 * @return v*s
 */
FVec4_Scale :: inline (v: C3D_FVec, s: float) -> C3D_FVec {
    // component-wise scaling
    return FVec4_New(v.x*s, v.y*s, v.z*s, v.w*s);
}

/**
 * @brief Perspective divide
 * @param[in_] v Vector to divide
 * @return v/v.w
 */
FVec4_PerspDivide :: inline (v: C3D_FVec) -> C3D_FVec {
    // divide by w
    return FVec4_New(v.x/v.w, v.y/v.w, v.z/v.w, 1.0);
}

/**
 * @brief Dot product of two FVec4s
 * @param[in_] lhs Left-side FVec4
 * @param[in_] rhs Right-side FVec4
 * @return lhs∙rhs
 */
FVec4_Dot :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> float {
    // A∙B = sum of component-wise products
    return lhs.x*rhs.x + lhs.y*rhs.y + lhs.z*rhs.z + lhs.w*rhs.w;
}

/**
 * @brief Magnitude of a FVec4
 * @param[in_] v Vector
 * @return ‖v‖
 */
FVec4_Magnitude :: inline (v: C3D_FVec) -> float {
    // ‖v‖ = √(v∙v)
    return sqrt(FVec4_Dot(v,v));
}

/**
 * @brief Normalize a FVec4
 * @param[in_] v FVec4 to normalize
 * @return v/‖v‖
 */
FVec4_Normalize :: inline (v: C3D_FVec) -> C3D_FVec {
    // get vector magnitude
    m := FVec4_Magnitude(v);

    // scale by inverse magnitude to get a unit vector
    return FVec4_New(v.x/m, v.y/m, v.z/m, v.w/m);
}

/**
 * @brief Create a new FVec3
 * @param[in_] x X-component
 * @param[in_] y Y-component
 * @param[in_] z Z-component
 * @return New FVec3
 */
FVec3_New :: inline (x: float, y: float, z: float) -> C3D_FVec {
    return FVec4_New(x, y, z, 0.0);
}

/**
 * @brief Dot product of two FVec3s
 * @param[in_] lhs Left-side FVec3
 * @param[in_] rhs Right-side FVec3
 * @return lhs∙rhs
 */
FVec3_Dot :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> float {
    // A∙B = sum of component-wise products
    return lhs.x*rhs.x + lhs.y*rhs.y + lhs.z*rhs.z;
}

/**
 * @brief Magnitude of a FVec3
 * @param[in_] v Vector
 * @return ‖v‖
 */
FVec3_Magnitude :: inline (v: C3D_FVec) -> float {
    // ‖v‖ = √(v∙v)
    return sqrt(FVec3_Dot(v,v));
}

/**
 * @brief Normalize a FVec3
 * @param[in_] v FVec3 to normalize
 * @return v/‖v‖
 */
FVec3_Normalize :: inline (v: C3D_FVec) -> C3D_FVec {
    // get vector magnitude
    m := FVec3_Magnitude(v);

    // scale by inverse magnitude to get a unit vector
    return FVec3_New(v.x/m, v.y/m, v.z/m);
}

/**
 * @brief Add two FVec3s
 * @param[in_] lhs Augend
 * @param[in_] rhs Addend
 * @return lhs+rhs (sum)
 */
FVec3_Add :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> C3D_FVec {
    // component-wise addition
    return FVec3_New(lhs.x+rhs.x, lhs.y+rhs.y, lhs.z+rhs.z);
}

/**
 * @brief Subtract two FVec3s
 * @param[in_] lhs Minuend
 * @param[in_] rhs Subtrahend
 * @return lhs-rhs (difference)
 */
FVec3_Subtract :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> C3D_FVec {
    // component-wise subtraction
    return FVec3_New(lhs.x-rhs.x, lhs.y-rhs.y, lhs.z-rhs.z);
}

/**
 * @brief Distance between two 3D points
 * @param[in_] lhs Relative origin
 * @param[in_] rhs Relative point of interest
 * @return ‖lhs-rhs‖
 */
FVec3_Distance :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> float {
                // distance = ‖lhs-rhs‖
    return FVec3_Magnitude(FVec3_Subtract(lhs, rhs));
}

/**
 * @brief Scale a FVec3
 * @param[in_] v Vector to scale
 * @param[in_] s Scale factor
 * @return v*s
 */
FVec3_Scale :: inline (v: C3D_FVec, s: float) -> C3D_FVec {
    // component-wise scaling
    return FVec3_New(v.x*s, v.y*s, v.z*s);
}

/**
 * @brief Negate a FVec3
 * @note This is equivalent to `FVec3_Scale(v, -1)`
 * @param[in_] v Vector to negate
 * @return -v
 */
FVec3_Negate :: inline (v: C3D_FVec) -> C3D_FVec {
    // component-wise negation
    return FVec3_New(-v.x, -v.y, -v.z);
}

/**
 * @brief Cross product of two FVec3s
 * @note This returns a pseudo-vector which is perpendicular to the plane
 *       spanned by the two input vectors.
 * @param[in_] lhs Left-side FVec3
 * @param[in_] rhs Right-side FVec3
 * @return lhs×rhs
 */
FVec3_Cross :: inline (lhs: C3D_FVec, rhs: C3D_FVec) -> C3D_FVec {
    // A×B = (AyBz - AzBy, AzBx - AxBz, AxBy - AyBx)
    return FVec3_New(lhs.y*rhs.z - lhs.z*rhs.y, lhs.z*rhs.x - lhs.x*rhs.z, lhs.x*rhs.y - lhs.y*rhs.x);
}
/** @} */


/**
 * @name Matrix Math
 * @note All matrices are 4x4 unless otherwise noted.
 * @{
 */

/**
 * @brief Zero matrix
 * @param[out_] out_ Matrix to zero
 */
Mtx_Zeros :: inline (out_: *C3D_Mtx) {
    memset(out_, 0, size_of(C3D_Mtx));
}

/**
 * @brief Copy a matrix
 * @param[out_] out_ Output matrix
 * @param[in_]  in_  Input matrix
 */
Mtx_Copy :: inline (out_: *C3D_Mtx, in_: *C3D_Mtx) {
    *out_ = *in_;
}

/**
 * @brief Creates a matrix with the diagonal using the given parameters.
 * @param[out_]  out_    Output matrix.
 * @param[in_]   x      The X component.
 * @param[in_]   y      The Y component.
 * @param[in_]   z      The Z component.
 * @param[in_]   w      The W component.
 */
Mtx_Diagonal :: inline (out_: *C3D_Mtx, x: float, y: float, z: float, w: float) {
    Mtx_Zeros(out_);
    out_.r[0].x = x;
    out_.r[1].y = y;
    out_.r[2].z = z;
    out_.r[3].w = w;
}

/**
 * @brief Identity matrix
 * @param[out_] out_ Matrix to fill
 */
Mtx_Identity :: inline (out_: *C3D_Mtx) {
    Mtx_Diagonal(out_, 1.0, 1.0, 1.0, 1.0);
}

/**
 * @brief Matrix addition
 * @param[out_]   out_    Output matrix.
 * @param[in_]    lhs    Left matrix.
 * @param[in_]    rhs    Right matrix.
 * @return lhs+rhs (sum)
 */
Mtx_Add :: inline (out_: *C3D_Mtx, lhs: *C3D_Mtx, rhs: *C3D_Mtx) {
    for 0..15 {
        out_.m[it] = lhs.m[it] + rhs.m[it];
    }
}

/**
 * @brief Matrix subtraction
 * @param[out_]   out_    Output matrix.
 * @param[in_]    lhs    Left matrix.
 * @param[in_]    rhs    Right matrix.
 * @return lhs-rhs (difference)
 */
Mtx_Subtract :: inline (out_: *C3D_Mtx, lhs: *C3D_Mtx, rhs: *C3D_Mtx) {
    for 0..15 {
        out_.m[it] = lhs.m[it] - rhs.m[it];
    }
}

/**
 * @brief Multiply 4x3 matrix by a FVec3
 * @param[in_] mtx Matrix
 * @param[in_] v   Vector
 * @return mtx*v (product)
 */
Mtx_MultiplyFVecH :: inline (mtx: *C3D_Mtx, v: C3D_FVec) -> C3D_FVec {
    v.w = 1.0;

    return Mtx_MultiplyFVec4(mtx, v);
}

/**
*@brief Transposes the matrix. Row => Column, and vice versa.
*@param[in,out] out     Output matrix.
*/
Mtx_Transpose :: (out: *C3D_Mtx) #foreign libcitro3d;

/**
* @brief Multiply two matrices
* @param[out] out Output matrix
* @param[in]  a   Multiplicand
* @param[in]  b   Multiplier
*/
Mtx_Multiply :: (out: *C3D_Mtx, a: *C3D_Mtx, b: *C3D_Mtx) #foreign libcitro3d;

/**
* @brief Inverse a matrix
* @param[in,out] out Matrix to inverse
* @retval 0.0 Degenerate matrix (no inverse)
* @return determinant
*/
Mtx_Inverse :: (out: *C3D_Mtx) -> float #foreign libcitro3d;

/**
* @brief Multiply 3x3 matrix by a FVec3
* @param[in] mtx Matrix
* @param[in] v   Vector
* @return mtx*v (product)
*/
Mtx_MultiplyFVec3 :: (mtx: *C3D_Mtx, v: C3D_FVec) -> C3D_FVec #foreign libcitro3d;

/**
* @brief Multiply 4x4 matrix by a FVec4
* @param[in] mtx Matrix
* @param[in] v   Vector
* @return mtx*v (product)
*/
Mtx_MultiplyFVec4 :: (mtx: *C3D_Mtx, v: C3D_FVec) -> C3D_FVec #foreign libcitro3d;

/**
* @brief Get 4x4 matrix equivalent to Quaternion
* @param[out] m Output matrix
* @param[in]  q Input Quaternion
*/
Mtx_FromQuat :: (m: *C3D_Mtx, q: C3D_FQuat) #foreign libcitro3d;

/**
* @brief 3D translation
* @param[in,out] mtx Matrix to translate
* @param[in]     x            X component to translate
* @param[in]     y            Y component to translate
* @param[in]     z            Z component to translate
* @param[in]     bRightSide   Whether to transform from the right side
*/
Mtx_Translate :: (mtx: *C3D_Mtx, x: float, y: float, z: float, bRightSide: bool) #foreign libcitro3d;

/**
* @brief 3D Scale
* @param[in,out] mtx Matrix to scale
* @param[in]     x   X component to scale
* @param[in]     y   Y component to scale
* @param[in]     z   Z component to scale
*/
Mtx_Scale :: (mtx: *C3D_Mtx, x: float, y: float, z: float) #foreign libcitro3d;

/**
* @brief 3D Rotation
* @param[in,out] mtx        Matrix to rotate
* @param[in]     axis       Axis about which to rotate
* @param[in]     angle      Radians to rotate
* @param[in]     bRightSide Whether to transform from the right side
*/
Mtx_Rotate :: (mtx: *C3D_Mtx, axis: C3D_FVec, angle: float, bRightSide: bool) #foreign libcitro3d;

/**
* @brief 3D Rotation about the X axis
* @param[in,out] mtx        Matrix to rotate
* @param[in]     angle      Radians to rotate
* @param[in]     bRightSide Whether to transform from the right side
*/
Mtx_RotateX :: (mtx: *C3D_Mtx, angle: float, bRightSide: bool) #foreign libcitro3d;

/**
* @brief 3D Rotation about the Y axis
* @param[in,out] mtx        Matrix to rotate
* @param[in]     angle      Radians to rotate
* @param[in]     bRightSide Whether to transform from the right side
*/
Mtx_RotateY :: (mtx: *C3D_Mtx, angle: float, bRightSide: bool) #foreign libcitro3d;

/**
* @brief 3D Rotation about the Z axis
* @param[in,out] mtx        Matrix to rotate
* @param[in]     angle      Radians to rotate
* @param[in]     bRightSide Whether to transform from the right side
*/
Mtx_RotateZ :: (mtx: *C3D_Mtx, angle: float, bRightSide: bool) #foreign libcitro3d;

/**
* @brief Orthogonal projection
* @param[out] mtx Output matrix
* @param[in]  left         Left clip plane (X=left)
* @param[in]  right        Right clip plane (X=right)
* @param[in]  bottom       Bottom clip plane (Y=bottom)
* @param[in]  top          Top clip plane (Y=top)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_OrthoTilt
*/
Mtx_Ortho :: (mtx: *C3D_Mtx, left: float, right: float, bottom: float, top: float, near: float, far: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Perspective projection
* @param[out] mtx          Output matrix
* @param[in]  fovy         Vertical field of view in radians
* @param[in]  aspect       Aspect ration of projection plane (width/height)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_PerspTilt
* @sa Mtx_PerspStereo
* @sa Mtx_PerspStereoTilt
*/
Mtx_Persp :: (mtx: *C3D_Mtx, fovy: float, aspect: float, near: float, far: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Stereo perspective projection
* @note Typically you will use iod to mean the distance between the eyes. Plug
*       in -iod for the left eye and iod for the right eye.
* @note The focal length is defined by screen. If objects are further than this,
*       they will appear to be inside the screen. If objects are closer than this,
*       they will appear to pop out of the screen. Objects at this distance appear
*       to be at the screen.
* @param[out] mtx          Output matrix
* @param[in]  fovy         Vertical field of view in radians
* @param[in]  aspect       Aspect ration of projection plane (width/height)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  iod          Interocular distance
* @param[in]  screen       Focal length
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_Persp
* @sa Mtx_PerspTilt
* @sa Mtx_PerspStereoTilt
*/
Mtx_PerspStereo :: (mtx: *C3D_Mtx, fovy: float, aspect: float, near: float, far: float, iod: float, screen: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Orthogonal projection, tilted to account for the 3DS screen rotation
* @param[out] mtx          Output matrix
* @param[in]  left         Left clip plane (X=left)
* @param[in]  right        Right clip plane (X=right)
* @param[in]  bottom       Bottom clip plane (Y=bottom)
* @param[in]  top          Top clip plane (Y=top)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_Ortho
*/
Mtx_OrthoTilt :: (mtx: *C3D_Mtx, left: float, right: float, bottom: float, top: float, near: float, far: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Perspective projection, tilted to account for the 3DS screen rotation
* @param[out] mtx          Output matrix
* @param[in]  fovy         Vertical field of view in radians
* @param[in]  aspect       Aspect ration of projection plane (width/height)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_Persp
* @sa Mtx_PerspStereo
* @sa Mtx_PerspStereoTilt
*/
Mtx_PerspTilt :: (mtx: *C3D_Mtx, fovy: float, aspect: float, near: float, far: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Stereo perspective projection, tilted to account for the 3DS screen rotation
* @note See the notes for @ref Mtx_PerspStereo
* @param[out] mtx          Output matrix
* @param[in]  fovy         Vertical field of view in radians
* @param[in]  aspect       Aspect ration of projection plane (width/height)
* @param[in]  near         Near clip plane (Z=near)
* @param[in]  far          Far clip plane (Z=far)
* @param[in]  iod          Interocular distance
* @param[in]  screen       Focal length
* @param[in]  isLeftHanded Whether to build a LH projection
* @sa Mtx_Persp
* @sa Mtx_PerspTilt
* @sa Mtx_PerspStereo
*/
Mtx_PerspStereoTilt :: (mtx: *C3D_Mtx, fovy: float, aspect: float, near: float, far: float, iod: float, screen: float, isLeftHanded: bool) #foreign libcitro3d;

/**
* @brief Look-At matrix, based on DirectX implementation
* @note See https://msdn.microsoft.com/en-us/library/windows/desktop/bb205342
* @param[out] out            Output matrix.
* @param[in]  cameraPosition Position of the intended camera in 3D space.
* @param[in]  cameraTarget   Position of the intended target the camera is supposed to face in 3D space.
* @param[in]  cameraUpVector The vector that points straight up depending on the camera's "Up" direction.
* @param[in]  isLeftHanded   Whether to build a LH projection
*/
Mtx_LookAt :: (out: *C3D_Mtx, cameraPosition: C3D_FVec, cameraTarget: C3D_FVec, cameraUpVector: C3D_FVec, isLeftHanded: bool) #foreign libcitro3d;

/**
 * @name Quaternion Math
 * @{
 */

/**
 * @brief Create a new Quaternion
 * @param[in_] i I-component
 * @param[in_] j J-component
 * @param[in_] k K-component
 * @param[in_] r Real component
 * @return New Quaternion
 */
Quat_New :: FVec4_New;

/**
 * @brief Negate a Quaternion
 * @note This is equivalent to `Quat_Scale(v, -1)`
 * @param[in_] q Quaternion to negate
 * @return -q
 */
Quat_Negate :: FVec4_Negate;

/**
 * @brief Add two Quaternions
 * @param[in_] lhs Augend
 * @param[in_] rhs Addend
 * @return lhs+rhs (sum)
 */
Quat_Add :: FVec4_Add;

/**
 * @brief Subtract two Quaternions
 * @param[in_] lhs Minuend
 * @param[in_] rhs Subtrahend
 * @return lhs-rhs (difference)
 */
Quat_Subtract :: FVec4_Subtract;

/**
 * @brief Scale a Quaternion
 * @param[in_] q Quaternion to scale
 * @param[in_] s Scale factor
 * @return q*s
 */
Quat_Scale :: FVec4_Scale;

/**
 * @brief Normalize a Quaternion
 * @param[in_] q Quaternion to normalize
 * @return q/‖q‖
 */
Quat_Normalize :: FVec4_Normalize;

/**
 * @brief Dot product of two Quaternions
 * @param[in_] lhs Left-side Quaternion
 * @param[in_] rhs Right-side Quaternion
 * @return lhs∙rhs
 */
Quat_Dot :: FVec4_Dot;

/**
* @brief Multiply two Quaternions
* @param[in] lhs Multiplicand
* @param[in] rhs Multiplier
* @return lhs*rhs
*/
Quat_Multiply :: (lhs: C3D_FQuat, rhs: C3D_FQuat) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Raise Quaternion to a power
* @note If p is 0, this returns the identity Quaternion.
*       If p is 1, this returns q.
* @param[in] q Base Quaternion
* @param[in] p Power
* @return q<sup>p</sup>
*/
Quat_Pow :: (q: C3D_FQuat, p: float) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Cross product of Quaternion and FVec3
* @param[in] q Base Quaternion
* @param[in] v Vector to cross
* @return q×v
*/
Quat_CrossFVec3 :: (q: C3D_FQuat, v: C3D_FVec) -> C3D_FVec #foreign libcitro3d;

/**
* @brief 3D Rotation
* @param[in] q          Quaternion to rotate
* @param[in] axis       Axis about which to rotate
* @param[in] r          Radians to rotate
* @param[in] bRightSide Whether to transform from the right side
* @return Rotated Quaternion
*/
Quat_Rotate :: (q: C3D_FQuat, axis: C3D_FVec, r: float, bRightSide: bool) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief 3D Rotation about the X axis
* @param[in] q          Quaternion to rotate
* @param[in] r          Radians to rotate
* @param[in] bRightSide Whether to transform from the right side
* @return Rotated Quaternion
*/
Quat_RotateX :: (q: C3D_FQuat, r: float, bRightSide: bool) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief 3D Rotation about the Y axis
* @param[in] q          Quaternion to rotate
* @param[in] r          Radians to rotate
* @param[in] bRightSide Whether to transform from the right side
* @return Rotated Quaternion
*/
Quat_RotateY :: (q: C3D_FQuat, r: float, bRightSide: bool) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief 3D Rotation about the Z axis
* @param[in] q          Quaternion to rotate
* @param[in] r          Radians to rotate
* @param[in] bRightSide Whether to transform from the right side
* @return Rotated Quaternion
*/
Quat_RotateZ :: (q: C3D_FQuat, r: float, bRightSide: bool) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Get Quaternion equivalent to 4x4 matrix
* @note If the matrix is orthogonal or special orthogonal, where determinant(matrix) = +1.0, then the matrix can be converted.
* @param[in]   m Input  Matrix
* @return      Generated Quaternion
*/
Quat_FromMtx :: (m: *C3D_Mtx) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Converting Pitch, Yaw, and Roll to Quaternion equivalent
* @param[in] pitch      The pitch angle in radians.
* @param[in] yaw        The yaw angle in radians.
* @param[in] roll       The roll angle in radians.
* @param[in] bRightSide Whether to transform from the right side
* @return    C3D_FQuat  The Quaternion equivalent with the pitch, yaw, and roll (in that order) orientations applied.
*/
Quat_FromPitchYawRoll :: (pitch: float, yaw: float, roll: float, bRightSide: bool) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Quaternion Look-At
* @param[in] source   C3D_FVec Starting position. Origin of rotation.
* @param[in] target   C3D_FVec Target position to orient towards.
* @param[in] forwardVector C3D_FVec The Up vector.
* @param[in] upVector C3D_FVec The Up vector.
* @return Quaternion rotation.
*/
Quat_LookAt :: (source: C3D_FVec, target: C3D_FVec, forwardVector: C3D_FVec, upVector: C3D_FVec) -> C3D_FQuat #foreign libcitro3d;

/**
* @brief Quaternion, created from a given axis and angle in radians.
* @param[in] axis  C3D_FVec The axis to rotate around at.
* @param[in] angle float The angle to rotate. Unit: Radians
* @return Quaternion rotation based on the axis and angle. Axis doesn't have to be orthogonal.
*/
Quat_FromAxisAngle :: (axis: C3D_FVec, angle: float) -> C3D_FQuat #foreign libcitro3d;

C3D_MtxStack :: struct {
    m:        [8] C3D_Mtx;
    pos:      s32;
    unifType: u8;
    unifPos:  u8;
    unifLen:  u8;
    isDirty:  bool;
}

MtxStack_Cur :: inline (stk: *C3D_MtxStack) -> *C3D_Mtx {
    stk.isDirty = true;
    return *stk.m[stk.pos];
}

MtxStack_Init :: (stk: *C3D_MtxStack) #foreign libcitro3d;
MtxStack_Bind :: (stk: *C3D_MtxStack, unifType: GPU_SHADER_TYPE, unifPos: s32, unifLen: s32) #foreign libcitro3d;
MtxStack_Push :: (stk: *C3D_MtxStack) -> *C3D_Mtx #foreign libcitro3d;
MtxStack_Pop :: (stk: *C3D_MtxStack) -> *C3D_Mtx #foreign libcitro3d;
MtxStack_Update :: (stk: *C3D_MtxStack) #foreign libcitro3d;

C3D_FVUnif:    [2][C3D_FVUNIF_COUNT] C3D_FVec  #elsewhere;
C3D_IVUnif:    [2][C3D_IVUNIF_COUNT] C3D_IVec  #elsewhere;
C3D_BoolUnifs: [2] u16                         #elsewhere;

C3D_FVUnifDirty:    [2][C3D_FVUNIF_COUNT] bool #elsewhere;
C3D_IVUnifDirty:    [2][C3D_IVUNIF_COUNT] bool #elsewhere;
C3D_BoolUnifsDirty: [2] bool                   #elsewhere;

C3D_FVUnifWritePtr :: inline (type: GPU_SHADER_TYPE, id: s32, size: s32) -> *C3D_FVec {
    for 0..size-1 {
        C3D_FVUnifDirty[type][id+i] = true;
    }
    return *C3D_FVUnif[type][id];
}

C3D_IVUnifWritePtr :: inline (type: GPU_SHADER_TYPE, id: s32) -> *C3D_IVec {
    id -= 0x60;
    C3D_IVUnifDirty[type][id] = true;
    return *C3D_IVUnif[type][id];
}

C3D_FVUnifMtxNx4 :: inline (type: GPU_SHADER_TYPE, id: s32, mtx: *C3D_Mtx, num: s32) {
    ptr := C3D_FVUnifWritePtr(type, id, num);
    for i..num-1 {
        ptr[i] = mtx.r.ptr[i]; // Struct copy. (Intentional write "out of bounds")
    }
}

C3D_FVUnifMtx4x4 :: inline (type: GPU_SHADER_TYPE, id: s32, mtx: *C3D_Mtx) {
    C3D_FVUnifMtxNx4(type, id, mtx, 4);
}

C3D_FVUnifMtx3x4 :: inline (type: GPU_SHADER_TYPE, id: s32, mtx: *C3D_Mtx) {
    C3D_FVUnifMtxNx4(type, id, mtx, 3);
}

C3D_FVUnifMtx2x4 :: inline (type: GPU_SHADER_TYPE, id: s32, mtx: *C3D_Mtx) {
    C3D_FVUnifMtxNx4(type, id, mtx, 2);
}

C3D_FVUnifSet :: inline (type: GPU_SHADER_TYPE, id: s32, x: float, y: float, z: float, w: float) {
    ptr := C3D_FVUnifWritePtr(type, id, 1);
    ptr.x = x;
    ptr.y = y;
    ptr.z = z;
    ptr.w = w;
}

C3D_IVUnifSet :: inline (type: GPU_SHADER_TYPE, id: s32, x: s32, y: s32, z: s32, w: s32) {
    ptr := C3D_IVUnifWritePtr(type, id);
    <<ptr = IVec_Pack(x, y, z, w);
}

C3D_BoolUnifSet :: inline (type: GPU_SHADER_TYPE, id: s32, value: bool) {
    id -= 0x68;
    C3D_BoolUnifsDirty[type] = true;
    if value {
        C3D_BoolUnifs[type] |= BIT(id);
    }
    else {
        C3D_BoolUnifs[type] &= ~BIT(id);
    }
}

C3D_UpdateUniforms :: (type: GPU_SHADER_TYPE) #foreign libcitro3d;

C3D_AttrInfo :: struct {
    flags:       [2] u32;
    permutation: u64;
    attrCount:   s32;
}

AttrInfo_Init :: (info: *C3D_AttrInfo) #foreign libcitro3d;
AttrInfo_AddLoader :: (info: *C3D_AttrInfo, regId: s32, format: GPU_FORMATS, count: s32) -> s32 #foreign libcitro3d;
AttrInfo_AddFixed :: (info: *C3D_AttrInfo, regId: s32) -> s32 #foreign libcitro3d;

C3D_GetAttrInfo :: () -> *C3D_AttrInfo #foreign libcitro3d;
C3D_SetAttrInfo :: (info: *C3D_AttrInfo) #foreign libcitro3d;

C3D_BufCfg :: struct {
    offset: u32;
    flags:  [2] u32;
}

C3D_BufInfo :: struct {
    base_paddr: u32;
    bufCount:   s32;
    buffers:    [12] C3D_BufCfg;
}

BufInfo_Init :: (info: *C3D_BufInfo) #foreign libcitro3d;
BufInfo_Add :: (info: *C3D_BufInfo, data: *void, stride: ptrdiff_t, attribCount: s32, permutation: u64) -> s32 #foreign libcitro3d;

C3D_GetBufInfo :: () -> *C3D_BufInfo #foreign libcitro3d;
C3D_SetBufInfo :: (info: *C3D_BufInfo) #foreign libcitro3d;

C3D_UNSIGNED :: enum u8 {
    BYTE  :: 0;
    SHORT :: 1;
}

C3D_Init :: (cmdBufSize: size_t) -> bool #foreign libcitro3d;
C3D_Fini :: () #foreign libcitro3d;

C3D_GetCmdBufUsage :: () -> float #foreign libcitro3d;

C3D_BindProgram :: (program: *shaderProgram_s) #foreign libcitro3d;

C3D_SetViewport :: (x: u32, y: u32, w: u32, h: u32) #foreign libcitro3d;
C3D_SetScissor :: (mode: GPU_SCISSORMODE, left: u32, top: u32, right: u32, bottom: u32) #foreign libcitro3d;

C3D_DrawArrays :: (primitive: GPU_Primitive_t, first: s32, size: s32) #foreign libcitro3d;
C3D_DrawElements :: (primitive: GPU_Primitive_t, count: s32, type: s32, indices: *void) #foreign libcitro3d;

// Immediate-mode vertex submission
C3D_ImmDrawBegin :: (primitive: GPU_Primitive_t) #foreign libcitro3d;
C3D_ImmSendAttrib :: (x: float, y: float, z: float, w: float) #foreign libcitro3d;
C3D_ImmDrawEnd :: () #foreign libcitro3d;

C3D_ImmDrawRestartPrim :: inline () {
    GPUCMD_AddWrite(GPUREG_RESTART_PRIMITIVE, 1);
}

// Fixed vertex attributes
C3D_FixedAttribGetWritePtr :: (id: s32) -> *C3D_FVec #foreign libcitro3d;

C3D_FixedAttribSet :: inline (id: s32, x: float, y: float, z: float, w: float) {
    ptr := C3D_FixedAttribGetWritePtr(id);
    ptr.x = x;
    ptr.y = y;
    ptr.z = z;
    ptr.w = w;
}

C3D_TexEnv :: struct {
    srcRgb:     u16;
    srcAlpha:   u16;
    union {
        opAll: u32;
        struct {
            opRgb:   u32;
            #place opRgb; /*bitfield 12*/ opAlpha: u32;
        }
    }
    funcRgb:    u16;
    funcAlpha:  u16;
    color:      u32;
    scaleRgb:   u16;
    scaleAlpha: u16;
}

C3D_TexEnvMode :: enum_flags u8 {
    RGB   :: 1;
    Alpha :: 2;
    Both  :: 3;
}

C3D_GetTexEnv :: (id: s32) -> *C3D_TexEnv #foreign libcitro3d;
C3D_SetTexEnv :: (id: s32, env: *C3D_TexEnv) #foreign libcitro3d;
C3D_DirtyTexEnv :: (env: *C3D_TexEnv) #foreign libcitro3d;

C3D_TexEnvBufUpdate :: (mode: s32, mask: s32) #foreign libcitro3d;
C3D_TexEnvBufColor :: (color: u32) #foreign libcitro3d;

C3D_TexEnvInit :: inline (env: *C3D_TexEnv)
{
    env.srcRgb     = cast(u16)GPU_TEVSOURCES(GPU_TEVSRC.PREVIOUS, 0, 0);
    env.srcAlpha   = env.srcRgb;
    env.opAll      = 0;
    env.funcRgb    = GPU_COMBINEFUNC.REPLACE;
    env.funcAlpha  = env.funcRgb;
    env.color      = 0xFFFFFFFF;
    env.scaleRgb   = GPU_TEVSCALE.X1;
    env.scaleAlpha = GPU_TEVSCALE.X1;
}

C3D_TexEnvSrc :: inline (
    env: *C3D_TexEnv,
    mode: C3D_TexEnvMode,
    s1: GPU_TEVSRC,
    s2: GPU_TEVSRC,
    s3: GPU_TEVSRC)
{
    param := GPU_TEVSOURCES(cast(s32)s1, cast(s32)s2, cast(s32)s3);
    if (mode & C3D_TexEnvMode.RGB)
        env.srcRgb = cast(u16)param;
    if (mode & C3D_TexEnvMode.ALPHA)
        env.srcAlpha = cast(u16)param;
}

C3D_TexEnvOpRgb :: inline (
    env: *C3D_TexEnv,
    o1: GPU_TEVOP_RGB,
    o2: GPU_TEVOP_RGB,
    o3: GPU_TEVOP_RGB)
{
    env.opRgb = GPU_TEVOPERANDS(cast(s32)o1, cast(s32)o2, cast(s32)o3);
}

C3D_TexEnvOpAlpha :: inline (
    env: *C3D_TexEnv,
    o1: GPU_TEVOP_A,
    o2: GPU_TEVOP_A,
    o3: GPU_TEVOP_A)
{
    env.opAlpha = GPU_TEVOPERANDS(cast(s32)o1, cast(s32)o2, cast(s32)o3);
}

C3D_TexEnvFunc :: inline (
    env: *C3D_TexEnv,
    mode: C3D_TexEnvMode,
    param: GPU_COMBINEFUNC)
{
    if mode & C3D_TexEnvMode.RGB {
        env.funcRgb = cast(u16)param;
    }
    if mode & C3D_TexEnvMode.ALPHA {
        env.funcAlpha = cast(u16)param;
    }
}

C3D_TexEnvColor :: inline (env: *C3D_TexEnv, color: u32)
{
    env.color = color;
}

C3D_TexEnvScale :: inline (env: *C3D_TexEnv, mode: C3D_TexEnvMode, param: GPU_TEVSCALE)
{
    if (mode & C3D_TexEnvMode.RGB)
        env.scaleRgb = cast(u16)param;
    if (mode & C3D_TexEnvMode.ALPHA)
        env.scaleAlpha = cast(u16)param;
}

C3D_DepthMap :: (bIsZBuffer: bool, zScale: float, zOffset: float) #foreign libcitro3d;
C3D_CullFace :: (mode: GPU_CULLMODE) #foreign libcitro3d;
C3D_StencilTest :: (enable: bool, function: GPU_TESTFUNC, ref: s32, inputMask: s32, writeMask: s32) #foreign libcitro3d;
C3D_StencilOp :: (sfail: GPU_STENCILOP, dfail: GPU_STENCILOP, pass: GPU_STENCILOP) #foreign libcitro3d;
C3D_BlendingColor :: (color: u32) #foreign libcitro3d;
C3D_EarlyDepthTest :: (enable: bool, function: GPU_EARLYDEPTHFUNC, ref: u32) #foreign libcitro3d;
C3D_DepthTest :: (enable: bool, function: GPU_TESTFUNC, writemask: GPU_WRITEMASK) #foreign libcitro3d;
C3D_AlphaTest :: (enable: bool, function: GPU_TESTFUNC, ref: s32) #foreign libcitro3d;
C3D_AlphaBlend :: (colorEq: GPU_BLENDEQUATION, alphaEq: GPU_BLENDEQUATION, srcClr: GPU_BLENDFACTOR, dstClr: GPU_BLENDFACTOR, srcAlpha: GPU_BLENDFACTOR, dstAlpha: GPU_BLENDFACTOR) #foreign libcitro3d;
C3D_ColorLogicOp :: (op: GPU_LOGICOP) #foreign libcitro3d;
C3D_FragOpMode :: (mode: GPU_FRAGOPMODE) #foreign libcitro3d;
C3D_FragOpShadow :: (scale: float, bias: float) #foreign libcitro3d;

C3D_TexCube :: struct {
    data: [6] *void;
}

C3D_Tex :: struct {
    union {
        data: *void;
        cube: *C3D_TexCube;
    }
    fmt:    GPU_TEXCOLOR;
    size:   size_t;
    union {
        dim: u32;
        struct {
            height: u16;
            width:  u16;
        }
    }
    param:  u32;
    border: u32;
    union {
        lodParam: u32;
        struct {
            lodBias:  u16;
            maxLevel: u8;
            minLevel: u8;
        }
    }
}

C3D_TexInitParams :: struct {
    width:    u16;
    height:   u16;
    maxLevel: u8;
    format:   GPU_TEXCOLOR;
    type:     GPU_TEXTURE_MODE_PARAM;
    onVram:   bool;
}

C3D_TexInitWithParams :: (tex: *C3D_Tex, cube: *C3D_TexCube, p: C3D_TexInitParams) -> bool #foreign libcitro3d;
C3D_TexLoadImage :: (tex: *C3D_Tex, data: *void, face: GPU_TEXFACE, level: s32) #foreign libcitro3d;
C3D_TexGenerateMipmap :: (tex: *C3D_Tex, face: GPU_TEXFACE) #foreign libcitro3d;
C3D_TexBind :: (unitId: s32, tex: *C3D_Tex) #foreign libcitro3d;
C3D_TexFlush :: (tex: *C3D_Tex) #foreign libcitro3d;
C3D_TexDelete :: (tex: *C3D_Tex) #foreign libcitro3d;

C3D_TexShadowParams :: (perspective: bool, bias: float) #foreign libcitro3d;

// avoid sizes smaller than 8
C3D_TexCalcMaxLevel :: inline (width: u32, height: u32) -> s32 {
    clz32 :: (x: u32) -> n: s32 { // @Speed! Replace with an intrinsic.
        if !x return 32;

        n: s32;
        mask: u32 = 0x8000_0000;

        while !(x & mask) {
            n += 1;
            mask = mask >> 1;
        }

        return n;
    }

    return (31-clz32(ifx width < height then width else height)) - 3; // avoid sizes smaller than 8
}

C3D_TexCalcLevelSize :: inline (size: u32, level: s32) -> u32 {
    return size >> (2*level);
}

C3D_TexCalcTotalSize :: inline (size: u32, maxLevel: s32) -> u32 {
    /*
    S  = s + sr + sr^2 + sr^3 + ... + sr^n
    Sr = sr + sr^2 + sr^3 + ... + sr^(n+1)
    S-Sr = s - sr^(n+1)
    S(1-r) = s(1 - r^(n+1))
    S = s (1 - r^(n+1)) / (1-r)

    r = 1/4
    1-r = 3/4

    S = 4s (1 - (1/4)^(n+1)) / 3
    S = 4s (1 - 1/4^(n+1)) / 3
    S = (4/3) (s - s/4^(n+1))
    S = (4/3) (s - s/(1<<(2n+2)))
    S = (4/3) (s - s>>(2n+2))
    */
    return (size - C3D_TexCalcLevelSize(size,maxLevel+1)) * 4 / 3;
}

C3D_TexInit :: inline (
    tex: *C3D_Tex,
    width: u16,
    height: u16,
    format: GPU_TEXCOLOR) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = 0;
    params.format   = format;
    params.type     = GPU_TEXTURE_MODE_PARAM._2D;
    params.onVram   = false;

    return C3D_TexInitWithParams(tex, null, params);
}

C3D_TexInitMipmap :: inline (
    tex: *C3D_Tex,
    width: u16,
    height: u16,
    format: GPU_TEXCOLOR) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = cast(u8)C3D_TexCalcMaxLevel(width, height);
    params.format   = format;
    params.type     = GPU_TEXTURE_MODE_PARAM._2D;
    params.onVram   = false;

    return C3D_TexInitWithParams(tex, null, params);
}

C3D_TexInitCube :: inline (
    tex: *C3D_Tex,
    cube: *C3D_TexCube,
    width: u16,
    height: u16,
    format: GPU_TEXCOLOR) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = 0;
    params.format   = format;
    params.type     = GPU_TEXTURE_MODE_PARAM.CUBE_MAP;
    params.onVram   = false;

    return C3D_TexInitWithParams(tex, cube, params);
}

C3D_TexInitVRAM :: inline (
    tex: *C3D_Tex,
    width: u16,
    height: u16,
    format: GPU_TEXCOLOR) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = 0;
    params.format   = format;
    params.type     = GPU_TEXTURE_MODE_PARAM._2D;
    params.onVram   = true;

    return C3D_TexInitWithParams(tex, null, params);
}

C3D_TexInitShadow :: inline (tex: *C3D_Tex, width: u16, height: u16) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = 0;
    params.format   = GPUTexColor.rgba8;
    params.type     = GPU_TEXTURE_MODE_PARAM._2D;
    params.onVram   = true;

    return C3D_TexInitWithParams(tex, null, params);
}

C3D_TexInitShadowCube :: inline (
    tex: *C3D_Tex,
    cube: *C3D_TexCube,
    width: u16,
    height: u16) -> bool
{
    params: C3D_TexInitParams;
    params.width    = width;
    params.height   = height;
    params.maxLevel = 0;
    params.format   = GPUTexColor.rgba8;
    params.type     = GPU_TEXTURE_MODE_PARAM.SHADOW_CUBE;
    params.onVram   = true;

    return C3D_TexInitWithParams(tex, cube, params);
}

C3D_TexGetType :: inline (tex: *C3D_Tex) -> GPU_TEXTURE_MODE_PARAM {
    return cast(GPU_TEXTURE_MODE_PARAM)((tex.param>>28)&0x7);
}

C3D_TexGetImagePtr :: inline (tex: *C3D_Tex, data: *void, level: s32, size: *u32) -> *void {
    if size    {
        <<size = ifx level >= 0 then C3D_TexCalcLevelSize(tex.size, level) else C3D_TexCalcTotalSize(tex.size, tex.maxLevel);
    }
    if !level return data;
    return cast(*u8)data + (ifx level > 0 then C3D_TexCalcTotalSize(tex.size, level-1) else 0);
}

C3D_Tex2DGetImagePtr :: inline (tex: *C3D_Tex, level: s32, size: *u32) -> *void {
    return C3D_TexGetImagePtr(tex, tex.data, level, size);
}

C3D_TexCubeGetImagePtr :: inline (
    tex: *C3D_Tex,
    face: GPU_TEXFACE,
    level: s32,
    size: *u32 ) -> *void
{
    return C3D_TexGetImagePtr(tex, tex.cube.data[face], level, size);
}

C3D_TexUpload :: inline (tex: *C3D_Tex, data: *void)
{
    C3D_TexLoadImage(tex, data, GPUTexFace.texface_2d, 0);
}

C3D_TexSetFilter :: inline (
    tex: *C3D_Tex,
    magFilter: GPU_TEXTURE_FILTER_PARAM,
    minFilter: GPU_TEXTURE_FILTER_PARAM)
{
    tex.param &= ~(GPU_TEXTURE_MAG_FILTER(GPU_TEXTURE_FILTER_PARAM.LINEAR) | GPU_TEXTURE_MIN_FILTER(GPU_TEXTURE_FILTER_PARAM.LINEAR));
    tex.param |= GPU_TEXTURE_MAG_FILTER(magFilter) | GPU_TEXTURE_MIN_FILTER(minFilter);
}

C3D_TexSetFilterMipmap :: inline (tex: *C3D_Tex, filter: GPU_TEXTURE_FILTER_PARAM) {
    tex.param &= ~GPU_TEXTURE_MIP_FILTER(GPU_TEXTURE_FILTER_PARAM.LINEAR);
    tex.param |= GPU_TEXTURE_MIP_FILTER(filter);
}

C3D_TexSetWrap :: inline (
    tex: *C3D_Tex,
    wrapS: GPU_TEXTURE_WRAP_PARAM,
    wrapT: GPU_TEXTURE_WRAP_PARAM)
{
    tex.param &= ~(GPU_TEXTURE_WRAP_S(3) | GPU_TEXTURE_WRAP_T(3));
    tex.param |= GPU_TEXTURE_WRAP_S(wrapS) | GPU_TEXTURE_WRAP_T(wrapT);
}

C3D_TexSetLodBias :: inline (tex: *C3D_Tex, lodBias: float) {
    iLodBias := cast(s32)(lodBias*0x100);
    if (iLodBias > 0xFFF)
        iLodBias = 0xFFF;
    else if (iLodBias < -0x1000)
        iLodBias = -0x1000;
    tex.lodBias = iLodBias & 0x1FFF;
}


C3D_ProcTexColorLut :: struct {
    color: [256] u32;
    diff:  [256] u32;
}

C3D_ProcTex :: struct {
    union {
        proctex0: u32;
        struct {
            uClamp:        u32;
            #place uClamp; /*bitfield 3*/ vClamp:        u32;
            #place uClamp; /*bitfield 6*/ rgbFunc:       u32;
            #place uClamp; /*bitfield 10*/ alphaFunc:     u32;
            alphaSeparate: bool;
            #place alphaSeparate; /*bitfield 1*/ enableNoise:   bool;
            uShift:        u32;
            #place uShift; /*bitfield 2*/ vShift:        u32;
            #place uShift; /*bitfield 4*/ lodBiasLow:    u32;
        }
    }
    union {
        proctex1: u32;
        struct {
            uNoiseAmpl:  u16;
            uNoisePhase: u16;
        }
    }
    union {
        proctex2: u32;
        struct {
            vNoiseAmpl:  u16;
            vNoisePhase: u16;
        }
    }
    union {
        proctex3: u32;
        struct {
            uNoiseFreq: u16;
            vNoiseFreq: u16;
        }
    }
    union {
        proctex4: u32;
        struct {
            minFilter:   u32;
            #place minFilter; /*bitfield 3*/ unknown1:    u32;
            #place minFilter; /*bitfield 11*/ width:       u32;
            #place minFilter; /*bitfield 19*/ lodBiasHigh: u32;
        }
    }
    union {
        proctex5: u32;
        struct {
            offset:   u32;
            #place offset; /*bitfield 8*/ unknown2: u32;
        }
    }
}

C3D_ProcTex_1 :: enum u8 {
    U  :: 1;
    V  :: 2;
    UV :: 3;
}

C3D_ProcTexInit :: (pt: *C3D_ProcTex, offset: s32, length: s32) #foreign libcitro3d;
C3D_ProcTexNoiseCoefs :: (pt: *C3D_ProcTex, mode: s32, amplitude: float, frequency: float, phase: float) #foreign libcitro3d;
C3D_ProcTexLodBias :: (pt: *C3D_ProcTex, bias: float) #foreign libcitro3d;
C3D_ProcTexBind :: (texCoordId: s32, pt: *C3D_ProcTex) #foreign libcitro3d;

// GPU_LUT_NOISE, GPU_LUT_RGBMAP, GPU_LUT_ALPHAMAP
C3D_ProcTexLut :: [128] u32;
C3D_ProcTexLutBind :: (id: GPU_PROCTEX_LUTID, lut: *C3D_ProcTexLut) #foreign libcitro3d;
ProcTexLut_FromArray :: (lut: *C3D_ProcTexLut, in: *[129] float) #foreign libcitro3d;

C3D_ProcTexColorLutBind :: (lut: *C3D_ProcTexColorLut) #foreign libcitro3d;
ProcTexColorLut_Write :: (out: *C3D_ProcTexColorLut, in: *u32, offset: s32, length: s32) #foreign libcitro3d;

C3D_ProcTexClamp :: inline (pt: C3D_ProcTex, u: GPU_PROCTEX_CLAMP, v: GPU_PROCTEX_CLAMP) {
    pt.uClamp = u;
    pt.vClamp = v;
}

C3D_ProcTexCombiner :: inline (pt: C3D_ProcTex, separate: bool, rgb: GPU_PROCTEX_MAPFUNC, alpha: GPU_PROCTEX_MAPFUNC) {
    pt.alphaSeparate = separate;
    pt.rgbFunc = rgb;
    if separate {
        pt.alphaFunc = alpha;
    }
}

C3D_ProcTexNoiseEnable :: inline (pt: C3D_ProcTex, enable: bool) {
    pt.enableNoise = enable;
}

C3D_ProcTexShift :: inline (pt: C3D_ProcTex, u: GPU_PROCTEX_SHIFT, v: GPU_PROCTEX_SHIFT) {
    pt.uShift = u;
    pt.vShift = v;
}

C3D_ProcTexFilter :: inline (pt: C3D_ProcTex, min: GPU_PROCTEX_FILTER) {
    pt.minFilter = min;
}

C3D_LightLut :: struct {
    data: [256] u32;
}

C3D_LightLutDA :: struct {
    lut:   C3D_LightLut;
    bias:  float;
    scale: float;
}

C3D_LightLutFunc :: #type (x: float, param: float) -> float #c_call;
C3D_LightLutFuncDA :: #type (dist: float, arg0: float, arg1: float) -> float #c_call;

quadratic_dist_attn :: inline (dist: float, linear: float, quad: float) -> float {
    return 1.0 / (1.0 + linear*dist + quad*dist*dist);
}

spot_step :: inline (angle: float, cutoff: float) -> float {
    return ifx angle >= cutoff then 1.0 else 0.0;
}

LightLut_FromArray :: (lut: *C3D_LightLut, data: *float) #foreign libcitro3d;
LightLut_FromFunc :: (lut: *C3D_LightLut, func: C3D_LightLutFunc, param: float, negative: bool) #foreign libcitro3d;
LightLutDA_Create :: (lut: *C3D_LightLutDA, func: C3D_LightLutFuncDA, from: float, to: float, arg0: float, arg1: float) #foreign libcitro3d;

LightLut_Phong :: inline (lut: *C3D_LightLut, shininess: float) {
    return LightLut_FromFunc(lut, powf, shininess, false);
}

LightLut_Spotlight :: inline (lut: *C3D_LightLut, angle: float) {
    return LightLut_FromFunc(lut, spot_step, cosf(angle), true);
}

LightLutDA_Quadratic :: inline (lut: *C3D_LightLut, from: float, to: float, linear: float, quad: float) {
    return LightLutDA_Create(lut, quadratic_dist_attn, from, to, linear, quad);
}

//-----------------------------------------------------------------------------
// Material
//-----------------------------------------------------------------------------
C3D_Material :: struct {
    ambient:   [3] float;
    diffuse:   [3] float;
    specular0: [3] float;
    specular1: [3] float;
    emission:  [3] float;
}

// Forward declarations
C3D_Light :: C3D_Light_t;
C3D_LightEnv :: C3D_LightEnv_t;

C3D_LightLutInputConf :: struct {
    abs:    u32;
    select: u32;
    scale:  u32;
}

C3D_LightEnvConf :: struct {
    ambient:     u32;
    numLights:   u32;
    config:      [2] u32;
    lutInput:    C3D_LightLutInputConf;
    permutation: u32;
}

C3DF_LightEnv :: enum_flags u32 {
    Dirty    :: 1;
    MtlDirty :: 2;
    LCDirty  :: 4;
}

C3DF_LightEnv_IsCP :: inline (n: u32) -> C3DF_LightEnv {
    return 1 << (18 + n);
}

C3DF_LightEnv_IsCP_Any : C3DF_LightEnv : 0xFF<<18;

C3DF_LightEnv_LutDirty :: inline (n: u32) -> C3DF_LightEnv {
    return 1 << (26 + n);
}

C3DF_LightEnv_LutDirtyAll : C3DF_LightEnv : 0x3F<<26;

C3D_LightEnv_t :: struct {
    flags:    u32;
    luts:     [6] *C3D_LightLut #align 4;
    ambient:  [3] float;
    lights:   [8] *C3D_Light;
    conf:     C3D_LightEnvConf;
    material: C3D_Material;
}

C3D_LightEnvInit :: (env: *C3D_LightEnv) #foreign libcitro3d;
C3D_LightEnvBind :: (env: *C3D_LightEnv) #foreign libcitro3d;

C3D_LightEnvMaterial :: (env: *C3D_LightEnv, mtl: *C3D_Material) #foreign libcitro3d;
C3D_LightEnvAmbient :: (env: *C3D_LightEnv, r: float, g: float, b: float) #foreign libcitro3d;
C3D_LightEnvLut :: (env: *C3D_LightEnv, lutId: GPU_LIGHTLUTID, input: GPU_LIGHTLUTINPUT, negative: bool, lut: *C3D_LightLut) #foreign libcitro3d;

GPU :: enum_flags u32 {
    SHADOW_PRIMARY   :: 65536;
    SHADOW_SECONDARY :: 131072;
    INVERT_SHADOW    :: 262144;
    SHADOW_ALPHA     :: 524288;
}

C3D_LightEnvFresnel :: (env: *C3D_LightEnv, selector: GPU_FRESNELSEL) #foreign libcitro3d;
C3D_LightEnvBumpMode :: (env: *C3D_LightEnv, mode: GPU_BUMPMODE) #foreign libcitro3d;
C3D_LightEnvBumpSel :: (env: *C3D_LightEnv, texUnit: s32) #foreign libcitro3d;
C3D_LightEnvShadowMode :: (env: *C3D_LightEnv, mode: u32) #foreign libcitro3d;
C3D_LightEnvShadowSel :: (env: *C3D_LightEnv, texUnit: s32) #foreign libcitro3d;
C3D_LightEnvClampHighlights :: (env: *C3D_LightEnv, clamp: bool) #foreign libcitro3d;

//-----------------------------------------------------------------------------
// Light
//-----------------------------------------------------------------------------
C3D_LightMatConf :: struct {
    specular0: u32;
    specular1: u32;
    diffuse:   u32;
    ambient:   u32;
}

C3D_LightConf :: struct {
    material:      C3D_LightMatConf;
    position:      [3] u16;
    padding0:      u16;
    spotDir:       [3] u16;
    padding1:      u16;
    padding2:      u32;
    config:        u32;
    distAttnBias:  u32;
    distAttnScale: u32;
}

C3DF_Light :: enum_flags u16 {
    Enabled  :: 1;
    Dirty    :: 2;
    MatDirty :: 4;
    SPDirty  :: 16384;
    DADirty  :: 32768;
}

C3D_Light_t :: struct {
    flags:     u16;
    id:        u16;
    parent:    *C3D_LightEnv #align 4;
    lut_SP:    *C3D_LightLut;
    lut_DA:    *C3D_LightLut #align 4;
    ambient:   [3] float;
    diffuse:   [3] float;
    specular0: [3] float;
    specular1: [3] float;
    conf:      C3D_LightConf;
}

C3D_LightInit :: (light: *C3D_Light, env: *C3D_LightEnv) -> s32 #foreign libcitro3d;
C3D_LightEnable :: (light: *C3D_Light, enable: bool) #foreign libcitro3d;
C3D_LightTwoSideDiffuse :: (light: *C3D_Light, enable: bool) #foreign libcitro3d;
C3D_LightGeoFactor :: (light: *C3D_Light, id: s32, enable: bool) #foreign libcitro3d;
C3D_LightAmbient :: (light: *C3D_Light, r: float, g: float, b: float) #foreign libcitro3d;
C3D_LightDiffuse :: (light: *C3D_Light, r: float, g: float, b: float) #foreign libcitro3d;
C3D_LightSpecular0 :: (light: *C3D_Light, r: float, g: float, b: float) #foreign libcitro3d;
C3D_LightSpecular1 :: (light: *C3D_Light, r: float, g: float, b: float) #foreign libcitro3d;
C3D_LightPosition :: (light: *C3D_Light, pos: *C3D_FVec) #foreign libcitro3d;
C3D_LightShadowEnable :: (light: *C3D_Light, enable: bool) #foreign libcitro3d;
C3D_LightSpotEnable :: (light: *C3D_Light, enable: bool) #foreign libcitro3d;
C3D_LightSpotDir :: (light: *C3D_Light, x: float, y: float, z: float) #foreign libcitro3d;
C3D_LightSpotLut :: (light: *C3D_Light, lut: *C3D_LightLut) #foreign libcitro3d;
C3D_LightDistAttnEnable :: (light: *C3D_Light, enable: bool) #foreign libcitro3d;
C3D_LightDistAttn :: (light: *C3D_Light, lut: *C3D_LightLutDA) #foreign libcitro3d;

C3D_LightColor :: inline (light: *C3D_Light, r: float, g: float, b: float) {
    C3D_LightDiffuse(light, r, g, b);
    C3D_LightSpecular0(light, r, g, b);
    C3D_LightSpecular1(light, r, g, b);
}

C3D_FogLut :: struct {
    data: [128] u32;
}

C3D_GasLut :: struct {
    diff:  [8] u32;
    color: [8] u32;
}

FogLut_CalcZ :: inline (depth: float, near: float, far: float) -> float {
    return far*near/(depth*(far-near)+near);
}

FogLut_FromArray :: (lut: *C3D_FogLut, data: *[256] float) #foreign libcitro3d;
FogLut_Exp :: (lut: *C3D_FogLut, density: float, gradient: float, near: float, far: float) #foreign libcitro3d;

C3D_FogGasMode :: (fogMode: GPU_FOGMODE, gasMode: GPU_GASMODE, zFlip: bool) #foreign libcitro3d;
C3D_FogColor :: (color: u32) #foreign libcitro3d;
C3D_FogLutBind :: (lut: *C3D_FogLut) #foreign libcitro3d;

GasLut_FromArray :: (lut: *C3D_GasLut, data: *[9] u32) #foreign libcitro3d;

C3D_GasBeginAcc :: () #foreign libcitro3d;
C3D_GasDeltaZ :: (value: float) #foreign libcitro3d;

C3D_GasAccMax :: (value: float) #foreign libcitro3d;
C3D_GasAttn :: (value: float) #foreign libcitro3d;
C3D_GasLightPlanar :: (min: float, max: float, attn: float) #foreign libcitro3d;
C3D_GasLightView :: (min: float, max: float, attn: float) #foreign libcitro3d;
C3D_GasLightDirection :: (dotp: float) #foreign libcitro3d;
C3D_GasLutInput :: (input: GPU_GASLUTINPUT) #foreign libcitro3d;
C3D_GasLutBind :: (lut: *C3D_GasLut) #foreign libcitro3d;

C3D_FrameBuf :: struct {
    colorBuf:  *void;
    depthBuf:  *void #align 4;
    width:     u16;
    height:    u16;
    colorFmt:  GPU_COLORBUF;
    depthFmt:  GPU_DEPTHBUF;
    block32:   bool;
    colorMask: u8;
    #place colorMask; /*bitfield 4*/ depthMask: u8;
}

// Flags for C3D_FrameBufClear
C3D_ClearBits :: enum u8 {
    COLOR :: 1;
    DEPTH :: 2;
    ALL   :: 3;
}

C3D_CalcColorBufSize :: (width: u32, height: u32, fmt: GPU_COLORBUF) -> u32 #foreign libcitro3d;
C3D_CalcDepthBufSize :: (width: u32, height: u32, fmt: GPU_DEPTHBUF) -> u32 #foreign libcitro3d;

C3D_GetFrameBuf :: () -> *C3D_FrameBuf #foreign libcitro3d;
C3D_SetFrameBuf :: (fb: *C3D_FrameBuf) #foreign libcitro3d;
C3D_FrameBufTex :: (fb: *C3D_FrameBuf, tex: *C3D_Tex, face: GPU_TEXFACE, level: s32) #foreign libcitro3d;
C3D_FrameBufClear :: (fb: *C3D_FrameBuf, clearBits: C3D_ClearBits, clearColor: u32, clearDepth: u32) #foreign libcitro3d;
C3D_FrameBufTransfer :: (fb: *C3D_FrameBuf, screen: gfxScreen_t, side: gfx3dSide_t, transferFlags: u32) #foreign libcitro3d;

C3D_FrameBufAttrib :: inline (fb: *C3D_FrameBuf, width: u16, height: u16, block32: bool) {
    fb.width   = width;
    fb.height  = height;
    fb.block32 = block32;
}

C3D_FrameBufColor :: inline (fb: *C3D_FrameBuf, buf: *void, fmt: GPU_COLORBUF) {
    if buf {
        fb.colorBuf  = buf;
        fb.colorFmt  = fmt;
        fb.colorMask = 0xF;
    }
    else {
        fb.colorBuf  = null;
        fb.colorFmt  = GPU_COLORBUF.RGBA8;
        fb.colorMask = 0;
    }
}

C3D_FrameBufDepth :: inline (fb: *C3D_FrameBuf, buf: *void, fmt: GPU_DEPTHBUF) {
    if buf {
        fb.depthBuf  = buf;
        fb.depthFmt  = fmt;
        fb.depthMask = ifx fmt == GPU_DEPTHBUF.DEPTH24_STENCIL8 then 0x3 else 0x2;
    }
    else {
        fb.depthBuf  = null;
        fb.depthFmt  = GPU_DEPTHBUF.DEPTH24;
        fb.depthMask = 0;
    }
}

C3D_RenderTarget :: C3D_RenderTarget_tag;

C3D_RenderTarget_tag :: struct {
    next:          *C3D_RenderTarget;
    prev:          *C3D_RenderTarget #align 4;
    frameBuf:      C3D_FrameBuf;
    used:          bool;
    ownsColor:     bool;
    ownsDepth:     bool;
    linked:        bool;
    screen:        gfxScreen_t;
    side:          gfx3dSide_t;
    transferFlags: u32;
}

// Flags for C3D_FrameBegin
C3D_FRAME :: enum u8 {
    SYNCDRAW :: 1;
    NONBLOCK :: 2;
}

C3D_FrameRate :: (fps: float) -> float #foreign libcitro3d;
C3D_FrameSync :: () #foreign libcitro3d;
C3D_FrameCounter :: (id: s32) -> u32 #foreign libcitro3d;

C3D_FrameBegin :: (flags: u8) -> bool #foreign libcitro3d;
C3D_FrameDrawOn :: (target: *C3D_RenderTarget) -> bool #foreign libcitro3d;
C3D_FrameSplit :: (flags: u8) #foreign libcitro3d;
C3D_FrameEnd :: (flags: u8) #foreign libcitro3d;

C3D_FrameEndHook :: (hook: #type (unknown0: *void) #c_call, param: *void) #foreign libcitro3d;

C3D_GetDrawingTime :: () -> float #foreign libcitro3d;
C3D_GetProcessingTime :: () -> float #foreign libcitro3d;

C3D_DEPTHTYPE :: union {
    __i: s32;
    __e: GPU_DEPTHBUF;
}

C3D_DEPTHTYPE_OK :: inline (_x : C3D_DEPTHTYPE) -> bool {
    return _x.__i >= 0;
}

C3D_DEPTHTYPE_VAL :: inline (_x : C3D_DEPTHTYPE) -> GPU_DEPTHBUF {
    return _x.__e;
}

C3D_RenderTargetCreate :: (width: s32, height: s32, colorFmt: GPU_COLORBUF, depthFmt: C3D_DEPTHTYPE) -> *C3D_RenderTarget #foreign libcitro3d;
C3D_RenderTargetCreateFromTex :: (tex: *C3D_Tex, face: GPU_TEXFACE, level: s32, depthFmt: C3D_DEPTHTYPE) -> *C3D_RenderTarget #foreign libcitro3d;
C3D_RenderTargetDelete :: (target: *C3D_RenderTarget) #foreign libcitro3d;
C3D_RenderTargetSetOutput :: (target: *C3D_RenderTarget, screen: gfxScreen_t, side: gfx3dSide_t, transferFlags: u32) #foreign libcitro3d;

C3D_RenderTargetClear :: inline (target: *C3D_RenderTarget, clearBits: C3D_ClearBits, clearColor: u32, clearDepth: u32) {
    C3D_FrameBufClear(*target.frameBuf, clearBits, clearColor, clearDepth);
}

C3D_SyncDisplayTransfer :: (inadr: *u32, indim: u32, outadr: *u32, outdim: u32, flags: u32) #foreign libcitro3d;
C3D_SyncTextureCopy :: (inadr: *u32, indim: u32, outadr: *u32, outdim: u32, size: u32, flags: u32) #foreign libcitro3d;
C3D_SyncMemoryFill :: (buf0a: *u32, buf0v: u32, buf0e: *u32, control0: u16, buf1a: *u32, buf1v: u32, buf1e: *u32, control1: u16) #foreign libcitro3d;

/** @brief Subtexture
*  @note If top < bottom, the subtexture is rotated 1/4 revolution counter-clockwise
*/
Tex3DS_SubTexture :: struct {
    width:  u16; ///< Sub-texture width (pixels)
    height: u16; ///< Sub-texture height (pixels)
    left:   float; ///< Left u-coordinate
    top:    float; ///< Top v-coordinate
    right:  float; ///< Right u-coordinate
    bottom: float; ///< Bottom v-coordinate
}

Tex3DS_Texture_s :: struct {}
/** @brief Texture */
Tex3DS_Texture :: *Tex3DS_Texture_s;

/** @brief Import Tex3DS texture
*  @param[in]  input   Input data
*  @param[in]  insize  Size of the input data
*  @param[out] tex     citro3d texture
*  @param[out] texcube citro3d texcube
*  @param[in]  vram    Whether to store textures in VRAM
*  @returns Tex3DS texture
*/
Tex3DS_TextureImport :: (input: *void, insize: size_t, tex: *C3D_Tex, texcube: *C3D_TexCube, vram: bool) -> Tex3DS_Texture #foreign libcitro3d;

/** @brief Import Tex3DS texture
*
*  @description
*  For example, use this if you want to import from a large file without
*  pulling the entire file into memory.
*
*  @param[out] tex      citro3d texture
*  @param[out] texcube  citro3d texcube
*  @param[in]  vram     Whether to store textures in VRAM
*  @param[in]  callback Data callback
*  @param[in]  userdata User data passed to callback
*  @returns Tex3DS texture
*/
Tex3DS_TextureImportCallback :: (tex: *C3D_Tex, texcube: *C3D_TexCube, vram: bool, callback: decompressCallback, userdata: *void) -> Tex3DS_Texture #foreign libcitro3d;

/** @brief Import Tex3DS texture
*
*  Starts reading at the current file descriptor's offset. The file
*  descriptor's position is left at the end of the decoded data. On error, the
*  file descriptor's position is indeterminate.
*
*  @param[in]  fd       Open file descriptor
*  @param[out] tex      citro3d texture
*  @param[out] texcube  citro3d texcube
*  @param[in]  vram     Whether to store textures in VRAM
*  @returns Tex3DS texture
*/
Tex3DS_TextureImportFD :: (fd: s32, tex: *C3D_Tex, texcube: *C3D_TexCube, vram: bool) -> Tex3DS_Texture #foreign libcitro3d;

/** @brief Import Tex3DS texture
*
*  Starts reading at the current file stream's offset. The file stream's
*  position is left at the end of the decoded data. On error, the file
*  stream's position is indeterminate.
*
*  @param[in]  fp       Open file stream
*  @param[out] tex      citro3d texture
*  @param[out] texcube  citro3d texcube
*  @param[in]  vram     Whether to store textures in VRAM
*  @returns Tex3DS texture
*/
Tex3DS_TextureImportStdio :: (fp: *FILE, tex: *C3D_Tex, texcube: *C3D_TexCube, vram: bool) -> Tex3DS_Texture #foreign libcitro3d;

/** @brief Get number of subtextures
*  @param[in] texture Tex3DS texture
*  @returns Number of subtextures
*/
Tex3DS_GetNumSubTextures :: (texture: Tex3DS_Texture) -> size_t #foreign libcitro3d;

/** @brief Get subtexture
*  @param[in] texture Tex3DS texture
*  @param[in] index   Subtexture index
*  @returns Subtexture info
*/
Tex3DS_GetSubTexture :: (texture: Tex3DS_Texture, index: size_t) -> *Tex3DS_SubTexture #foreign libcitro3d;


/** @brief Check if subtexture is rotated
 *  @param[in] subtex Subtexture to check
 *  @returns whether subtexture is rotated
 */
Tex3DS_SubTextureRotated :: inline (subtex: *Tex3DS_SubTexture) {
    return subtex.top < subtex.bottom;
}

/** @brief Get bottom-left texcoords
 *  @param[in]  subtex Subtexture
 *  @param[out] u      u-coordinate
 *  @param[out] v      v-coordinate
 */
Tex3DS_SubTextureBottomLeft :: inline (subtex: *Tex3DS_SubTexture, u: *float, v: *float) {
    if !Tex3DS_SubTextureRotated(subtex) {
        <<u = subtex.left;
        <<v = subtex.bottom;
    }
    else {
        <<u = subtex.bottom;
        <<v = subtex.left;
    }
}

/** @brief Get bottom-right texcoords
 *  @param[in]  subtex Subtexture
 *  @param[out] u      u-coordinate
 *  @param[out] v      v-coordinate
 */
Tex3DS_SubTextureBottomRight :: inline (subtex: *Tex3DS_SubTexture, u: *float, v: *float) {
    if !Tex3DS_SubTextureRotated(subtex) {
        <<u = subtex.right;
        <<v = subtex.bottom;
    }
    else {
        <<u = subtex.bottom;
        <<v = subtex.right;
    }
}

/** @brief Get top-left texcoords
 *  @param[in]  subtex Subtexture
 *  @param[out] u      u-coordinate
 *  @param[out] v      v-coordinate
 */
Tex3DS_SubTextureTopLeft :: inline (subtex: *Tex3DS_SubTexture, u: *float, v: *float) {
    if !Tex3DS_SubTextureRotated(subtex) {
        <<u = subtex.left;
        <<v = subtex.top;
    }
    else {
        <<u = subtex.top;
        <<v = subtex.left;
    }
}

/** @brief Get top-right texcoords
 *  @param[in]  subtex Subtexture
 *  @param[out] u      u-coordinate
 *  @param[out] v      v-coordinate
 */
Tex3DS_SubTextureTopRight :: inline (subtex: *Tex3DS_SubTexture, u: *float, v: *float) {
    if !Tex3DS_SubTextureRotated(subtex) {
        <<u = subtex.right;
        <<v = subtex.top;
    }
    else {
        <<u = subtex.top;
        <<v = subtex.right;
    }
}

/** @brief Free Tex3DS texture
*  @param[in] texture Tex3DS texture to free
*/
Tex3DS_TextureFree :: (texture: Tex3DS_Texture) #foreign libcitro3d;

#scope_file

libctru :: #foreign_system_library,no_dll "libctru";
libcitro3d :: #foreign_system_library,no_dll "libcitro3d";
