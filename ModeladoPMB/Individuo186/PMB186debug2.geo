SetFactory("OpenCASCADE");

// =============================================================================
// CONFIGURACIÓN DE PARÁMETROS DEL PMB DE RUBÉN
// =============================================================================

// Geometría del Individuo 186
r2 = 5.0e-3;
h0 = 3.5e-3;
h1 = 3.3e-3;

// Geometría fija
r1 = 2.0e-3;      // radio interno imanes interiores
r3 = 6.0e-3;      // radio interno imanes exteriores
r4 = 8.0e-3;      // radio externo imanes exteriores

air_gap = r3 - r2;

// Dominio de simulación externo (cilindro de aire)
domain_radius = 12.0e-3;
domain_height = 20.0e-3;

// ------------------ GENERACIÓN DE VOLUMENES 3D ------------------

// Dominio de aire externo
Cylinder(100) = {0, 0, -domain_height/2, 0, 0, domain_height, domain_radius, 2*Pi};

// Imán exterior inferior (anillo)
z_me1 = -h1/2;
Cylinder(1) = {0, 0, z_me1, 0, 0, h1, r4, 2*Pi};
Cylinder(2) = {0, 0, z_me1, 0, 0, h1, r3, 2*Pi};
BooleanDifference(10) = { Volume{1}; Delete; }{ Volume{2}; Delete; };

// Imán exterior superior (anillo)
z_me2 = z_me1 + h1 + air_gap;
Cylinder(3) = {0, 0, z_me2, 0, 0, h1, r4, 2*Pi};
Cylinder(4) = {0, 0, z_me2, 0, 0, h1, r3, 2*Pi};
BooleanDifference(11) = { Volume{3}; Delete; }{ Volume{4}; Delete; };

// Imán interior inferior (anillo)
z_mi1 = -h0/2;
Cylinder(5) = {0, 0, z_mi1, 0, 0, h0, r2, 2*Pi};
Cylinder(6) = {0, 0, z_mi1, 0, 0, h0, r1, 2*Pi};
BooleanDifference(12) = { Volume{5}; Delete; }{ Volume{6}; Delete; };

// Imán interior superior (anillo)
z_mi2 = z_mi1 + h0 + air_gap;
Cylinder(7) = {0, 0, z_mi2, 0, 0, h0, r2, 2*Pi};
Cylinder(8) = {0, 0, z_mi2, 0, 0, h0, r1, 2*Pi};
BooleanDifference(13) = { Volume{7}; Delete; }{ Volume{8}; Delete; };

// Asegurar coherencia geométrica
Coherence;

// ------------------ VOLUMEN DE AIRE LIMPIO ------------------
// Quitar imanes del dominio de aire
BooleanDifference(200) = { Volume{100}; Delete; }{ Volume{10, 11, 12, 13}; Delete; };

// Coherencia final
Coherence;

// ------------------ DEFINICIÓN DE GRUPOS FÍSICOS ------------------
Physical Volume("Air_Domain") = {200};
Physical Volume("Magnet_Exterior_1") = {10};
Physical Volume("Magnet_Exterior_2") = {11};
Physical Volume("Magnet_Interior_1") = {12};
Physical Volume("Magnet_Interior_2") = {13};

// ------------------ DEFINICIÓN DE SUPERFICIES FÍSICAS ------------------
// Esto asegura que todas las superficies límite sean exportadas correctamente
Physical Surface("Magnet_Ext_1_Surfaces") = {Surface{In BoundingBox{r3-0.001, -r4-0.001, z_me1-0.001, r4+0.001, r4+0.001, z_me1+h1+0.001};}};
Physical Surface("Magnet_Ext_2_Surfaces") = {Surface{In BoundingBox{r3-0.001, -r4-0.001, z_me2-0.001, r4+0.001, r4+0.001, z_me2+h1+0.001};}};
Physical Surface("Magnet_Int_1_Surfaces") = {Surface{In BoundingBox{r1-0.001, -r2-0.001, z_mi1-0.001, r2+0.001, r2+0.001, z_mi1+h0+0.001};}};
Physical Surface("Magnet_Int_2_Surfaces") = {Surface{In BoundingBox{r1-0.001, -r2-0.001, z_mi2-0.001, r2+0.001, r2+0.001, z_mi2+h0+0.001};}};

// Superficies del dominio de aire
Physical Surface("Air_Boundary") = {Surface{In BoundingBox{-domain_radius-0.001, -domain_radius-0.001, -domain_height/2-0.001, domain_radius+0.001, domain_radius+0.001, domain_height/2+0.001};}};

// ------------------ MALLA ------------------
Mesh.CharacteristicLengthMax = 0.0005;
Mesh.CharacteristicLengthMin = 0.0001;

// Configuración adicional para mejorar la calidad de la malla
Mesh.Algorithm = 6;          // Frontal-Delaunay
Mesh.Algorithm3D = 10;       // HXT
Mesh.ElementOrder = 1;       // Elementos lineales
Mesh.Optimize = 1;           // Optimización de la malla
Mesh.OptimizeNetgen = 1;     // Optimización adicional

//+
Show "*";
//+
Hide {
  Volume{200}; 
}//+
Show "*";
