SetFactory("OpenCASCADE");

// ===================== PARÁMETROS =====================
r2 = 5.0e-3;
h0 = 3.5e-3;
h1 = 3.3e-3;

r1 = 2.0e-3;      // radio interno imanes interiores
r3 = 6.0e-3;      // radio interno imanes exteriores
r4 = 8.0e-3;      // radio externo imanes exteriores

air_gap = r3 - r2;

domain_radius = 14.5e-3;
domain_height = 24.0e-3;

// ===================== GEOMETRÍA =====================
// Aire (volumen externo)
Cylinder(100) = {0, 0, -domain_height/2, 0, 0, domain_height, domain_radius, 2*Pi};

// --- Imán exterior inferior (anillo) ---
z_me1 = -h1/2;
Cylinder(1) = {0, 0, z_me1, 0, 0, h1, r4, 2*Pi};
Cylinder(2) = {0, 0, z_me1, 0, 0, h1, r3, 2*Pi};
MagExt1[] = BooleanDifference{ Volume{1}; Delete; }{ Volume{2}; Delete; };
mag_ext_inf = MagExt1[0];

// --- Imán exterior superior (anillo) ---
z_me2 = z_me1 + h1 + air_gap;
Cylinder(3) = {0, 0, z_me2, 0, 0, h1, r4, 2*Pi};
Cylinder(4) = {0, 0, z_me2, 0, 0, h1, r3, 2*Pi};
MagExt2[] = BooleanDifference{ Volume{3}; Delete; }{ Volume{4}; Delete; };
mag_ext_sup = MagExt2[0];

// --- Imán interior inferior (anillo) ---
z_mi1 = -h0/2;
Cylinder(5) = {0, 0, z_mi1, 0, 0, h0, r2, 2*Pi};
Cylinder(6) = {0, 0, z_mi1, 0, 0, h0, r1, 2*Pi};
MagInt1[] = BooleanDifference{ Volume{5}; Delete; }{ Volume{6}; Delete; };
mag_int_inf = MagInt1[0];

// --- Imán interior superior (anillo) ---
z_mi2 = z_mi1 + h0 + air_gap;
Cylinder(7) = {0, 0, z_mi2, 0, 0, h0, r2, 2*Pi};
Cylinder(8) = {0, 0, z_mi2, 0, 0, h0, r1, 2*Pi};
MagInt2[] = BooleanDifference{ Volume{7}; Delete; }{ Volume{8}; Delete; };
mag_int_sup = MagInt2[0];

// Unifica geometría antes de recortar aire
Coherence;

// ===================== AIRE = CILINDRO - IMANES =====================
AirDom[] = BooleanDifference{ Volume{100}; Delete; }
                         { Volume{mag_ext_inf, mag_ext_sup, mag_int_inf, mag_int_sup}; };
air_vol = AirDom[0];

// Unificación final de interfaces compartidas
Coherence;

// ===================== (OPCIONAL) FORZAR CONFORMIDAD SIN PARTIR CUERPOS =====================
// En la práctica, con el Difference de aire + Coherence ya queda conformal.
// NO usar BooleanFragments aquí para no crear subvolúmenes extra.

// ===================== GRUPOS FÍSICOS (SOLO VOLÚMENES) =====================
Physical Volume("Magnet_Exterior_1") = { mag_ext_inf };
Physical Volume("Magnet_Exterior_2") = { mag_ext_sup };
Physical Volume("Magnet_Interior_1") = { mag_int_inf };
Physical Volume("Magnet_Interior_2") = { mag_int_sup };
Physical Volume("Air_Domain")        = { air_vol };

// (NO definir Physical Surface: Elmer detectará fronteras externas e interfaces automáticamente)

// ===================== MALLA =====================
Mesh.CharacteristicLengthMax = 0.0005;
Mesh.CharacteristicLengthMin = 0.0001;
Mesh.Algorithm   = 6;   // Frontal-Delaunay
Mesh.Algorithm3D = 10;  // HXT
Mesh.ElementOrder = 1;
Mesh.Optimize = 1;
Mesh.OptimizeNetgen = 1;

// Mallado 3D
Mesh 3;

// (Opcional) Ocultar el aire en la GUI de Gmsh
// Hide { Volume{ air_vol }; }
