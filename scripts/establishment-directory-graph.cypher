// Establisment-Directory-graph LOAD CSV cypher script
CREATE CONSTRAINT FOR (e:Perusahaan) REQUIRE e.no IS UNIQUE;
CREATE CONSTRAINT FOR (c:KategoriKBLI) REQUIRE c.kategori_id IS UNIQUE;
CREATE CONSTRAINT FOR (g:GolonganKBLI) REQUIRE g.golongan_id IS UNIQUE;
CREATE CONSTRAINT FOR (p:Provinsi) REQUIRE p.prov_id IS UNIQUE;
CREATE CONSTRAINT FOR (k:KabupatenKota) REQUIRE k.kako_id IS UNIQUE;

// Load Provinsi
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/ekotwidodo/KG-Establishment-Directory/main/import/prov.csv' AS line
MERGE (p:Provinsi {prov_id: line.prov_id, prov_nama: line.prov_nama});

// Load Kabupaten/Kota
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/ekotwidodo/KG-Establishment-Directory/main/import/kako.csv' AS line
MERGE (k:KabupatenKota {kako_id: line.kako_id, kako_nama: line.kako_nama})
WITH line, k
MERGE (p:Provinsi {prov_id: line.prov_id})
MERGE (k)-[:IS_KAKO_OF]->(p);

// Load Kategori KBLI
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/ekotwidodo/KG-Establishment-Directory/main/import/kategori_kbli.csv' AS line
MERGE (c:KategoriKBLI {kategori_id: line.kategori_id, kategori_nama: line.kategori_nama});

// Load Golongan KBLI
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/ekotwidodo/KG-Establishment-Directory/main/import/golongan_kbli.csv' AS line
MERGE (g:GolonganKBLI {golongan_id: line.golongan_id, golongan_nama: line.golongan_nama})
WITH line, g
MERGE (c:KategoriKBLI {kategori_id: line.kategori_id})
MERGE (g)-[:IS_KATEGORI_KBLI_OF]->(c);

// Load Perusahaan
LOAD CSV WITH HEADERS
FROM 'https://raw.githubusercontent.com/ekotwidodo/KG-Establishment-Directory/main/import/perusahaan.csv' AS line
MERGE (e:Perusahaan {
    nama: line.nama, 
    alamat: line.alamat, 
    latitude: CASE WHEN line.latitude IS NULL OR line.latitude = '' THEN null ELSE line.latitude END,
    longitude: CASE WHEN line.longitude IS NULL OR line.longitude = '' THEN null ELSE line.longitude END
    })
    ON CREATE SET e = line

MERGE (p:Provinsi {prov_id: line.prov_id})
MERGE (e)-[:HAS_PROVINSI]->(p)
MERGE (k:KabupatenKota {kako_id: line.kako_id})
MERGE (e)-[:HAS_KAKO]->(k)

WITH line, e
WHERE line.kbli IS NOT NULL AND line.kbli <> ''
MERGE (b:KBLI {kbli: line.kbli})
MERGE (e)-[:HAS_KODE_KBLI]->(b)

WITH line, e
WHERE line.kategori_kbli IS NOT NULL AND line.kategori_kbli <> ''
MERGE (c:KategoriKBLI {kategori_kbli: line.kategori_kbli})
MERGE (e)-[:HAS_KATEGORI_KBLI]->(c)

WITH line, e
WHERE line.golongan_kbli IS NOT NULL AND line.golongan_kbli <> ''
MERGE (g:GolonganKBLI {golongan_kbli: line.golongan_kbli})
MERGE (e)-[:HAS_GOLONGAN_KBLI]->(g);

CREATE INDEX FOR (e:Perusahaan) ON (e.prov_id);
CREATE INDEX FOR (e:Perusahaan) ON (e.kako_id);
CREATE INDEX FOR (e:Perusahaan) ON (e.kategori_kbli);
CREATE INDEX FOR (e:Perusahaan) ON (e.golongan_kbli);
CREATE INDEX FOR (e:Perusahaan) ON (e.kbli);