// ThreeExtras.js r38 - http://github.com/mrdoob/three.js
var GeometryUtils = {
    merge: function (a, f) {
        var b = f instanceof THREE.Mesh,
            c = a.vertices.length,
            e = b ? f.geometry : f,
            d = a.vertices,
            g = e.vertices,
            h = a.faces,
            m = e.faces,
            k = a.faceVertexUvs[0];
        e = e.faceVertexUvs[0];
        b && f.matrixAutoUpdate && f.updateMatrix();
        for (var j = 0, n = g.length; j < n; j++) {
            var p = new THREE.Vertex(g[j].position.clone());
            b && f.matrix.multiplyVector3(p.position);
            d.push(p)
        }
        j = 0;
        for (n = m.length; j < n; j++) {
            g = m[j];
            var t, w, x = g.vertexNormals;
            p = g.vertexColors;
            if (g instanceof THREE.Face3) t = new THREE.Face3(g.a + c, g.b + c, g.c + c);
            else g instanceof THREE.Face4 && (t = new THREE.Face4(g.a + c, g.b + c, g.c + c, g.d + c));
            t.normal.copy(g.normal);
            b = 0;
            for (d = x.length; b < d; b++) {
                w = x[b];
                t.vertexNormals.push(w.clone())
            }
            t.color.copy(g.color);
            b = 0;
            for (d = p.length; b < d; b++) {
                w = p[b];
                t.vertexColors.push(w.clone())
            }
            t.materials = g.materials.slice();
            t.centroid.copy(g.centroid);
            h.push(t)
        }
        j = 0;
        for (n = e.length; j < n; j++) {
            c = e[j];
            h = [];
            b = 0;
            for (d = c.length; b < d; b++) h.push(new THREE.UV(c[b].u, c[b].v));
            k.push(h)
        }
    }
}, ImageUtils = {
    loadTexture: function (a, f, b) {
        var c = new Image,
            e = new THREE.Texture(c, f);
        c.onload = function () {
            e.needsUpdate = !0;
            b && b(this)
        };
        c.src = a;
        return e
    },
    loadTextureCube: function (a, f, b) {
        var c, e = [],
            d = new THREE.Texture(e, f);
        f = e.loadCount = 0;
        for (c = a.length; f < c; ++f) {
            e[f] = new Image;
            e[f].onload = function () {
                e.loadCount += 1;
                if (e.loadCount == 6) d.needsUpdate = !0;
                b && b(this)
            };
            e[f].src = a[f]
        }
        return d
    }
}, SceneUtils = {
    loadScene: function (a, f, b, c) {
        var e = new Worker(a);
        e.postMessage(0);
        var d = THREE.Loader.prototype.extractUrlbase(a);
        e.onmessage = function (g) {
            function h(V, W) {
                return W == "relativeToHTML" ? V : d + "/" + V
            }
            function m() {
                for (t in E.objects) if (!F.objects[t]) {
                    y = E.objects[t];
                    if (G = F.geometries[y.geometry]) {
                        I = [];
                        for (M = 0; M < y.materials.length; M++) I[M] = F.materials[y.materials[M]];
                        l = y.position;
                        r = y.rotation;
                        q = y.quaternion;
                        s = y.scale;
                        q = 0;
                        I.length == 0 && (I[0] = new THREE.MeshFaceMaterial);
                        object = new THREE.Mesh(G, I);
                        object.position.set(l[0], l[1], l[2]);
                        if (q) {
                            object.quaternion.set(q[0], q[1], q[2], q[3]);
                            object.useQuaternion = !0
                        } else object.rotation.set(r[0], r[1], r[2]);
                        object.scale.set(s[0], s[1], s[2]);
                        object.visible = y.visible;
                        F.scene.addObject(object);
                        F.objects[t] = object
                    }
                }
            }
            function k(V) {
                return function (W) {
                    F.geometries[V] = W;
                    m();
                    P -= 1;
                    j()
                }
            }
            function j() {
                c({
                    total_models: O,
                    total_textures: R,
                    loaded_models: O - P,
                    loaded_textures: R - N
                }, F);
                P == 0 && N == 0 && b(F)
            }
            var n, p, t, w, x, u, B, y, l, z, C, G, K, J, I, E, L, S, P, N, O, R, F;
            E = g.data;
            L = new THREE.BinaryLoader;
            S = new THREE.JSONLoader;
            N = P = 0;
            F = {
                scene: new THREE.Scene,
                geometries: {},
                materials: {},
                textures: {},
                objects: {},
                cameras: {},
                lights: {},
                fogs: {}
            };
            g = function () {
                N -= 1;
                j()
            };
            for (x in E.cameras) {
                z = E.cameras[x];
                if (z.type == "perspective") K = new THREE.Camera(z.fov, z.aspect, z.near, z.far);
                else if (z.type == "ortho") {
                    K = new THREE.Camera;
                    K.projectionMatrix = THREE.Matrix4.makeOrtho(z.left, z.right, z.top, z.bottom, z.near, z.far)
                }
                l = z.position;
                z = z.target;
                K.position.set(l[0], l[1], l[2]);
                K.target.position.set(z[0], z[1], z[2]);
                F.cameras[x] = K
            }
            for (w in E.lights) {
                x = E.lights[w];
                K = x.color !== undefined ? x.color : 16777215;
                z = x.intensity !== undefined ? x.intensity : 1;
                if (x.type == "directional") {
                    l = x.direction;
                    light = new THREE.DirectionalLight(K, z);
                    light.position.set(l[0], l[1], l[2]);
                    light.position.normalize()
                } else if (x.type == "point") {
                    l = x.position;
                    light = new THREE.PointLight(K, z);
                    light.position.set(l[0], l[1], l[2])
                }
                F.scene.addLight(light);
                F.lights[w] = light
            }
            for (u in E.fogs) {
                w = E.fogs[u];
                if (w.type == "linear") J = new THREE.Fog(0, w.near, w.far);
                else w.type == "exp2" && (J = new THREE.FogExp2(0, w.density));
                z = w.color;
                J.color.setRGB(z[0], z[1], z[2]);
                F.fogs[u] = J
            }
            if (F.cameras && E.defaults.camera) F.currentCamera = F.cameras[E.defaults.camera];
            if (F.fogs && E.defaults.fog) F.scene.fog = F.fogs[E.defaults.fog];
            z = E.defaults.bgcolor;
            F.bgColor = new THREE.Color;
            F.bgColor.setRGB(z[0], z[1], z[2]);
            F.bgColorAlpha = E.defaults.bgalpha;
            for (n in E.geometries) {
                u = E.geometries[n];
                if (u.type == "bin_mesh" || u.type == "ascii_mesh") P += 1
            }
            O = P;
            for (n in E.geometries) {
                u = E.geometries[n];
                if (u.type == "cube") {
                    G = new Cube(u.width, u.height, u.depth, u.segmentsWidth, u.segmentsHeight, u.segmentsDepth, null, u.flipped, u.sides);
                    F.geometries[n] = G
                } else if (u.type == "plane") {
                    G = new Plane(u.width, u.height, u.segmentsWidth, u.segmentsHeight);
                    F.geometries[n] = G
                } else if (u.type == "sphere") {
                    G = new Sphere(u.radius, u.segmentsWidth, u.segmentsHeight);
                    F.geometries[n] = G
                } else if (u.type == "cylinder") {
                    G = new Cylinder(u.numSegs, u.topRad, u.botRad, u.height, u.topOffset, u.botOffset);
                    F.geometries[n] = G
                } else if (u.type == "torus") {
                    G = new Torus(u.radius, u.tube, u.segmentsR, u.segmentsT);
                    F.geometries[n] = G
                } else if (u.type == "icosahedron") {
                    G = new Icosahedron(u.subdivisions);
                    F.geometries[n] = G
                } else if (u.type == "bin_mesh") L.load({
                    model: h(u.url, E.urlBaseType),
                    callback: k(n)
                });
                else u.type == "ascii_mesh" && S.load({
                    model: h(u.url, E.urlBaseType),
                    callback: k(n)
                })
            }
            for (B in E.textures) {
                n = E.textures[B];
                N += n.url instanceof Array ? n.url.length : 1
            }
            R = N;
            for (B in E.textures) {
                n = E.textures[B];
                if (n.mapping != undefined && THREE[n.mapping] != undefined) n.mapping = new THREE[n.mapping];
                if (n.url instanceof Array) {
                    u = [];
                    for (var M = 0; M < n.url.length; M++) u[M] = h(n.url[M], E.urlBaseType);
                    u = ImageUtils.loadTextureCube(u, n.mapping, g)
                } else {
                    u = ImageUtils.loadTexture(h(n.url, E.urlBaseType), n.mapping, g);
                    if (THREE[n.minFilter] != undefined) u.minFilter = THREE[n.minFilter];
                    if (THREE[n.magFilter] != undefined) u.magFilter = THREE[n.magFilter]
                }
                F.textures[B] = u
            }
            for (p in E.materials) {
                B = E.materials[p];
                for (C in B.parameters) if (C == "envMap" || C == "map" || C == "lightMap") B.parameters[C] = F.textures[B.parameters[C]];
                else if (C == "shading") B.parameters[C] = B.parameters[C] == "flat" ? THREE.FlatShading : THREE.SmoothShading;
                else if (C == "blending") B.parameters[C] = THREE[B.parameters[C]] ? THREE[B.parameters[C]] : THREE.NormalBlending;
                else C == "combine" && (B.parameters[C] = B.parameters[C] == "MixOperation" ? THREE.MixOperation : THREE.MultiplyOperation);
                B = new THREE[B.type](B.parameters);
                F.materials[p] = B
            }
            m();
            f(F)
        }
    },
    addMesh: function (a, f, b, c, e, d, g, h, m, k) {
        f = new THREE.Mesh(f, k);
        f.scale.x = f.scale.y = f.scale.z = b;
        f.position.x = c;
        f.position.y = e;
        f.position.z = d;
        f.rotation.x = g;
        f.rotation.y = h;
        f.rotation.z = m;
        a.addObject(f);
        return f
    },
    addPanoramaCubeWebGL: function (a, f, b) {
        var c = ShaderUtils.lib.cube;
        c.uniforms.tCube.texture = b;
        b = new THREE.MeshShaderMaterial({
            fragmentShader: c.fragmentShader,
            vertexShader: c.vertexShader,
            uniforms: c.uniforms
        });
        f = new THREE.Mesh(new Cube(f, f, f, 1, 1, 1, null, !0), b);
        a.addObject(f);
        return f
    },
    addPanoramaCube: function (a, f, b) {
        var c = [];
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[0])
        }));
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[1])
        }));
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[2])
        }));
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[3])
        }));
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[4])
        }));
        c.push(new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[5])
        }));
        f = new THREE.Mesh(new Cube(f, f, f, 1, 1, c, !0), new THREE.MeshFaceMaterial);
        a.addObject(f);
        return f
    },
    addPanoramaCubePlanes: function (a, f, b) {
        var c = f / 2;
        f = new Plane(f, f);
        var e = Math.PI,
            d = Math.PI / 2;
        SceneUtils.addMesh(a, f, 1, 0, 0, - c, 0, 0, 0, new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[5])
        }));
        SceneUtils.addMesh(a, f, 1, - c, 0, 0, 0, d, 0, new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[0])
        }));
        SceneUtils.addMesh(a, f, 1, c, 0, 0, 0, - d, 0, new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[1])
        }));
        SceneUtils.addMesh(a,
        f, 1, 0, c, 0, d, 0, e, new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[2])
        }));
        SceneUtils.addMesh(a, f, 1, 0, - c, 0, - d, 0, e, new THREE.MeshBasicMaterial({
            map: new THREE.Texture(b[3])
        }))
    },
    showHierarchy: function (a, f) {
        SceneUtils.traverseHierarchy(a, function (b) {
            b.visible = f
        })
    },
    traverseHierarchy: function (a, f) {
        var b, c, e = a.children.length;
        for (c = 0; c < e; c++) {
            b = a.children[c];
            f(b);
            SceneUtils.traverseHierarchy(b, f)
        }
    }
}, ShaderUtils = {
    lib: {
        fresnel: {
            uniforms: {
                mRefractionRatio: {
                    type: "f",
                    value: 1.02
                },
                mFresnelBias: {
                    type: "f",
                    value: 0.1
                },
                mFresnelPower: {
                    type: "f",
                    value: 2
                },
                mFresnelScale: {
                    type: "f",
                    value: 1
                },
                tCube: {
                    type: "t",
                    value: 1,
                    texture: null
                }
            },
            fragmentShader: "uniform samplerCube tCube;\nvarying vec3 vReflect;\nvarying vec3 vRefract[3];\nvarying float vReflectionFactor;\nvoid main() {\nvec4 reflectedColor = textureCube( tCube, vec3( -vReflect.x, vReflect.yz ) );\nvec4 refractedColor = vec4( 1.0, 1.0, 1.0, 1.0 );\nrefractedColor.r = textureCube( tCube, vec3( -vRefract[0].x, vRefract[0].yz ) ).r;\nrefractedColor.g = textureCube( tCube, vec3( -vRefract[1].x, vRefract[1].yz ) ).g;\nrefractedColor.b = textureCube( tCube, vec3( -vRefract[2].x, vRefract[2].yz ) ).b;\nrefractedColor.a = 1.0;\ngl_FragColor = mix( refractedColor, reflectedColor, clamp( vReflectionFactor, 0.0, 1.0 ) );\n}",
            vertexShader: "uniform float mRefractionRatio;\nuniform float mFresnelBias;\nuniform float mFresnelScale;\nuniform float mFresnelPower;\nvarying vec3 vReflect;\nvarying vec3 vRefract[3];\nvarying float vReflectionFactor;\nvoid main() {\nvec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );\nvec4 mPosition = objectMatrix * vec4( position, 1.0 );\nvec3 nWorld = normalize ( mat3( objectMatrix[0].xyz, objectMatrix[1].xyz, objectMatrix[2].xyz ) * normal );\nvec3 I = mPosition.xyz - cameraPosition;\nvReflect = reflect( I, nWorld );\nvRefract[0] = refract( normalize( I ), nWorld, mRefractionRatio );\nvRefract[1] = refract( normalize( I ), nWorld, mRefractionRatio * 0.99 );\nvRefract[2] = refract( normalize( I ), nWorld, mRefractionRatio * 0.98 );\nvReflectionFactor = mFresnelBias + mFresnelScale * pow( 1.0 + dot( normalize( I ), nWorld ), mFresnelPower );\ngl_Position = projectionMatrix * mvPosition;\n}"
        },
        normal: {
            uniforms: {
                enableAO: {
                    type: "i",
                    value: 0
                },
                enableDiffuse: {
                    type: "i",
                    value: 0
                },
                tDiffuse: {
                    type: "t",
                    value: 0,
                    texture: null
                },
                tNormal: {
                    type: "t",
                    value: 2,
                    texture: null
                },
                tAO: {
                    type: "t",
                    value: 3,
                    texture: null
                },
                uNormalScale: {
                    type: "f",
                    value: 1
                },
                tDisplacement: {
                    type: "t",
                    value: 4,
                    texture: null
                },
                uDisplacementBias: {
                    type: "f",
                    value: -0.5
                },
                uDisplacementScale: {
                    type: "f",
                    value: 2.5
                },
                uPointLightPos: {
                    type: "v3",
                    value: new THREE.Vector3
                },
                uPointLightColor: {
                    type: "c",
                    value: new THREE.Color(15658734)
                },
                uDirLightPos: {
                    type: "v3",
                    value: new THREE.Vector3
                },
                uDirLightColor: {
                    type: "c",
                    value: new THREE.Color(15658734)
                },
                uAmbientLightColor: {
                    type: "c",
                    value: new THREE.Color(328965)
                },
                uDiffuseColor: {
                    type: "c",
                    value: new THREE.Color(15658734)
                },
                uSpecularColor: {
                    type: "c",
                    value: new THREE.Color(1118481)
                },
                uAmbientColor: {
                    type: "c",
                    value: new THREE.Color(328965)
                },
                uShininess: {
                    type: "f",
                    value: 30
                }
            },
            fragmentShader: "uniform vec3 uDirLightPos;\nuniform vec3 uAmbientLightColor;\nuniform vec3 uDirLightColor;\nuniform vec3 uPointLightColor;\nuniform vec3 uAmbientColor;\nuniform vec3 uDiffuseColor;\nuniform vec3 uSpecularColor;\nuniform float uShininess;\nuniform bool enableDiffuse;\nuniform bool enableAO;\nuniform sampler2D tDiffuse;\nuniform sampler2D tNormal;\nuniform sampler2D tAO;\nuniform float uNormalScale;\nvarying vec3 vTangent;\nvarying vec3 vBinormal;\nvarying vec3 vNormal;\nvarying vec2 vUv;\nvarying vec3 vPointLightVector;\nvarying vec3 vViewPosition;\nvoid main() {\nvec3 diffuseTex = vec3( 1.0, 1.0, 1.0 );\nvec3 aoTex = vec3( 1.0, 1.0, 1.0 );\nvec3 normalTex = texture2D( tNormal, vUv ).xyz * 2.0 - 1.0;\nnormalTex.xy *= uNormalScale;\nnormalTex = normalize( normalTex );\nif( enableDiffuse )\ndiffuseTex = texture2D( tDiffuse, vUv ).xyz;\nif( enableAO )\naoTex = texture2D( tAO, vUv ).xyz;\nmat3 tsb = mat3( vTangent, vBinormal, vNormal );\nvec3 finalNormal = tsb * normalTex;\nvec3 normal = normalize( finalNormal );\nvec3 viewPosition = normalize( vViewPosition );\nvec4 pointDiffuse  = vec4( 0.0, 0.0, 0.0, 0.0 );\nvec4 pointSpecular = vec4( 0.0, 0.0, 0.0, 0.0 );\nvec3 pointVector = normalize( vPointLightVector );\nvec3 pointHalfVector = normalize( vPointLightVector + vViewPosition );\nfloat pointDotNormalHalf = dot( normal, pointHalfVector );\nfloat pointDiffuseWeight = max( dot( normal, pointVector ), 0.0 );\nfloat pointSpecularWeight = 0.0;\nif ( pointDotNormalHalf >= 0.0 )\npointSpecularWeight = pow( pointDotNormalHalf, uShininess );\npointDiffuse  += vec4( uDiffuseColor, 1.0 ) * pointDiffuseWeight;\npointSpecular += vec4( uSpecularColor, 1.0 ) * pointSpecularWeight;\nvec4 dirDiffuse  = vec4( 0.0, 0.0, 0.0, 0.0 );\nvec4 dirSpecular = vec4( 0.0, 0.0, 0.0, 0.0 );\nvec4 lDirection = viewMatrix * vec4( uDirLightPos, 0.0 );\nvec3 dirVector = normalize( lDirection.xyz );\nvec3 dirHalfVector = normalize( lDirection.xyz + vViewPosition );\nfloat dirDotNormalHalf = dot( normal, dirHalfVector );\nfloat dirDiffuseWeight = max( dot( normal, dirVector ), 0.0 );\nfloat dirSpecularWeight = 0.0;\nif ( dirDotNormalHalf >= 0.0 )\ndirSpecularWeight = pow( dirDotNormalHalf, uShininess );\ndirDiffuse  += vec4( uDiffuseColor, 1.0 ) * dirDiffuseWeight;\ndirSpecular += vec4( uSpecularColor, 1.0 ) * dirSpecularWeight;\nvec4 totalLight = vec4( uAmbientLightColor * uAmbientColor, 1.0 );\ntotalLight += vec4( uDirLightColor, 1.0 ) * ( dirDiffuse + dirSpecular );\ntotalLight += vec4( uPointLightColor, 1.0 ) * ( pointDiffuse + pointSpecular );\ngl_FragColor = vec4( totalLight.xyz * aoTex * diffuseTex, 1.0 );\n}",
            vertexShader: "attribute vec4 tangent;\nuniform vec3 uPointLightPos;\n#ifdef VERTEX_TEXTURES\nuniform sampler2D tDisplacement;\nuniform float uDisplacementScale;\nuniform float uDisplacementBias;\n#endif\nvarying vec3 vTangent;\nvarying vec3 vBinormal;\nvarying vec3 vNormal;\nvarying vec2 vUv;\nvarying vec3 vPointLightVector;\nvarying vec3 vViewPosition;\nvoid main() {\nvec4 mPosition = objectMatrix * vec4( position, 1.0 );\nvViewPosition = cameraPosition - mPosition.xyz;\nvec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );\nvNormal = normalize( normalMatrix * normal );\nvTangent = normalize( normalMatrix * tangent.xyz );\nvBinormal = cross( vNormal, vTangent ) * tangent.w;\nvBinormal = normalize( vBinormal );\nvUv = uv;\nvec4 lPosition = viewMatrix * vec4( uPointLightPos, 1.0 );\nvPointLightVector = normalize( lPosition.xyz - mvPosition.xyz );\n#ifdef VERTEX_TEXTURES\nvec3 dv = texture2D( tDisplacement, uv ).xyz;\nfloat df = uDisplacementScale * dv.x + uDisplacementBias;\nvec4 displacedPosition = vec4( vNormal.xyz * df, 0.0 ) + mvPosition;\ngl_Position = projectionMatrix * displacedPosition;\n#else\ngl_Position = projectionMatrix * mvPosition;\n#endif\n}"
        },
        cube: {
            uniforms: {
                tCube: {
                    type: "t",
                    value: 1,
                    texture: null
                }
            },
            vertexShader: "varying vec3 vViewPosition;\nvoid main() {\nvec4 mPosition = objectMatrix * vec4( position, 1.0 );\nvViewPosition = cameraPosition - mPosition.xyz;\ngl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}",
            fragmentShader: "uniform samplerCube tCube;\nvarying vec3 vViewPosition;\nvoid main() {\nvec3 wPos = cameraPosition - vViewPosition;\ngl_FragColor = textureCube( tCube, vec3( - wPos.x, wPos.yz ) );\n}"
        },
        convolution: {
            uniforms: {
                tDiffuse: {
                    type: "t",
                    value: 0,
                    texture: null
                },
                uImageIncrement: {
                    type: "v2",
                    value: new THREE.Vector2(0.001953125, 0)
                },
                cKernel: {
                    type: "fv1",
                    value: []
                }
            },
            vertexShader: "varying vec2 vUv;\nuniform vec2 uImageIncrement;\nvoid main(void) {\nvUv = uv - ((KERNEL_SIZE - 1.0) / 2.0) * uImageIncrement;\ngl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}",
            fragmentShader: "varying vec2 vUv;\nuniform sampler2D tDiffuse;\nuniform vec2 uImageIncrement;\nuniform float cKernel[KERNEL_SIZE];\nvoid main(void) {\nvec2 imageCoord = vUv;\nvec4 sum = vec4( 0.0, 0.0, 0.0, 0.0 );\nfor( int i=0; i<KERNEL_SIZE; ++i ) {\nsum += texture2D( tDiffuse, imageCoord ) * cKernel[i];\nimageCoord += uImageIncrement;\n}\ngl_FragColor = sum;\n}"
        },
        film: {
            uniforms: {
                tDiffuse: {
                    type: "t",
                    value: 0,
                    texture: null
                },
                time: {
                    type: "f",
                    value: 0
                },
                nIntensity: {
                    type: "f",
                    value: 0.5
                },
                sIntensity: {
                    type: "f",
                    value: 0.05
                },
                sCount: {
                    type: "f",
                    value: 4096
                },
                grayscale: {
                    type: "i",
                    value: 1
                }
            },
            vertexShader: "varying vec2 vUv;\nvoid main() {\nvUv = vec2( uv.x, 1.0 - uv.y );\ngl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}",
            fragmentShader: "varying vec2 vUv;\nuniform sampler2D tDiffuse;\nuniform float time;\nuniform bool grayscale;\nuniform float nIntensity;\nuniform float sIntensity;\nuniform float sCount;\nvoid main() {\nvec4 cTextureScreen = texture2D( tDiffuse, vUv );\nfloat x = vUv.x * vUv.y * time *  1000.0;\nx = mod( x, 13.0 ) * mod( x, 123.0 );\nfloat dx = mod( x, 0.01 );\nvec3 cResult = cTextureScreen.rgb + cTextureScreen.rgb * clamp( 0.1 + dx * 100.0, 0.0, 1.0 );\nvec2 sc = vec2( sin( vUv.y * sCount ), cos( vUv.y * sCount ) );\ncResult += cTextureScreen.rgb * vec3( sc.x, sc.y, sc.x ) * sIntensity;\ncResult = cTextureScreen.rgb + clamp( nIntensity, 0.0,1.0 ) * ( cResult - cTextureScreen.rgb );\nif( grayscale ) {\ncResult = vec3( cResult.r * 0.3 + cResult.g * 0.59 + cResult.b * 0.11 );\n}\ngl_FragColor =  vec4( cResult, cTextureScreen.a );\n}"
        },
        screen: {
            uniforms: {
                tDiffuse: {
                    type: "t",
                    value: 0,
                    texture: null
                },
                opacity: {
                    type: "f",
                    value: 1
                }
            },
            vertexShader: "varying vec2 vUv;\nvoid main() {\nvUv = vec2( uv.x, 1.0 - uv.y );\ngl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}",
            fragmentShader: "varying vec2 vUv;\nuniform sampler2D tDiffuse;\nuniform float opacity;\nvoid main() {\nvec4 texel = texture2D( tDiffuse, vUv );\ngl_FragColor = opacity * texel;\n}"
        },
        basic: {
            uniforms: {},
            vertexShader: "void main() {\ngl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );\n}",
            fragmentShader: "void main() {\ngl_FragColor = vec4( 1.0, 0.0, 0.0, 0.5 );\n}"
        }
    },
    buildKernel: function (a) {
        var f, b, c, e, d = 2 * Math.ceil(a * 3) + 1;
        d > 25 && (d = 25);
        e = (d - 1) * 0.5;
        b = Array(d);
        for (f = c = 0; f < d; ++f) {
            b[f] = Math.exp(-((f - e) * (f - e)) / (2 * a * a));
            c += b[f]
        }
        for (f = 0; f < d; ++f) b[f] /= c;
        return b
    }
};
THREE.QuakeCamera = function (a) {
    function f(b, c) {
        return function () {
            c.apply(b, arguments)
        }
    }
    THREE.Camera.call(this, a.fov, a.aspect, a.near, a.far, a.target);
    this.movementSpeed = 1;
    this.lookSpeed = 0.0050;
    this.noFly = !1;
    this.lookVertical = !0;
    this.autoForward = !1;
    this.activeLook = !0;
    this.heightSpeed = !1;
    this.heightCoef = 1;
    this.heightMin = 0;
    this.constrainVertical = !1;
    this.verticalMin = 0;
    this.verticalMax = 3.14;
    this.domElement = document;
    if (a) {
        if (a.movementSpeed !== undefined) this.movementSpeed = a.movementSpeed;
        if (a.lookSpeed !== undefined) this.lookSpeed = a.lookSpeed;
        if (a.noFly !== undefined) this.noFly = a.noFly;
        if (a.lookVertical !== undefined) this.lookVertical = a.lookVertical;
        if (a.autoForward !== undefined) this.autoForward = a.autoForward;
        if (a.activeLook !== undefined) this.activeLook = a.activeLook;
        if (a.heightSpeed !== undefined) this.heightSpeed = a.heightSpeed;
        if (a.heightCoef !== undefined) this.heightCoef = a.heightCoef;
        if (a.heightMin !== undefined) this.heightMin = a.heightMin;
        if (a.heightMax !== undefined) this.heightMax = a.heightMax;
        if (a.constrainVertical !== undefined) this.constrainVertical = a.constrainVertical;
        if (a.verticalMin !== undefined) this.verticalMin = a.verticalMin;
        if (a.verticalMax !== undefined) this.verticalMax = a.verticalMax;
        if (a.domElement !== undefined) this.domElement = a.domElement
    }
    this.theta = this.phi = this.lon = this.lat = this.mouseY = this.mouseX = this.autoSpeedFactor = 0;
    this.moveForward = !1;
    this.moveBackward = !1;
    this.moveLeft = !1;
    this.moveRight = !1;
    this.mouseDragOn = !1;
    this.windowHalfX = window.innerWidth / 2;
    this.windowHalfY = window.innerHeight / 2;
    this.onMouseDown = function (b) {
        b.preventDefault();
        b.stopPropagation();
        if (this.activeLook) switch (b.button) {
        case 0:
            this.moveForward = !0;
            break;
        case 2:
            this.moveBackward = !0
        }
        this.mouseDragOn = !0
    };
    this.onMouseUp = function (b) {
        b.preventDefault();
        b.stopPropagation();
        if (this.activeLook) switch (b.button) {
        case 0:
            this.moveForward = !1;
            break;
        case 2:
            this.moveBackward = !1
        }
        this.mouseDragOn = !1
    };
    this.onMouseMove = function (b) {
        this.mouseX = b.clientX - this.windowHalfX;
        this.mouseY = b.clientY - this.windowHalfY
    };
    this.onKeyDown = function (b) {
        switch (b.keyCode) {
        case 38:
        case 87:
            this.moveForward = !0;
            break;
        case 37:
        case 65:
            this.moveLeft = !0;
            break;
        case 40:
        case 83:
            this.moveBackward = !0;
            break;
        case 39:
        case 68:
            this.moveRight = !0
        }
    };
    this.onKeyUp = function (b) {
        switch (b.keyCode) {
        case 38:
        case 87:
            this.moveForward = !1;
            break;
        case 37:
        case 65:
            this.moveLeft = !1;
            break;
        case 40:
        case 83:
            this.moveBackward = !1;
            break;
        case 39:
        case 68:
            this.moveRight = !1
        }
    };
    this.update = function () {
        this.autoSpeedFactor = this.heightSpeed ? ((this.position.y < this.heightMin ? this.heightMin : this.position.y > this.heightMax ? this.heightMax : this.position.y) - this.heightMin) * this.heightCoef : 0;
        (this.moveForward || this.autoForward) && this.translateZ(-(this.movementSpeed + this.autoSpeedFactor));
        this.moveBackward && this.translateZ(this.movementSpeed);
        this.moveLeft && this.translateX(-this.movementSpeed);
        this.moveRight && this.translateX(this.movementSpeed);
        var b = this.lookSpeed;
        this.activeLook || (b = 0);
        this.lon += this.mouseX * b;
        this.lookVertical && (this.lat -= this.mouseY * b);
        this.lat = Math.max(-85, Math.min(85, this.lat));
        this.phi = (90 - this.lat) * Math.PI / 180;
        this.theta = this.lon * Math.PI / 180;
        if (this.constrainVertical) this.phi = (this.phi - 0) * (this.verticalMax - this.verticalMin) / 3.14 + this.verticalMin;
        b = this.target.position;
        var c = this.position;
        b.x = c.x + 100 * Math.sin(this.phi) * Math.cos(this.theta);
        b.y = c.y + 100 * Math.cos(this.phi);
        b.z = c.z + 100 * Math.sin(this.phi) * Math.sin(this.theta);
        this.supr.update.call(this)
    };
    this.domElement.addEventListener("contextmenu", function (b) {
        b.preventDefault()
    }, !1);
    this.domElement.addEventListener("mousemove", f(this, this.onMouseMove), !1);
    this.domElement.addEventListener("mousedown",
    f(this, this.onMouseDown), !1);
    this.domElement.addEventListener("mouseup", f(this, this.onMouseUp), !1);
    this.domElement.addEventListener("keydown", f(this, this.onKeyDown), !1);
    this.domElement.addEventListener("keyup", f(this, this.onKeyUp), !1)
};
THREE.QuakeCamera.prototype = new THREE.Camera;
THREE.QuakeCamera.prototype.constructor = THREE.QuakeCamera;
THREE.QuakeCamera.prototype.supr = THREE.Camera.prototype;
THREE.QuakeCamera.prototype.translate = function (a, f) {
    this.matrix.rotateAxis(f);
    if (this.noFly) f.y = 0;
    this.position.addSelf(f.multiplyScalar(a));
    this.target.position.addSelf(f.multiplyScalar(a))
};
THREE.PathCamera = function (a) {
    function f(k, j, n, p) {
        var t = {
            name: n,
            fps: 0.6,
            length: p,
            hierarchy: []
        }, w, x = j.getControlPointsArray(),
            u = j.getLength(),
            B = x.length,
            y = 0;
        w = B - 1;
        j = {
            parent: -1,
            keys: []
        };
        j.keys[0] = {
            time: 0,
            pos: x[0],
            rot: [0, 0, 0, 1],
            scl: [1, 1, 1]
        };
        j.keys[w] = {
            time: p,
            pos: x[w],
            rot: [0, 0, 0, 1],
            scl: [1, 1, 1]
        };
        for (w = 1; w < B - 1; w++) {
            y = p * u.chunks[w] / u.total;
            j.keys[w] = {
                time: y,
                pos: x[w]
            }
        }
        t.hierarchy[0] = j;
        THREE.AnimationHandler.add(t);
        return new THREE.Animation(k, n, THREE.AnimationHandler.CATMULLROM_FORWARD, !1)
    }
    function b(k, j) {
        var n,
        p, t = new THREE.Geometry;
        for (n = 0; n < k.points.length * j; n++) {
            p = n / (k.points.length * j);
            p = k.getPoint(p);
            t.vertices[n] = new THREE.Vertex(new THREE.Vector3(p.x, p.y, p.z))
        }
        return t
    }
    function c(k, j) {
        var n = b(j, 10),
            p = b(j, 10),
            t = new THREE.LineBasicMaterial({
                color: 16711680,
                linewidth: 3
            });
        lineObj = new THREE.Line(n, t);
        particleObj = new THREE.ParticleSystem(p, new THREE.ParticleBasicMaterial({
            color: 16755200,
            size: 3
        }));
        lineObj.scale.set(1, 1, 1);
        k.addChild(lineObj);
        particleObj.scale.set(1, 1, 1);
        k.addChild(particleObj);
        p = new Sphere(1,
        16, 8);
        t = new THREE.MeshBasicMaterial({
            color: 65280
        });
        for (i = 0; i < j.points.length; i++) {
            n = new THREE.Mesh(p, t);
            n.position.copy(j.points[i]);
            n.updateMatrix();
            k.addChild(n)
        }
    }
    THREE.Camera.call(this, a.fov, a.aspect, a.near, a.far, a.target);
    this.id = "PathCamera" + THREE.PathCameraIdCounter++;
    this.duration = 1E4;
    this.waypoints = [];
    this.useConstantSpeed = !0;
    this.resamplingCoef = 50;
    this.debugPath = new THREE.Object3D;
    this.debugDummy = new THREE.Object3D;
    this.animationParent = new THREE.Object3D;
    this.lookSpeed = 0.0050;
    this.lookVertical = !0;
    this.lookHorizontal = !0;
    this.verticalAngleMap = {
        srcRange: [0, 6.28],
        dstRange: [0, 6.28]
    };
    this.horizontalAngleMap = {
        srcRange: [0, 6.28],
        dstRange: [0, 6.28]
    };
    this.domElement = document;
    if (a) {
        if (a.duration !== undefined) this.duration = a.duration * 1E3;
        if (a.waypoints !== undefined) this.waypoints = a.waypoints;
        if (a.useConstantSpeed !== undefined) this.useConstantSpeed = a.useConstantSpeed;
        if (a.resamplingCoef !== undefined) this.resamplingCoef = a.resamplingCoef;
        if (a.createDebugPath !== undefined) this.createDebugPath = a.createDebugPath;
        if (a.createDebugDummy !== undefined) this.createDebugDummy = a.createDebugDummy;
        if (a.lookSpeed !== undefined) this.lookSpeed = a.lookSpeed;
        if (a.lookVertical !== undefined) this.lookVertical = a.lookVertical;
        if (a.lookHorizontal !== undefined) this.lookHorizontal = a.lookHorizontal;
        if (a.verticalAngleMap !== undefined) this.verticalAngleMap = a.verticalAngleMap;
        if (a.horizontalAngleMap !== undefined) this.horizontalAngleMap = a.horizontalAngleMap;
        if (a.domElement !== undefined) this.domElement = a.domElement
    }
    this.theta = this.phi = this.lon = this.lat = this.mouseY = this.mouseX = 0;
    this.windowHalfX = window.innerWidth / 2;
    this.windowHalfY = window.innerHeight / 2;
    var e = Math.PI * 2,
        d = Math.PI / 180;
    this.update = function (k, j, n) {
        var p, t;
        this.lookHorizontal && (this.lon += this.mouseX * this.lookSpeed);
        this.lookVertical && (this.lat -= this.mouseY * this.lookSpeed);
        this.lon = Math.max(0, Math.min(360, this.lon));
        this.lat = Math.max(-85, Math.min(85, this.lat));
        this.phi = (90 - this.lat) * d;
        this.theta = this.lon * d;
        p = this.phi % e;
        this.phi = p >= 0 ? p : p + e;
        p = this.verticalAngleMap.srcRange;
        t = this.verticalAngleMap.dstRange;
        this.phi = (this.phi - p[0]) * (t[1] - t[0]) / (p[1] - p[0]) + t[0];
        p = this.horizontalAngleMap.srcRange;
        t = this.horizontalAngleMap.dstRange;
        this.theta = (this.theta - p[0]) * (t[1] - t[0]) / (p[1] - p[0]) + t[0];
        p = this.target.position;
        p.x = 100 * Math.sin(this.phi) * Math.cos(this.theta);
        p.y = 100 * Math.cos(this.phi);
        p.z = 100 * Math.sin(this.phi) * Math.sin(this.theta);
        this.supr.update.call(this, k, j, n)
    };
    this.onMouseMove = function (k) {
        this.mouseX = k.clientX - this.windowHalfX;
        this.mouseY = k.clientY - this.windowHalfY
    };
    this.spline = new THREE.Spline;
    this.spline.initFromArray(this.waypoints);
    this.useConstantSpeed && this.spline.reparametrizeByArcLength(this.resamplingCoef);
    if (this.createDebugDummy) {
        a = new THREE.MeshLambertMaterial({
            color: 30719
        });
        var g = new THREE.MeshLambertMaterial({
            color: 65280
        }),
            h = new Cube(10, 10, 20),
            m = new Cube(2, 2, 10);
        this.animationParent = new THREE.Mesh(h, a);
        a = new THREE.Mesh(m, g);
        a.position.set(0, 10, 0);
        this.animation = f(this.animationParent, this.spline, this.id, this.duration);
        this.animationParent.addChild(this);
        this.animationParent.addChild(this.target);
        this.animationParent.addChild(a)
    } else {
        this.animation = f(this.animationParent, this.spline, this.id, this.duration);
        this.animationParent.addChild(this.target);
        this.animationParent.addChild(this)
    }
    this.createDebugPath && c(this.debugPath, this.spline);
    this.domElement.addEventListener("mousemove", function (k, j) {
        return function () {
            j.apply(k, arguments)
        }
    }(this, this.onMouseMove), !1)
};
THREE.PathCamera.prototype = new THREE.Camera;
THREE.PathCamera.prototype.constructor = THREE.PathCamera;
THREE.PathCamera.prototype.supr = THREE.Camera.prototype;
THREE.PathCameraIdCounter = 0;
var Cube = function (a, f, b, c, e, d, g, h, m) {
    function k(u, B, y, l, z, C, G, K) {
        var J, I, E = c || 1,
            L = e || 1,
            S = z / 2,
            P = C / 2,
            N = j.vertices.length;
        if (u == "x" && B == "y" || u == "y" && B == "x") J = "z";
        else if (u == "x" && B == "z" || u == "z" && B == "x") {
            J = "y";
            L = d || 1
        } else if (u == "z" && B == "y" || u == "y" && B == "z") {
            J = "x";
            E = d || 1
        }
        var O = E + 1,
            R = L + 1;
        z /= E;
        var F = C / L;
        for (I = 0; I < R; I++) for (C = 0; C < O; C++) {
            var M = new THREE.Vector3;
            M[u] = (C * z - S) * y;
            M[B] = (I * F - P) * l;
            M[J] = G;
            j.vertices.push(new THREE.Vertex(M))
        }
        for (I = 0; I < L; I++) for (C = 0; C < E; C++) {
            j.faces.push(new THREE.Face4(C + O * I + N, C + O * (I + 1) + N, C + 1 + O * (I + 1) + N, C + 1 + O * I + N, null, null, K));
            j.faceVertexUvs[0].push([new THREE.UV(C / E, I / L), new THREE.UV(C / E, (I + 1) / L), new THREE.UV((C + 1) / E, (I + 1) / L), new THREE.UV((C + 1) / E, I / L)])
        }
    }
    THREE.Geometry.call(this);
    var j = this,
        n = a / 2,
        p = f / 2,
        t = b / 2;
    h = h ? -1 : 1;
    if (g !== undefined) if (g instanceof Array) this.materials = g;
    else {
        this.materials = [];
        for (var w = 0; w < 6; w++) this.materials.push([g])
    } else this.materials = [];
    this.sides = {
        px: !0,
        nx: !0,
        py: !0,
        ny: !0,
        pz: !0,
        nz: !0
    };
    if (m != undefined) for (var x in m) this.sides[x] != undefined && (this.sides[x] = m[x]);
    this.sides.px && k("z", "y", 1 * h, - 1, b, f, - n, this.materials[0]);
    this.sides.nx && k("z", "y", - 1 * h, - 1, b, f, n, this.materials[1]);
    this.sides.py && k("x", "z", 1 * h, 1, a, b, p, this.materials[2]);
    this.sides.ny && k("x", "z", 1 * h, - 1, a, b, - p, this.materials[3]);
    this.sides.pz && k("x", "y", 1 * h, - 1, a, f, t, this.materials[4]);
    this.sides.nz && k("x", "y", - 1 * h, - 1, a, f, - t, this.materials[5]);
    (function () {
        for (var u = [], B = [], y = 0, l = j.vertices.length; y < l; y++) {
            for (var z = j.vertices[y], C = !1, G = 0, K = u.length; G < K; G++) {
                var J = u[G];
                if (z.position.x == J.position.x && z.position.y == J.position.y && z.position.z == J.position.z) {
                    B[y] = G;
                    C = !0;
                    break
                }
            }
            if (!C) {
                B[y] = u.length;
                u.push(new THREE.Vertex(z.position.clone()))
            }
        }
        y = 0;
        for (l = j.faces.length; y < l; y++) {
            z = j.faces[y];
            z.a = B[z.a];
            z.b = B[z.b];
            z.c = B[z.c];
            z.d = B[z.d]
        }
        j.vertices = u
    })();
    this.computeCentroids();
    this.computeFaceNormals()
};
Cube.prototype = new THREE.Geometry;
Cube.prototype.constructor = Cube;
var Cylinder = function (a, f, b, c, e, d) {
    function g(j, n, p) {
        h.vertices.push(new THREE.Vertex(new THREE.Vector3(j, n, p)))
    }
    THREE.Geometry.call(this);
    var h = this,
        m = Math.PI,
        k = c / 2;
    for (c = 0; c < a; c++) g(Math.sin(2 * m * c / a) * f, Math.cos(2 * m * c / a) * f, - k);
    for (c = 0; c < a; c++) g(Math.sin(2 * m * c / a) * b, Math.cos(2 * m * c / a) * b, k);
    for (c = 0; c < a; c++) h.faces.push(new THREE.Face4(c, c + a, a + (c + 1) % a, (c + 1) % a));
    if (b > 0) {
        g(0, 0, - k - (d || 0));
        for (c = a; c < a + a / 2; c++) h.faces.push(new THREE.Face4(2 * a, (2 * c - 2 * a) % a, (2 * c - 2 * a + 1) % a, (2 * c - 2 * a + 2) % a))
    }
    if (f > 0) {
        g(0, 0, k + (e || 0));
        for (c = a + a / 2; c < 2 * a; c++) h.faces.push(new THREE.Face4(2 * a + 1, (2 * c - 2 * a + 2) % a + a, (2 * c - 2 * a + 1) % a + a, (2 * c - 2 * a) % a + a))
    }
    this.computeCentroids();
    this.computeFaceNormals()
};
Cylinder.prototype = new THREE.Geometry;
Cylinder.prototype.constructor = Cylinder;
var Icosahedron = function (a) {
    function f(n, p, t) {
        var w = Math.sqrt(n * n + p * p + t * t);
        return e.vertices.push(new THREE.Vertex(new THREE.Vector3(n / w, p / w, t / w))) - 1
    }
    function b(n, p, t, w) {
        w.faces.push(new THREE.Face3(n, p, t))
    }
    function c(n, p) {
        var t = e.vertices[n].position,
            w = e.vertices[p].position;
        return f((t.x + w.x) / 2, (t.y + w.y) / 2, (t.z + w.z) / 2)
    }
    var e = this,
        d = new THREE.Geometry,
        g;
    this.subdivisions = a || 0;
    THREE.Geometry.call(this);
    a = (1 + Math.sqrt(5)) / 2;
    f(-1, a, 0);
    f(1, a, 0);
    f(-1, - a, 0);
    f(1, - a, 0);
    f(0, - 1, a);
    f(0, 1, a);
    f(0, - 1, - a);
    f(0,
    1, - a);
    f(a, 0, - 1);
    f(a, 0, 1);
    f(-a, 0, - 1);
    f(-a, 0, 1);
    b(0, 11, 5, d);
    b(0, 5, 1, d);
    b(0, 1, 7, d);
    b(0, 7, 10, d);
    b(0, 10, 11, d);
    b(1, 5, 9, d);
    b(5, 11, 4, d);
    b(11, 10, 2, d);
    b(10, 7, 6, d);
    b(7, 1, 8, d);
    b(3, 9, 4, d);
    b(3, 4, 2, d);
    b(3, 2, 6, d);
    b(3, 6, 8, d);
    b(3, 8, 9, d);
    b(4, 9, 5, d);
    b(2, 4, 11, d);
    b(6, 2, 10, d);
    b(8, 6, 7, d);
    b(9, 8, 1, d);
    for (a = 0; a < this.subdivisions; a++) {
        g = new THREE.Geometry;
        for (var h in d.faces) {
            var m = c(d.faces[h].a, d.faces[h].b),
                k = c(d.faces[h].b, d.faces[h].c),
                j = c(d.faces[h].c, d.faces[h].a);
            b(d.faces[h].a, m, j, g);
            b(d.faces[h].b, k, m, g);
            b(d.faces[h].c,
            j, k, g);
            b(m, k, j, g)
        }
        d.faces = g.faces
    }
    e.faces = d.faces;
    delete d;
    delete g;
    this.computeCentroids();
    this.computeFaceNormals();
    this.computeVertexNormals()
};
Icosahedron.prototype = new THREE.Geometry;
Icosahedron.prototype.constructor = Icosahedron;

function Lathe(a, f, b) {
    THREE.Geometry.call(this);
    this.steps = f || 12;
    this.angle = b || 2 * Math.PI;
    f = this.angle / this.steps;
    for (var c = [], e = [], d = [], g = [], h = 0; h < a.length; h++) {
        this.vertices.push(new THREE.Vertex(a[h]));
        c[h] = a[h].clone();
        e[h] = this.vertices.length - 1
    }
    for (var m = (new THREE.Matrix4).setRotationZ(f), k = 0; k <= this.angle + 0.0010; k += f) {
        for (h = 0; h < c.length; h++) if (k < this.angle) {
            c[h] = m.multiplyVector3(c[h].clone());
            this.vertices.push(new THREE.Vertex(c[h]));
            d[h] = this.vertices.length - 1
        } else d = g;
        k == 0 && (g = e);
        for (h = 0; h < e.length - 1; h++) {
            this.faces.push(new THREE.Face4(d[h], d[h + 1], e[h + 1], e[h]));
            this.faceVertexUvs[0].push([new THREE.UV(k / b, h / a.length), new THREE.UV(k / b, (h + 1) / a.length), new THREE.UV((k - f) / b, (h + 1) / a.length), new THREE.UV((k - f) / b, h / a.length)])
        }
        e = d;
        d = []
    }
    this.computeCentroids();
    this.computeFaceNormals();
    this.computeVertexNormals()
}
Lathe.prototype = new THREE.Geometry;
Lathe.prototype.constructor = Lathe;
var Plane = function (a, f, b, c) {
    THREE.Geometry.call(this);
    var e, d = a / 2,
        g = f / 2;
    b = b || 1;
    c = c || 1;
    var h = b + 1,
        m = c + 1;
    a /= b;
    var k = f / c;
    for (e = 0; e < m; e++) for (f = 0; f < h; f++) this.vertices.push(new THREE.Vertex(new THREE.Vector3(f * a - d, - (e * k - g), 0)));
    for (e = 0; e < c; e++) for (f = 0; f < b; f++) {
        this.faces.push(new THREE.Face4(f + h * e, f + h * (e + 1), f + 1 + h * (e + 1), f + 1 + h * e));
        this.faceVertexUvs[0].push([new THREE.UV(f / b, e / c), new THREE.UV(f / b, (e + 1) / c), new THREE.UV((f + 1) / b, (e + 1) / c), new THREE.UV((f + 1) / b, e / c)])
    }
    this.computeCentroids();
    this.computeFaceNormals()
};
Plane.prototype = new THREE.Geometry;
Plane.prototype.constructor = Plane;
var Sphere = function (a, f, b) {
    THREE.Geometry.call(this);
    var c, e = Math.PI,
        d = Math.max(3, f || 8),
        g = Math.max(2, b || 6);
    f = [];
    for (b = 0; b < g + 1; b++) {
        c = b / g;
        var h = a * Math.cos(c * e),
            m = a * Math.sin(c * e),
            k = [],
            j = 0;
        for (c = 0; c < d; c++) {
            var n = 2 * c / d,
                p = m * Math.sin(n * e);
            n = m * Math.cos(n * e);
            (b == 0 || b == g) && c > 0 || (j = this.vertices.push(new THREE.Vertex(new THREE.Vector3(n, h, p))) - 1);
            k.push(j)
        }
        f.push(k)
    }
    var t, w, x;
    e = f.length;
    for (b = 0; b < e; b++) {
        d = f[b].length;
        if (b > 0) for (c = 0; c < d; c++) {
            k = c == d - 1;
            g = f[b][k ? 0 : c + 1];
            h = f[b][k ? d - 1 : c];
            m = f[b - 1][k ? d - 1 : c];
            k = f[b - 1][k ? 0 : c + 1];
            p = b / (e - 1);
            t = (b - 1) / (e - 1);
            w = (c + 1) / d;
            n = c / d;
            j = new THREE.UV(1 - w, p);
            p = new THREE.UV(1 - n, p);
            n = new THREE.UV(1 - n, t);
            var u = new THREE.UV(1 - w, t);
            if (b < f.length - 1) {
                t = this.vertices[g].position.clone();
                w = this.vertices[h].position.clone();
                x = this.vertices[m].position.clone();
                t.normalize();
                w.normalize();
                x.normalize();
                this.faces.push(new THREE.Face3(g, h, m, [new THREE.Vector3(t.x, t.y, t.z), new THREE.Vector3(w.x, w.y, w.z), new THREE.Vector3(x.x, x.y, x.z)]));
                this.faceVertexUvs[0].push([j, p, n])
            }
            if (b > 1) {
                t = this.vertices[g].position.clone();
                w = this.vertices[m].position.clone();
                x = this.vertices[k].position.clone();
                t.normalize();
                w.normalize();
                x.normalize();
                this.faces.push(new THREE.Face3(g, m, k, [new THREE.Vector3(t.x, t.y, t.z), new THREE.Vector3(w.x, w.y, w.z), new THREE.Vector3(x.x, x.y, x.z)]));
                this.faceVertexUvs[0].push([j, n, u])
            }
        }
    }
    this.computeCentroids();
    this.computeFaceNormals();
    this.computeVertexNormals();
    this.boundingSphere = {
        radius: a
    }
};
Sphere.prototype = new THREE.Geometry;
Sphere.prototype.constructor = Sphere;
var Torus = function (a, f, b, c) {
    this.radius = a || 100;
    this.tube = f || 40;
    this.segmentsR = b || 8;
    this.segmentsT = c || 6;
    a = [];
    THREE.Geometry.call(this);
    for (f = 0; f <= this.segmentsR; ++f) for (b = 0; b <= this.segmentsT; ++b) {
        c = b / this.segmentsT * 2 * Math.PI;
        var e = f / this.segmentsR * 2 * Math.PI;
        this.vertices.push(new THREE.Vertex(new THREE.Vector3((this.radius + this.tube * Math.cos(e)) * Math.cos(c), (this.radius + this.tube * Math.cos(e)) * Math.sin(c), this.tube * Math.sin(e))));
        a.push([b / this.segmentsT, 1 - f / this.segmentsR])
    }
    for (f = 1; f <= this.segmentsR; ++f) for (b = 1; b <= this.segmentsT; ++b) {
        c = (this.segmentsT + 1) * f + b;
        e = (this.segmentsT + 1) * f + b - 1;
        var d = (this.segmentsT + 1) * (f - 1) + b - 1,
            g = (this.segmentsT + 1) * (f - 1) + b;
        this.faces.push(new THREE.Face4(c, e, d, g));
        this.faceVertexUvs[0].push([new THREE.UV(a[c][0], a[c][1]), new THREE.UV(a[e][0], a[e][1]), new THREE.UV(a[d][0], a[d][1]), new THREE.UV(a[g][0], a[g][1])])
    }
    delete a;
    this.computeCentroids();
    this.computeFaceNormals();
    this.computeVertexNormals()
};
Torus.prototype = new THREE.Geometry;
Torus.prototype.constructor = Torus;
var TorusKnot = function (a, f, b, c, e, d, g) {
    function h(n, p, t, w, x, u) {
        p = t / w * n;
        t = Math.cos(p);
        return new THREE.Vector3(x * (2 + t) * 0.5 * Math.cos(n), x * (2 + t) * Math.sin(n) * 0.5, u * x * Math.sin(p) * 0.5)
    }
    THREE.Geometry.call(this);
    this.radius = a || 200;
    this.tube = f || 40;
    this.segmentsR = b || 64;
    this.segmentsT = c || 8;
    this.p = e || 2;
    this.q = d || 3;
    this.heightScale = g || 1;
    this.grid = Array(this.segmentsR);
    b = new THREE.Vector3;
    c = new THREE.Vector3;
    d = new THREE.Vector3;
    for (a = 0; a < this.segmentsR; ++a) {
        this.grid[a] = Array(this.segmentsT);
        for (f = 0; f < this.segmentsT; ++f) {
            var m = a / this.segmentsR * 2 * this.p * Math.PI;
            g = f / this.segmentsT * 2 * Math.PI;
            e = h(m, g, this.q, this.p, this.radius, this.heightScale);
            m = h(m + 0.01, g, this.q, this.p, this.radius, this.heightScale);
            b.x = m.x - e.x;
            b.y = m.y - e.y;
            b.z = m.z - e.z;
            c.x = m.x + e.x;
            c.y = m.y + e.y;
            c.z = m.z + e.z;
            d.cross(b, c);
            c.cross(d, b);
            d.normalize();
            c.normalize();
            m = this.tube * Math.cos(g);
            g = this.tube * Math.sin(g);
            e.x += m * c.x + g * d.x;
            e.y += m * c.y + g * d.y;
            e.z += m * c.z + g * d.z;
            this.grid[a][f] = this.vertices.push(new THREE.Vertex(new THREE.Vector3(e.x, e.y, e.z))) - 1
        }
    }
    for (a = 0; a < this.segmentsR; ++a) for (f = 0; f < this.segmentsT; ++f) {
        d = (a + 1) % this.segmentsR;
        g = (f + 1) % this.segmentsT;
        e = this.grid[a][f];
        b = this.grid[d][f];
        c = this.grid[a][g];
        d = this.grid[d][g];
        g = new THREE.UV(a / this.segmentsR, f / this.segmentsT);
        m = new THREE.UV((a + 1) / this.segmentsR, f / this.segmentsT);
        var k = new THREE.UV(a / this.segmentsR, (f + 1) / this.segmentsT),
            j = new THREE.UV((a + 1) / this.segmentsR, (f + 1) / this.segmentsT);
        this.faces.push(new THREE.Face3(e, b, c));
        this.faceVertexUvs[0].push([g, m, k]);
        this.faces.push(new THREE.Face3(d, c, b));
        this.faceVertexUvs[0].push([j,
        k, m])
    }
    this.computeCentroids();
    this.computeFaceNormals();
    this.computeVertexNormals()
};
TorusKnot.prototype = new THREE.Geometry;
TorusKnot.prototype.constructor = TorusKnot;
THREE.Loader = function (a) {
    this.statusDomElement = (this.showStatus = a) ? THREE.Loader.prototype.addStatusElement() : null;
    this.onLoadStart = function () {};
    this.onLoadProgress = function () {};
    this.onLoadComplete = function () {}
};
THREE.Loader.prototype = {
    addStatusElement: function () {
        var a = document.createElement("div");
        a.style.position = "absolute";
        a.style.right = "0px";
        a.style.top = "0px";
        a.style.fontSize = "0.8em";
        a.style.textAlign = "left";
        a.style.background = "rgba(0,0,0,0.25)";
        a.style.color = "#fff";
        a.style.width = "120px";
        a.style.padding = "0.5em 0.5em 0.5em 0.5em";
        a.style.zIndex = 1E3;
        a.innerHTML = "Loading ...";
        return a
    },
    updateProgress: function (a) {
        var f = "Loaded ";
        f += a.total ? (100 * a.loaded / a.total).toFixed(0) + "%" : (a.loaded / 1E3).toFixed(2) + " KB";
        this.statusDomElement.innerHTML = f
    },
    extractUrlbase: function (a) {
        a = a.split("/");
        a.pop();
        return a.join("/")
    },
    init_materials: function (a, f, b) {
        a.materials = [];
        for (var c = 0; c < f.length; ++c) a.materials[c] = [THREE.Loader.prototype.createMaterial(f[c], b)]
    },
    createMaterial: function (a, f) {
        function b(h) {
            h = Math.log(h) / Math.LN2;
            return Math.floor(h) == h
        }
        function c(h, m) {
            var k = new Image;
            k.onload = function () {
                if (!b(this.width) || !b(this.height)) {
                    var j = Math.pow(2, Math.round(Math.log(this.width) / Math.LN2)),
                        n = Math.pow(2, Math.round(Math.log(this.height) / Math.LN2));
                    h.image.width = j;
                    h.image.height = n;
                    h.image.getContext("2d").drawImage(this, 0, 0, j, n)
                } else h.image = this;
                h.needsUpdate = !0
            };
            k.src = m
        }
        var e, d, g;
        e = "MeshLambertMaterial";
        d = {
            color: 15658734,
            opacity: 1,
            map: null,
            lightMap: null,
            vertexColors: a.vertexColors ? THREE.VertexColors : !1,
            wireframe: a.wireframe
        };
        if (a.shading) if (a.shading == "Phong") e = "MeshPhongMaterial";
        else a.shading == "Basic" && (e = "MeshBasicMaterial");
        if (a.blending) if (a.blending == "Additive") d.blending = THREE.AdditiveBlending;
        else if (a.blending == "Subtractive") d.blending = THREE.SubtractiveBlending;
        else if (a.blending == "Multiply") d.blending = THREE.MultiplyBlending;
        if (a.transparent !== undefined) d.transparent = a.transparent;
        if (a.depthTest !== undefined) d.depthTest = a.depthTest;
        if (a.mapDiffuse && f) {
            g = document.createElement("canvas");
            d.map = new THREE.Texture(g);
            d.map.sourceFile = a.mapDiffuse;
            c(d.map, f + "/" + a.mapDiffuse)
        } else if (a.colorDiffuse) {
            g = (a.colorDiffuse[0] * 255 << 16) + (a.colorDiffuse[1] * 255 << 8) + a.colorDiffuse[2] * 255;
            d.color = g;
            d.opacity = a.transparency
        } else if (a.DbgColor) d.color = a.DbgColor;
        if (a.mapLightmap && f) {
            g = document.createElement("canvas");
            d.lightMap = new THREE.Texture(g);
            d.lightMap.sourceFile = a.mapLightmap;
            c(d.lightMap, f + "/" + a.mapLightmap)
        }
        return new THREE[e](d)
    }
};
THREE.JSONLoader = function (a) {
    THREE.Loader.call(this, a)
};
THREE.JSONLoader.prototype = new THREE.Loader;
THREE.JSONLoader.prototype.constructor = THREE.JSONLoader;
THREE.JSONLoader.prototype.supr = THREE.Loader.prototype;
THREE.JSONLoader.prototype.load = function (a) {
    var f = this,
        b = a.model,
        c = a.callback,
        e = a.texture_path ? a.texture_path : this.extractUrlbase(b);
    a = new Worker(b);
    a.onmessage = function (d) {
        f.createModel(d.data, c, e);
        f.onLoadComplete()
    };
    this.onLoadStart();
    a.postMessage((new Date).getTime())
};
THREE.JSONLoader.prototype.createModel = function (a, f, b) {
    var c = new THREE.Geometry;
    this.init_materials(c, a.materials, b);
    (function () {
        if (a.version === undefined || a.version != 2) console.error("Deprecated file format.");
        else {
            var e, d, g, h, m, k, j, n, p, t, w, x, u, B, y, l = a.faces;
            k = a.vertices;
            var z = a.normals,
                C = a.colors;
            j = a.scale !== undefined ? a.scale : 1;
            var G = 0;
            for (e = 0; e < a.uvs.length; e++) a.uvs[e].length && G++;
            for (e = 0; e < G; e++) {
                c.faceUvs[e] = [];
                c.faceVertexUvs[e] = []
            }
            h = 0;
            for (m = k.length; h < m;) {
                w = new THREE.Vertex;
                w.position.x = k[h++] / j;
                w.position.y = k[h++] / j;
                w.position.z = k[h++] / j;
                c.vertices.push(w)
            }
            h = 0;
            for (m = l.length; h < m;) {
                t = l[h++];
                k = t & 1;
                g = t & 2;
                e = t & 4;
                d = t & 8;
                n = t & 16;
                j = t & 32;
                w = t & 64;
                t &= 128;
                if (k) {
                    x = new THREE.Face4;
                    x.a = l[h++];
                    x.b = l[h++];
                    x.c = l[h++];
                    x.d = l[h++];
                    k = 4
                } else {
                    x = new THREE.Face3;
                    x.a = l[h++];
                    x.b = l[h++];
                    x.c = l[h++];
                    k = 3
                }
                if (g) {
                    g = l[h++];
                    x.materials = c.materials[g]
                }
                g = c.faces.length;
                if (e) for (e = 0; e < G; e++) {
                    u = a.uvs[e];
                    p = l[h++];
                    y = u[p * 2];
                    p = u[p * 2 + 1];
                    c.faceUvs[e][g] = new THREE.UV(y, p)
                }
                if (d) for (e = 0; e < G; e++) {
                    u = a.uvs[e];
                    B = [];
                    for (d = 0; d < k; d++) {
                        p = l[h++];
                        y = u[p * 2];
                        p = u[p * 2 + 1];
                        B[d] = new THREE.UV(y, p)
                    }
                    c.faceVertexUvs[e][g] = B
                }
                if (n) {
                    n = l[h++] * 3;
                    d = new THREE.Vector3;
                    d.x = z[n++];
                    d.y = z[n++];
                    d.z = z[n];
                    x.normal = d
                }
                if (j) for (e = 0; e < k; e++) {
                    n = l[h++] * 3;
                    d = new THREE.Vector3;
                    d.x = z[n++];
                    d.y = z[n++];
                    d.z = z[n];
                    x.vertexNormals.push(d)
                }
                if (w) {
                    j = new THREE.Color(l[h++]);
                    x.color = j
                }
                if (t) for (e = 0; e < k; e++) {
                    j = l[h++];
                    j = new THREE.Color(C[j]);
                    x.vertexColors.push(j)
                }
                c.faces.push(x)
            }
        }
    })();
    (function () {
        var e, d, g, h;
        if (a.skinWeights) {
            e = 0;
            for (d = a.skinWeights.length; e < d; e += 2) {
                g = a.skinWeights[e];
                h = a.skinWeights[e + 1];
                c.skinWeights.push(new THREE.Vector4(g, h, 0, 0))
            }
        }
        if (a.skinIndices) {
            e = 0;
            for (d = a.skinIndices.length; e < d; e += 2) {
                g = a.skinIndices[e];
                h = a.skinIndices[e + 1];
                c.skinIndices.push(new THREE.Vector4(g, h, 0, 0))
            }
        }
        c.bones = a.bones;
        c.animation = a.animation
    })();
    (function () {
        if (a.morphTargets !== undefined) {
            var e, d, g, h;
            e = 0;
            for (d = a.morphTargets.length; e < d; e++) {
                c.morphTargets[e] = {};
                c.morphTargets[e].name = a.morphTargets[e].name;
                c.morphTargets[e].vertices = [];
                dstVertices = c.morphTargets[e].vertices;
                srcVertices = a.morphTargets[e].vertices;
                g = 0;
                for (h = srcVertices.length; g < h; g += 3) dstVertices.push(new THREE.Vertex(new THREE.Vector3(srcVertices[g], srcVertices[g + 1], srcVertices[g + 2])))
            }
        }
    })();
    c.computeCentroids();
    c.computeFaceNormals();
    f(c)
};
THREE.BinaryLoader = function (a) {
    THREE.Loader.call(this, a)
};
THREE.BinaryLoader.prototype = new THREE.Loader;
THREE.BinaryLoader.prototype.constructor = THREE.BinaryLoader;
THREE.BinaryLoader.prototype.supr = THREE.Loader.prototype;
THREE.BinaryLoader.prototype = {
    load: function (a) {
        var f = a.model,
            b = a.callback,
            c = a.texture_path ? a.texture_path : THREE.Loader.prototype.extractUrlbase(f),
            e = a.bin_path ? a.bin_path : THREE.Loader.prototype.extractUrlbase(f);
        a = (new Date).getTime();
        f = new Worker(f);
        var d = this.showProgress ? THREE.Loader.prototype.updateProgress : null;
        f.onmessage = function (g) {
            THREE.BinaryLoader.prototype.loadAjaxBuffers(g.data.buffers, g.data.materials, b, e, c, d)
        };
        f.onerror = function (g) {
            alert("worker.onerror: " + g.message + "\n" + g.data);
            g.preventDefault()
        };
        f.postMessage(a)
    },
    loadAjaxBuffers: function (a, f, b, c, e, d) {
        var g = new XMLHttpRequest,
            h = c + "/" + a,
            m = 0;
        g.onreadystatechange = function () {
            if (g.readyState == 4) g.status == 200 || g.status == 0 ? THREE.BinaryLoader.prototype.createBinModel(g.responseText, b, e, f) : alert("Couldn't load [" + h + "] [" + g.status + "]");
            else if (g.readyState == 3) {
                if (d) {
                    m == 0 && (m = g.getResponseHeader("Content-Length"));
                    d({
                        total: m,
                        loaded: g.responseText.length
                    })
                }
            } else g.readyState == 2 && (m = g.getResponseHeader("Content-Length"))
        };
        g.open("GET", h, !0);
        g.overrideMimeType("text/plain; charset=x-user-defined");
        g.setRequestHeader("Content-Type", "text/plain");
        g.send(null)
    },
    createBinModel: function (a, f, b, c) {
        var e = function (d) {
            function g(o, v) {
                var A = j(o, v),
                    D = j(o, v + 1),
                    H = j(o, v + 2),
                    Q = j(o, v + 3),
                    T = (Q << 1 & 255 | H >> 7) - 127;
                A |= (H & 127) << 16 | D << 8;
                if (A == 0 && T == -127) return 0;
                return (1 - 2 * (Q >> 7)) * (1 + A * Math.pow(2, - 23)) * Math.pow(2, T)
            }
            function h(o, v) {
                var A = j(o, v),
                    D = j(o, v + 1),
                    H = j(o, v + 2);
                return (j(o, v + 3) << 24) + (H << 16) + (D << 8) + A
            }
            function m(o, v) {
                var A = j(o, v);
                return (j(o, v + 1) << 8) + A
            }
            function k(o, v) {
                var A = j(o, v);
                return A > 127 ? A - 256 : A
            }
            function j(o,
            v) {
                return o.charCodeAt(v) & 255
            }
            function n(o) {
                var v, A, D;
                v = h(a, o);
                A = h(a, o + G);
                D = h(a, o + K);
                o = m(a, o + J);
                THREE.BinaryLoader.prototype.f3(B, v, A, D, o)
            }
            function p(o) {
                var v, A, D, H, Q, T;
                v = h(a, o);
                A = h(a, o + G);
                D = h(a, o + K);
                H = m(a, o + J);
                Q = h(a, o + I);
                T = h(a, o + E);
                o = h(a, o + L);
                THREE.BinaryLoader.prototype.f3n(B, z, v, A, D, H, Q, T, o)
            }
            function t(o) {
                var v, A, D, H;
                v = h(a, o);
                A = h(a, o + S);
                D = h(a, o + P);
                H = h(a, o + N);
                o = m(a, o + O);
                THREE.BinaryLoader.prototype.f4(B, v, A, D, H, o)
            }
            function w(o) {
                var v, A, D, H, Q, T, ba, ca;
                v = h(a, o);
                A = h(a, o + S);
                D = h(a, o + P);
                H = h(a, o + N);
                Q = m(a,
                o + O);
                T = h(a, o + R);
                ba = h(a, o + F);
                ca = h(a, o + M);
                o = h(a, o + V);
                THREE.BinaryLoader.prototype.f4n(B, z, v, A, D, H, Q, T, ba, ca, o)
            }
            function x(o) {
                var v, A;
                v = h(a, o);
                A = h(a, o + W);
                o = h(a, o + da);
                THREE.BinaryLoader.prototype.uv3(B.faceVertexUvs[0], C[v * 2], C[v * 2 + 1], C[A * 2], C[A * 2 + 1], C[o * 2], C[o * 2 + 1])
            }
            function u(o) {
                var v, A, D;
                v = h(a, o);
                A = h(a, o + ea);
                D = h(a, o + fa);
                o = h(a, o + ga);
                THREE.BinaryLoader.prototype.uv4(B.faceVertexUvs[0], C[v * 2], C[v * 2 + 1], C[A * 2], C[A * 2 + 1], C[D * 2], C[D * 2 + 1], C[o * 2], C[o * 2 + 1])
            }
            var B = this,
                y = 0,
                l, z = [],
                C = [],
                G, K, J, I, E, L, S, P, N, O, R, F,
                M, V, W, da, ea, fa, ga, X, Y, Z, $, aa, U;
            THREE.Geometry.call(this);
            THREE.Loader.prototype.init_materials(B, c, d);
            l = {
                signature: a.substr(y, 8),
                header_bytes: j(a, y + 8),
                vertex_coordinate_bytes: j(a, y + 9),
                normal_coordinate_bytes: j(a, y + 10),
                uv_coordinate_bytes: j(a, y + 11),
                vertex_index_bytes: j(a, y + 12),
                normal_index_bytes: j(a, y + 13),
                uv_index_bytes: j(a, y + 14),
                material_index_bytes: j(a, y + 15),
                nvertices: h(a, y + 16),
                nnormals: h(a, y + 16 + 4),
                nuvs: h(a, y + 16 + 8),
                ntri_flat: h(a, y + 16 + 12),
                ntri_smooth: h(a, y + 16 + 16),
                ntri_flat_uv: h(a, y + 16 + 20),
                ntri_smooth_uv: h(a,
                y + 16 + 24),
                nquad_flat: h(a, y + 16 + 28),
                nquad_smooth: h(a, y + 16 + 32),
                nquad_flat_uv: h(a, y + 16 + 36),
                nquad_smooth_uv: h(a, y + 16 + 40)
            };
            y += l.header_bytes;
            G = l.vertex_index_bytes;
            K = l.vertex_index_bytes * 2;
            J = l.vertex_index_bytes * 3;
            I = l.vertex_index_bytes * 3 + l.material_index_bytes;
            E = l.vertex_index_bytes * 3 + l.material_index_bytes + l.normal_index_bytes;
            L = l.vertex_index_bytes * 3 + l.material_index_bytes + l.normal_index_bytes * 2;
            S = l.vertex_index_bytes;
            P = l.vertex_index_bytes * 2;
            N = l.vertex_index_bytes * 3;
            O = l.vertex_index_bytes * 4;
            R = l.vertex_index_bytes * 4 + l.material_index_bytes;
            F = l.vertex_index_bytes * 4 + l.material_index_bytes + l.normal_index_bytes;
            M = l.vertex_index_bytes * 4 + l.material_index_bytes + l.normal_index_bytes * 2;
            V = l.vertex_index_bytes * 4 + l.material_index_bytes + l.normal_index_bytes * 3;
            W = l.uv_index_bytes;
            da = l.uv_index_bytes * 2;
            ea = l.uv_index_bytes;
            fa = l.uv_index_bytes * 2;
            ga = l.uv_index_bytes * 3;
            d = l.vertex_index_bytes * 3 + l.material_index_bytes;
            U = l.vertex_index_bytes * 4 + l.material_index_bytes;
            X = l.ntri_flat * d;
            Y = l.ntri_smooth * (d + l.normal_index_bytes * 3);
            Z = l.ntri_flat_uv * (d + l.uv_index_bytes * 3);
            $ = l.ntri_smooth_uv * (d + l.normal_index_bytes * 3 + l.uv_index_bytes * 3);
            aa = l.nquad_flat * U;
            d = l.nquad_smooth * (U + l.normal_index_bytes * 4);
            U = l.nquad_flat_uv * (U + l.uv_index_bytes * 4);
            y += function (o) {
                for (var v, A, D, H = l.vertex_coordinate_bytes * 3, Q = o + l.nvertices * H; o < Q; o += H) {
                    v = g(a, o);
                    A = g(a, o + l.vertex_coordinate_bytes);
                    D = g(a, o + l.vertex_coordinate_bytes * 2);
                    THREE.BinaryLoader.prototype.v(B, v, A, D)
                }
                return l.nvertices * H
            }(y);
            y += function (o) {
                for (var v, A, D, H = l.normal_coordinate_bytes * 3, Q = o + l.nnormals * H; o < Q; o += H) {
                    v = k(a, o);
                    A = k(a, o + l.normal_coordinate_bytes);
                    D = k(a, o + l.normal_coordinate_bytes * 2);
                    z.push(v / 127, A / 127, D / 127)
                }
                return l.nnormals * H
            }(y);
            y += function (o) {
                for (var v, A, D = l.uv_coordinate_bytes * 2, H = o + l.nuvs * D; o < H; o += D) {
                    v = g(a, o);
                    A = g(a, o + l.uv_coordinate_bytes);
                    C.push(v, A)
                }
                return l.nuvs * D
            }(y);
            X = y + X;
            Y = X + Y;
            Z = Y + Z;
            $ = Z + $;
            aa = $ + aa;
            d = aa + d;
            U = d + U;
            (function (o) {
                var v, A = l.vertex_index_bytes * 3 + l.material_index_bytes,
                    D = A + l.uv_index_bytes * 3,
                    H = o + l.ntri_flat_uv * D;
                for (v = o; v < H; v += D) {
                    n(v);
                    x(v + A)
                }
                return H - o
            })(Y);
            (function (o) {
                var v,
                A = l.vertex_index_bytes * 3 + l.material_index_bytes + l.normal_index_bytes * 3,
                    D = A + l.uv_index_bytes * 3,
                    H = o + l.ntri_smooth_uv * D;
                for (v = o; v < H; v += D) {
                    p(v);
                    x(v + A)
                }
                return H - o
            })(Z);
            (function (o) {
                var v, A = l.vertex_index_bytes * 4 + l.material_index_bytes,
                    D = A + l.uv_index_bytes * 4,
                    H = o + l.nquad_flat_uv * D;
                for (v = o; v < H; v += D) {
                    t(v);
                    u(v + A)
                }
                return H - o
            })(d);
            (function (o) {
                var v, A = l.vertex_index_bytes * 4 + l.material_index_bytes + l.normal_index_bytes * 4,
                    D = A + l.uv_index_bytes * 4,
                    H = o + l.nquad_smooth_uv * D;
                for (v = o; v < H; v += D) {
                    w(v);
                    u(v + A)
                }
                return H - o
            })(U);
            (function (o) {
                var v, A = l.vertex_index_bytes * 3 + l.material_index_bytes,
                    D = o + l.ntri_flat * A;
                for (v = o; v < D; v += A) n(v);
                return D - o
            })(y);
            (function (o) {
                var v, A = l.vertex_index_bytes * 3 + l.material_index_bytes + l.normal_index_bytes * 3,
                    D = o + l.ntri_smooth * A;
                for (v = o; v < D; v += A) p(v);
                return D - o
            })(X);
            (function (o) {
                var v, A = l.vertex_index_bytes * 4 + l.material_index_bytes,
                    D = o + l.nquad_flat * A;
                for (v = o; v < D; v += A) t(v);
                return D - o
            })($);
            (function (o) {
                var v, A = l.vertex_index_bytes * 4 + l.material_index_bytes + l.normal_index_bytes * 4,
                    D = o + l.nquad_smooth * A;
                for (v = o; v < D; v += A) w(v);
                return D - o
            })(aa);
            this.computeCentroids();
            this.computeFaceNormals()
        };
        e.prototype = new THREE.Geometry;
        e.prototype.constructor = e;
        f(new e(b))
    },
    v: function (a, f, b, c) {
        a.vertices.push(new THREE.Vertex(new THREE.Vector3(f, b, c)))
    },
    f3: function (a, f, b, c, e) {
        a.faces.push(new THREE.Face3(f, b, c, null, null, a.materials[e]))
    },
    f4: function (a, f, b, c, e, d) {
        a.faces.push(new THREE.Face4(f, b, c, e, null, null, a.materials[d]))
    },
    f3n: function (a, f, b, c, e, d, g, h, m) {
        d = a.materials[d];
        var k = f[h * 3],
            j = f[h * 3 + 1];
        h = f[h * 3 + 2];
        var n = f[m * 3],
            p = f[m * 3 + 1];
        m = f[m * 3 + 2];
        a.faces.push(new THREE.Face3(b, c, e, [new THREE.Vector3(f[g * 3], f[g * 3 + 1], f[g * 3 + 2]), new THREE.Vector3(k, j, h), new THREE.Vector3(n, p, m)], null, d))
    },
    f4n: function (a, f, b, c, e, d, g, h, m, k, j) {
        g = a.materials[g];
        var n = f[m * 3],
            p = f[m * 3 + 1];
        m = f[m * 3 + 2];
        var t = f[k * 3],
            w = f[k * 3 + 1];
        k = f[k * 3 + 2];
        var x = f[j * 3],
            u = f[j * 3 + 1];
        j = f[j * 3 + 2];
        a.faces.push(new THREE.Face4(b, c, e, d, [new THREE.Vector3(f[h * 3], f[h * 3 + 1], f[h * 3 + 2]), new THREE.Vector3(n, p, m), new THREE.Vector3(t, w, k), new THREE.Vector3(x, u, j)], null, g))
    },
    uv3: function (a, f, b, c, e, d, g) {
        var h = [];
        h.push(new THREE.UV(f, b));
        h.push(new THREE.UV(c, e));
        h.push(new THREE.UV(d, g));
        a.push(h)
    },
    uv4: function (a, f, b, c, e, d, g, h, m) {
        var k = [];
        k.push(new THREE.UV(f, b));
        k.push(new THREE.UV(c, e));
        k.push(new THREE.UV(d, g));
        k.push(new THREE.UV(h, m));
        a.push(k)
    }
};
if (!window.Int32Array) {
    window.Int32Array = Array;
    window.Float32Array = Array
}
THREE.MarchingCubes = function (a, f) {
    THREE.Object3D.call(this);
    this.materials = f instanceof Array ? f : [f];
    this.init = function (b) {
        this.isolation = 80;
        this.size = b;
        this.size2 = this.size * this.size;
        this.size3 = this.size2 * this.size;
        this.halfsize = this.size / 2;
        this.delta = 2 / this.size;
        this.yd = this.size;
        this.zd = this.size2;
        this.field = new Float32Array(this.size3);
        this.normal_cache = new Float32Array(this.size3 * 3);
        this.vlist = new Float32Array(36);
        this.nlist = new Float32Array(36);
        this.firstDraw = !0;
        this.maxCount = 4096;
        this.count = 0;
        this.hasPos = !1;
        this.hasNormal = !1;
        this.positionArray = new Float32Array(this.maxCount * 3);
        this.normalArray = new Float32Array(this.maxCount * 3)
    };
    this.lerp = function (b, c, e) {
        return b + (c - b) * e
    };
    this.VIntX = function (b, c, e, d, g, h, m, k, j, n) {
        g = (g - j) / (n - j);
        j = this.normal_cache;
        c[d] = h + g * this.delta;
        c[d + 1] = m;
        c[d + 2] = k;
        e[d] = this.lerp(j[b], j[b + 3], g);
        e[d + 1] = this.lerp(j[b + 1], j[b + 4], g);
        e[d + 2] = this.lerp(j[b + 2], j[b + 5], g)
    };
    this.VIntY = function (b, c, e, d, g, h, m, k, j, n) {
        g = (g - j) / (n - j);
        j = this.normal_cache;
        c[d] = h;
        c[d + 1] = m + g * this.delta;
        c[d + 2] = k;
        c = b + this.yd * 3;
        e[d] = this.lerp(j[b], j[c], g);
        e[d + 1] = this.lerp(j[b + 1], j[c + 1], g);
        e[d + 2] = this.lerp(j[b + 2], j[c + 2], g)
    };
    this.VIntZ = function (b, c, e, d, g, h, m, k, j, n) {
        g = (g - j) / (n - j);
        j = this.normal_cache;
        c[d] = h;
        c[d + 1] = m;
        c[d + 2] = k + g * this.delta;
        c = b + this.zd * 3;
        e[d] = this.lerp(j[b], j[c], g);
        e[d + 1] = this.lerp(j[b + 1], j[c + 1], g);
        e[d + 2] = this.lerp(j[b + 2], j[c + 2], g)
    };
    this.compNorm = function (b) {
        var c = b * 3;
        if (this.normal_cache[c] == 0) {
            this.normal_cache[c] = this.field[b - 1] - this.field[b + 1];
            this.normal_cache[c + 1] = this.field[b - this.yd] - this.field[b + this.yd];
            this.normal_cache[c + 2] = this.field[b - this.zd] - this.field[b + this.zd]
        }
    };
    this.polygonize = function (b, c, e, d, g, h) {
        var m = d + 1,
            k = d + this.yd,
            j = d + this.zd,
            n = m + this.yd,
            p = m + this.zd,
            t = d + this.yd + this.zd,
            w = m + this.yd + this.zd,
            x = 0,
            u = this.field[d],
            B = this.field[m],
            y = this.field[k],
            l = this.field[n],
            z = this.field[j],
            C = this.field[p],
            G = this.field[t],
            K = this.field[w];
        u < g && (x |= 1);
        B < g && (x |= 2);
        y < g && (x |= 8);
        l < g && (x |= 4);
        z < g && (x |= 16);
        C < g && (x |= 32);
        G < g && (x |= 128);
        K < g && (x |= 64);
        var J = THREE.edgeTable[x];
        if (J == 0) return 0;
        var I = this.delta,
            E = b + I,
            L = c + I;
        I = e + I;
        if (J & 1) {
            this.compNorm(d);
            this.compNorm(m);
            this.VIntX(d * 3, this.vlist, this.nlist, 0, g, b, c, e, u, B)
        }
        if (J & 2) {
            this.compNorm(m);
            this.compNorm(n);
            this.VIntY(m * 3, this.vlist, this.nlist, 3, g, E, c, e, B, l)
        }
        if (J & 4) {
            this.compNorm(k);
            this.compNorm(n);
            this.VIntX(k * 3, this.vlist, this.nlist, 6, g, b, L, e, y, l)
        }
        if (J & 8) {
            this.compNorm(d);
            this.compNorm(k);
            this.VIntY(d * 3, this.vlist, this.nlist, 9, g, b, c, e, u, y)
        }
        if (J & 16) {
            this.compNorm(j);
            this.compNorm(p);
            this.VIntX(j * 3, this.vlist, this.nlist, 12, g, b, c, I,
            z, C)
        }
        if (J & 32) {
            this.compNorm(p);
            this.compNorm(w);
            this.VIntY(p * 3, this.vlist, this.nlist, 15, g, E, c, I, C, K)
        }
        if (J & 64) {
            this.compNorm(t);
            this.compNorm(w);
            this.VIntX(t * 3, this.vlist, this.nlist, 18, g, b, L, I, G, K)
        }
        if (J & 128) {
            this.compNorm(j);
            this.compNorm(t);
            this.VIntY(j * 3, this.vlist, this.nlist, 21, g, b, c, I, z, G)
        }
        if (J & 256) {
            this.compNorm(d);
            this.compNorm(j);
            this.VIntZ(d * 3, this.vlist, this.nlist, 24, g, b, c, e, u, z)
        }
        if (J & 512) {
            this.compNorm(m);
            this.compNorm(p);
            this.VIntZ(m * 3, this.vlist, this.nlist, 27, g, E, c, e, B, C)
        }
        if (J & 1024) {
            this.compNorm(n);
            this.compNorm(w);
            this.VIntZ(n * 3, this.vlist, this.nlist, 30, g, E, L, e, l, K)
        }
        if (J & 2048) {
            this.compNorm(k);
            this.compNorm(t);
            this.VIntZ(k * 3, this.vlist, this.nlist, 33, g, b, L, e, y, G)
        }
        x <<= 4;
        for (g = d = 0; THREE.triTable[x + g] != -1;) {
            b = x + g;
            c = b + 1;
            e = b + 2;
            this.posnormtriv(this.vlist, this.nlist, 3 * THREE.triTable[b], 3 * THREE.triTable[c], 3 * THREE.triTable[e], h);
            g += 3;
            d++
        }
        return d
    };
    this.posnormtriv = function (b, c, e, d, g, h) {
        var m = this.count * 3;
        this.positionArray[m] = b[e];
        this.positionArray[m + 1] = b[e + 1];
        this.positionArray[m + 2] = b[e + 2];
        this.positionArray[m + 3] = b[d];
        this.positionArray[m + 4] = b[d + 1];
        this.positionArray[m + 5] = b[d + 2];
        this.positionArray[m + 6] = b[g];
        this.positionArray[m + 7] = b[g + 1];
        this.positionArray[m + 8] = b[g + 2];
        this.normalArray[m] = c[e];
        this.normalArray[m + 1] = c[e + 1];
        this.normalArray[m + 2] = c[e + 2];
        this.normalArray[m + 3] = c[d];
        this.normalArray[m + 4] = c[d + 1];
        this.normalArray[m + 5] = c[d + 2];
        this.normalArray[m + 6] = c[g];
        this.normalArray[m + 7] = c[g + 1];
        this.normalArray[m + 8] = c[g + 2];
        this.hasPos = !0;
        this.hasNormal = !0;
        this.count += 3;
        this.count >= this.maxCount - 3 && h(this)
    };
    this.begin = function () {
        this.count = 0;
        this.hasPos = !1;
        this.hasNormal = !1
    };
    this.end = function (b) {
        if (this.count != 0) {
            for (var c = this.count * 3; c < this.positionArray.length; c++) this.positionArray[c] = 0;
            b(this)
        }
    };
    this.addBall = function (b, c, e, d, g) {
        var h = this.size * Math.sqrt(d / g),
            m = e * this.size,
            k = c * this.size,
            j = b * this.size,
            n = Math.floor(m - h);
        n < 1 && (n = 1);
        m = Math.floor(m + h);
        m > this.size - 1 && (m = this.size - 1);
        var p = Math.floor(k - h);
        p < 1 && (p = 1);
        k = Math.floor(k + h);
        k > this.size - 1 && (k = this.size - 1);
        var t = Math.floor(j - h);
        t < 1 && (t = 1);
        h = Math.floor(j + h);
        h > this.size - 1 && (h = this.size - 1);
        for (var w, x, u, B, y, l; n < m; n++) {
            j = this.size2 * n;
            x = n / this.size - e;
            y = x * x;
            for (x = p; x < k; x++) {
                u = j + this.size * x;
                w = x / this.size - c;
                l = w * w;
                for (w = t; w < h; w++) {
                    B = w / this.size - b;
                    B = d / (1.0E-6 + B * B + l + y) - g;
                    B > 0 && (this.field[u + w] += B)
                }
            }
        }
    };
    this.addPlaneX = function (b, c) {
        var e, d, g, h, m, k = this.size,
            j = this.yd,
            n = this.zd,
            p = this.field,
            t = k * Math.sqrt(b / c);
        t > k && (t = k);
        for (e = 0; e < t; e++) {
            d = e / k;
            d *= d;
            h = b / (1.0E-4 + d) - c;
            if (h > 0) for (d = 0; d < k; d++) {
                m = e + d * j;
                for (g = 0; g < k; g++) p[n * g + m] += h
            }
        }
    };
    this.addPlaneY = function (b, c) {
        var e, d,
        g, h, m, k, j = this.size,
            n = this.yd,
            p = this.zd,
            t = this.field,
            w = j * Math.sqrt(b / c);
        w > j && (w = j);
        for (d = 0; d < w; d++) {
            e = d / j;
            e *= e;
            h = b / (1.0E-4 + e) - c;
            if (h > 0) {
                m = d * n;
                for (e = 0; e < j; e++) {
                    k = m + e;
                    for (g = 0; g < j; g++) t[p * g + k] += h
                }
            }
        }
    };
    this.addPlaneZ = function (b, c) {
        var e, d, g, h, m, k;
        size = this.size;
        yd = this.yd;
        zd = this.zd;
        field = this.field;
        dist = size * Math.sqrt(b / c);
        dist > size && (dist = size);
        for (g = 0; g < dist; g++) {
            e = g / size;
            e *= e;
            h = b / (1.0E-4 + e) - c;
            if (h > 0) {
                m = zd * g;
                for (d = 0; d < size; d++) {
                    k = m + d * yd;
                    for (e = 0; e < size; e++) field[k + e] += h
                }
            }
        }
    };
    this.reset = function () {
        var b;
        for (b = 0; b < this.size3; b++) {
            this.normal_cache[b * 3] = 0;
            this.field[b] = 0
        }
    };
    this.render = function (b) {
        this.begin();
        var c, e, d, g, h, m, k, j, n, p = this.size - 2;
        for (g = 1; g < p; g++) {
            n = this.size2 * g;
            k = (g - this.halfsize) / this.halfsize;
            for (d = 1; d < p; d++) {
                j = n + this.size * d;
                m = (d - this.halfsize) / this.halfsize;
                for (e = 1; e < p; e++) {
                    h = (e - this.halfsize) / this.halfsize;
                    c = j + e;
                    this.polygonize(h, m, k, c, this.isolation, b)
                }
            }
        }
        this.end(b)
    };
    this.generateGeometry = function () {
        var b = 0,
            c = new THREE.Geometry;
        this.render(function (e) {
            var d, g, h, m, k, j, n, p;
            for (d = 0; d < e.count; d++) {
                k = d * 3;
                n = k + 1;
                p = k + 2;
                g = e.positionArray[k];
                h = e.positionArray[n];
                m = e.positionArray[p];
                j = new THREE.Vector3(g, h, m);
                g = e.normalArray[k];
                h = e.normalArray[n];
                m = e.normalArray[p];
                k = new THREE.Vector3(g, h, m);
                k.normalize();
                k = new THREE.Vertex(j, k);
                c.vertices.push(k)
            }
            nfaces = e.count / 3;
            for (d = 0; d < nfaces; d++) {
                k = (b + d) * 3;
                n = k + 1;
                p = k + 2;
                j = c.vertices[k].normal;
                g = c.vertices[n].normal;
                h = c.vertices[p].normal;
                k = new THREE.Face3(k, n, p, [j, g, h]);
                c.faces.push(k)
            }
            b += nfaces;
            e.count = 0
        });
        return c
    };
    this.init(a)
};
THREE.MarchingCubes.prototype = new THREE.Object3D;
THREE.MarchingCubes.prototype.constructor = THREE.MarchingCubes;
THREE.edgeTable = new Int32Array([0, 265, 515, 778, 1030, 1295, 1541, 1804, 2060, 2309, 2575, 2822, 3082, 3331, 3593, 3840, 400, 153, 915, 666, 1430, 1183, 1941, 1692, 2460, 2197, 2975, 2710, 3482, 3219, 3993, 3728, 560, 825, 51, 314, 1590, 1855, 1077, 1340, 2620, 2869, 2111, 2358, 3642, 3891, 3129, 3376, 928, 681, 419, 170, 1958, 1711, 1445, 1196, 2988, 2725, 2479, 2214, 4010, 3747, 3497, 3232, 1120, 1385, 1635, 1898, 102, 367, 613, 876, 3180, 3429, 3695, 3942, 2154, 2403, 2665, 2912, 1520, 1273, 2035, 1786, 502, 255, 1013, 764, 3580, 3317, 4095, 3830, 2554, 2291, 3065, 2800, 1616, 1881, 1107,
1370, 598, 863, 85, 348, 3676, 3925, 3167, 3414, 2650, 2899, 2137, 2384, 1984, 1737, 1475, 1226, 966, 719, 453, 204, 4044, 3781, 3535, 3270, 3018, 2755, 2505, 2240, 2240, 2505, 2755, 3018, 3270, 3535, 3781, 4044, 204, 453, 719, 966, 1226, 1475, 1737, 1984, 2384, 2137, 2899, 2650, 3414, 3167, 3925, 3676, 348, 85, 863, 598, 1370, 1107, 1881, 1616, 2800, 3065, 2291, 2554, 3830, 4095, 3317, 3580, 764, 1013, 255, 502, 1786, 2035, 1273, 1520, 2912, 2665, 2403, 2154, 3942, 3695, 3429, 3180, 876, 613, 367, 102, 1898, 1635, 1385, 1120, 3232, 3497, 3747, 4010, 2214, 2479, 2725, 2988, 1196, 1445, 1711, 1958, 170,
419, 681, 928, 3376, 3129, 3891, 3642, 2358, 2111, 2869, 2620, 1340, 1077, 1855, 1590, 314, 51, 825, 560, 3728, 3993, 3219, 3482, 2710, 2975, 2197, 2460, 1692, 1941, 1183, 1430, 666, 915, 153, 400, 3840, 3593, 3331, 3082, 2822, 2575, 2309, 2060, 1804, 1541, 1295, 1030, 778, 515, 265, 0]);
THREE.triTable = new Int32Array([-1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 1, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 8, 3, 9, 8, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, 1, 2, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 2, 10, 0, 2, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 8, 3, 2, 10, 8, 10, 9, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 11, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 11, 2, 8, 11, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 9, 0, 2, 3, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 11, 2, 1, 9, 11, 9, 8, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 10, 1, 11, 10, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 10, 1, 0, 8, 10, 8, 11, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 9, 0, 3, 11, 9, 11, 10, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 8, 10, 10, 8, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 7, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 3, 0, 7, 3, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 1, 9, 8, 4, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 1, 9, 4, 7, 1, 7, 3, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, 8, 4, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 4, 7, 3, 0, 4, 1, 2, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 2, 10, 9, 0, 2, 8, 4, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, - 1, - 1, - 1, - 1, 8, 4, 7, 3, 11, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 4, 7, 11, 2, 4, 2, 0, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 0, 1, 8, 4, 7, 2, 3, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, - 1, - 1, - 1, - 1, 3, 10, 1, 3, 11, 10, 7, 8, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, - 1, - 1, - 1, - 1, 4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, - 1, - 1, - 1, - 1, 4, 7, 11, 4, 11, 9, 9, 11, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 5, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 5, 4, 0, 8, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 5, 4, 1, 5, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 5, 4, 8, 3, 5, 3, 1, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, 9, 5, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 0, 8, 1, 2, 10, 4, 9, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 2, 10, 5, 4, 2, 4, 0, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, - 1, - 1, - 1, - 1, 9, 5, 4, 2, 3, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 11, 2, 0, 8, 11, 4, 9, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 5, 4, 0, 1, 5, 2, 3, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, - 1, - 1, - 1, - 1, 10, 3, 11, 10, 1, 3, 9, 5, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, - 1, - 1, - 1, - 1, 5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, - 1, - 1, - 1, - 1, 5, 4, 8, 5,
8, 10, 10, 8, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 7, 8, 5, 7, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 3, 0, 9, 5, 3, 5, 7, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 7, 8, 0, 1, 7, 1, 5, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 5, 3, 3, 5, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 7, 8, 9, 5, 7, 10, 1, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, - 1, - 1, - 1, - 1, 8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, - 1, - 1, - 1, - 1, 2, 10, 5, 2, 5, 3, 3, 5, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 9, 5, 7, 8, 9, 3, 11, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, - 1, - 1, - 1, - 1, 2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, - 1, - 1, - 1, - 1, 11, 2, 1, 11, 1, 7, 7, 1, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, - 1, - 1, - 1, - 1, 5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, - 1, 11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, - 1, 11, 10, 5, 7, 11, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 6, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, 5, 10, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 0, 1, 5, 10, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 8, 3, 1, 9, 8, 5, 10, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 6, 5, 2, 6, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 6, 5, 1, 2, 6, 3, 0, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 6, 5, 9, 0, 6, 0, 2, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, - 1, - 1, - 1, - 1, 2, 3, 11, 10, 6,
5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 0, 8, 11, 2, 0, 10, 6, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 1, 9, 2, 3, 11, 5, 10, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, - 1, - 1, - 1, - 1, 6, 3, 11, 6, 5, 3, 5, 1, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, - 1, - 1, - 1, - 1, 3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, - 1, - 1, - 1, - 1, 6, 5, 9, 6, 9, 11, 11, 9, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 10, 6, 4, 7, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 3, 0, 4, 7, 3, 6, 5, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 9, 0, 5, 10, 6, 8, 4, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, - 1, - 1, - 1, - 1, 6, 1, 2, 6, 5, 1, 4, 7, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, - 1, - 1, - 1, - 1, 8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, - 1, - 1, - 1, - 1, 7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, - 1, 3, 11, 2, 7, 8, 4, 10, 6, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, - 1, - 1, - 1, - 1, 0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, - 1, - 1, - 1, - 1, 9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, - 1, 8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, - 1, - 1, - 1, - 1, 5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, - 1, 0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, - 1, 6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, - 1, - 1, - 1, - 1, 10, 4, 9, 6, 4, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 10, 6, 4, 9, 10, 0, 8, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1,
10, 0, 1, 10, 6, 0, 6, 4, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, - 1, - 1, - 1, - 1, 1, 4, 9, 1, 2, 4, 2, 6, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, - 1, - 1, - 1, - 1, 0, 2, 4, 4, 2, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 3, 2, 8, 2, 4, 4, 2, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 4, 9, 10, 6, 4, 11, 2, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, - 1, - 1, - 1, - 1, 3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, - 1, - 1, - 1, - 1, 6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, - 1, 9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, - 1, - 1, - 1, - 1, 8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, - 1, 3, 11, 6, 3, 6, 0, 0, 6, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1,
6, 4, 8, 11, 6, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 10, 6, 7, 8, 10, 8, 9, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, - 1, - 1, - 1, - 1, 10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, - 1, - 1, - 1, - 1, 10, 6, 7, 10, 7, 1, 1, 7, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, - 1, - 1, - 1, - 1, 2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, - 1, 7, 8, 0, 7, 0, 6, 6, 0, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 3, 2, 6, 7, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, - 1, - 1, - 1, - 1, 2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, - 1, 1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, - 1, 11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, - 1, - 1, - 1, - 1,
8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, - 1, 0, 9, 1, 11, 6, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, - 1, - 1, - 1, - 1, 7, 11, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 6, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 0, 8, 11, 7, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 1, 9, 11, 7, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 1, 9, 8, 3, 1, 11, 7, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 1, 2, 6, 11, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, 3, 0, 8, 6, 11, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 9, 0, 2, 10, 9, 6, 11, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, - 1, - 1, - 1, - 1, 7,
2, 3, 6, 2, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 7, 0, 8, 7, 6, 0, 6, 2, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 7, 6, 2, 3, 7, 0, 1, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, - 1, - 1, - 1, - 1, 10, 7, 6, 10, 1, 7, 1, 3, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, - 1, - 1, - 1, - 1, 0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, - 1, - 1, - 1, - 1, 7, 6, 10, 7, 10, 8, 8, 10, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 6, 8, 4, 11, 8, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 6, 11, 3, 0, 6, 0, 4, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 6, 11, 8, 4, 6, 9, 0, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, - 1, - 1, - 1, - 1, 6, 8, 4, 6, 11, 8, 2, 10, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, - 1, - 1, - 1, - 1, 4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, - 1, - 1, - 1, - 1, 10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, - 1, 8, 2, 3, 8, 4, 2, 4, 6, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 4, 2, 4, 6, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, - 1, - 1, - 1, - 1, 1, 9, 4, 1, 4, 2, 2, 4, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, - 1, - 1, - 1, - 1, 10, 1, 0, 10, 0, 6, 6, 0, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, - 1, 10, 9, 4, 6, 10, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 9, 5, 7, 6, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, 4, 9, 5, 11, 7, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 0, 1, 5, 4, 0, 7, 6, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, - 1, - 1, - 1, - 1, 9, 5, 4, 10, 1, 2, 7, 6, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, - 1, - 1, - 1, - 1, 7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, - 1, - 1, - 1, - 1, 3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, - 1, 7, 2, 3, 7, 6, 2, 5, 4, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, - 1, - 1, - 1, - 1, 3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, - 1, - 1, - 1, - 1, 6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, - 1, 9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, - 1, - 1, - 1, - 1, 1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, - 1, 4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, - 1, 7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, - 1, - 1, - 1, - 1, 6, 9, 5, 6, 11, 9, 11, 8, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, - 1, - 1, - 1, - 1, 0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, - 1, - 1, - 1, - 1, 6, 11, 3, 6, 3, 5, 5, 3, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, - 1, - 1, - 1, - 1, 0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, - 1, 11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, - 1, 6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, - 1, - 1, - 1, - 1, 5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, - 1, - 1, - 1, - 1, 9, 5, 6, 9, 6, 0, 0, 6, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, - 1, 1, 5, 6, 2, 1, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1,
1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, - 1, 10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, - 1, - 1, - 1, - 1, 0, 3, 8, 5, 6, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 5, 6, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 5, 10, 7, 5, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 5, 10, 11, 7, 5, 8, 3, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 11, 7, 5, 10, 11, 1, 9, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, - 1, - 1, - 1, - 1, 11, 1, 2, 11, 7, 1, 7, 5, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, - 1, - 1, - 1, - 1, 9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, - 1, - 1, - 1, - 1, 7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, - 1, 2, 5, 10, 2, 3, 5, 3, 7, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, - 1, - 1, - 1, - 1, 9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, - 1, - 1, - 1, - 1, 9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, - 1, 1, 3, 5, 3, 7, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 7, 0, 7, 1, 1, 7, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 0, 3, 9, 3, 5, 5, 3, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 8, 7, 5, 9, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 8, 4, 5, 10, 8, 10, 11, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, - 1, - 1, - 1, - 1, 0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, - 1, - 1, - 1, - 1, 10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, - 1, 2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, - 1, - 1, - 1, - 1, 0, 4, 11, 0, 11, 3, 4, 5, 11,
2, 11, 1, 5, 1, 11, - 1, 0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, - 1, 9, 4, 5, 2, 11, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, - 1, - 1, - 1, - 1, 5, 10, 2, 5, 2, 4, 4, 2, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, - 1, 5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, - 1, - 1, - 1, - 1, 8, 4, 5, 8, 5, 3, 3, 5, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 4, 5, 1, 0, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, - 1, - 1, - 1, - 1, 9, 4, 5, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 11, 7, 4, 9, 11, 9, 10, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, - 1, - 1, - 1, - 1, 1, 10, 11, 1, 11,
4, 1, 4, 0, 7, 4, 11, - 1, - 1, - 1, - 1, 3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, - 1, 4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, - 1, - 1, - 1, - 1, 9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, - 1, 11, 7, 4, 11, 4, 2, 2, 4, 0, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, - 1, - 1, - 1, - 1, 2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, - 1, - 1, - 1, - 1, 9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, - 1, 3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, - 1, 1, 10, 2, 8, 7, 4, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 9, 1, 4, 1, 7, 7, 1, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, - 1, - 1, - 1, - 1, 4, 0, 3, 7, 4, 3, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 4, 8, 7, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 10, 8, 10, 11, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 0, 9, 3, 9, 11, 11, 9, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 1, 10, 0, 10, 8, 8, 10, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 1, 10, 11, 3, 10, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 2, 11, 1, 11, 9, 9, 11, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, - 1, - 1, - 1, - 1, 0, 2, 11, 8, 0, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 3, 2, 11, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 3, 8, 2, 8, 10, 10, 8, 9, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 9, 10, 2, 0, 9, 2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, - 1, - 1, - 1, - 1, 1, 10,
2, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 1, 3, 8, 9, 1, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 9, 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, 0, 3, 8, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1, - 1]);