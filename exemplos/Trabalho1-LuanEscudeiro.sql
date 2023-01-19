CREATE TABLE Aluno(
Nome VARCHAR(50) NOT NULL,
RA DECIMAL(8) NOT NULL,
DataNasc DATE NOT NULL,
Idade DECIMAL(3),
NomeMae VARCHAR(50) NOT NULL,
Cidade VARCHAR(30),
Estado CHAR(2),
Curso VARCHAR(50),
periodo integer
);

CREATE TABLE Discip(
Sigla CHAR(7) NOT NULL,
Nome VARCHAR(25) NOT NULL,
SiglaPreReq CHAR(7),
NNCred DECIMAL(2) NOT NULL,
Monitor DECIMAL(8),
Depto CHAR(8)
);

CREATE TABLE Matricula(
RA DECIMAL(8) NOT NULL,
Sigla CHAR(7) NOT NULL,
Ano CHAR(4) NOT NULL,
Semestre CHAR(1) NOT NULL,
CodTurma DECIMAL(4) NOT NULL,
NotaP1 NUMERIC(3,1),
NotaP2 NUMERIC(3,1),
NotaTrab NUMERIC(3,1),
NotaFIM NUMERIC(3,1),
Frequencia DECIMAL(3)
);

--PK E FK--
ALTER TABLE Aluno 
ADD CONSTRAINT id_aluno 
PRIMARY KEY (RA);

ALTER TABLE Discip 
ADD CONSTRAINT id_discip 
PRIMARY KEY (Sigla);

ALTER TABLE Matricula 
ADD CONSTRAINT id_discip_fk 
FOREIGN KEY (Sigla) REFERENCES Discip (Sigla)
ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE Matricula 
ADD CONSTRAINT id_aluno_fk 
FOREIGN KEY (RA) REFERENCES Aluno (RA)
ON UPDATE CASCADE ON DELETE SET NULL;

--Numero aleatorio (Quantidade max de digitos por parametro)
create or replace function numero(digitos integer) returns integer as $$
begin
	return trunc(random()*power(10,digitos));
end;
$$language plpgsql;

--Random Date
create or replace function data() returns date as
$$
begin
	return date(timestamp '1980-01-01 00:00:00' +
			random() * (timestamp '2017-01-30 00:00:00' -
			timestamp '1990-01-01 00:00:00'));
end;
$$language plpgsql;

--Random Text
Create or replace function texto(tamanho integer) returns text as $$
declare
	chars text[] := '{A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
	result text := '';
	i integer := 0;
begin
	if tamanho < 0 then
		raise exception 'Tamanho dado nao pode ser menor que zero';
	end if;
	for i in 1..tamanho loop
		result := result || chars[1+random()*(array_length(chars, 1)-1)];
		end loop;
	return result;
end;
$$ language plpgsql;
--select texto(5)

--Popular tabelas
--Table Aluno
Do $$
begin
	for i in 0..600 loop
		INSERT INTO Aluno VALUES (texto(25), i, data(), numero(2), texto(20), 'Sao Paulo', 'SP', 'Medicina Veterinaria', numero(1)) ON CONFLICT DO NOTHING;
	end loop;
end$$;
analyze Aluno;

do $$
begin
	for i in 601..1200 loop
		INSERT INTO Aluno VALUES (texto(25), i, data(), numero(2), texto(20), 'Pato Branco', 'PR', 'Engenharia de Computacao', numero(1)) ON CONFLICT DO NOTHING;
	end loop;
end$$;
analyze Aluno;

Do $$
begin
	for i in 1201..1800 loop
		INSERT INTO Aluno VALUES (texto(25), i, data(), numero(2), texto(20), 'Buenos Aires', 'BA', 'Arquitetura', numero(1)) ON CONFLICT DO NOTHING;
	end loop;
end$$;
analyze Aluno;

commit;

--Disciplina
INSERT INTO Discip VALUES ('CA28CP', 'Calculo 1', 'Nada', 6, 1809784, 'DAMAT');
INSERT INTO Discip VALUES ('CA29CP', 'Calculo 2', 'CA28CP', 6, 1890867, 'DAMAT');
INSERT INTO Discip VALUES ('CA30CP', 'Calculo 3', 'CA29CP', 6, 1234567, 'DAMAT');
INSERT INTO Discip VALUES ('BD26CP', 'Banco de dados 1', 'CA28MC', 5, 7654321, 'DAINF');
INSERT INTO Discip VALUES ('BD27CP', 'Banco de dados 2', 'BD26CP', 5, 1265487, 'DAINF');
INSERT INTO Discip VALUES ('GA01CP', 'Geometria Analitica', 'Nada', 4, 9571326, 'DAMAT');
INSERT INTO Discip VALUES ('DE32CP', 'Desenho Tecnico', 'CA28CP', 5, 4598763,'DACIV');
INSERT INTO Discip VALUES ('LI26LE', 'Libras 1', 'Nada', 2, 467764,'DAQUI');

analyze Discip;

--Popular Matricula
DO $$
BEGIN
	FOR i IN 0..200 LOOP
		INSERT INTO Matricula VALUES (i, 'DE32CP', '2021', numero(1), i, 7.5, 8.5, 9, 8.5, 75) ON CONFLICT DO NOTHING;
	END LOOP;
END$$;
ANALYZE Aluno;

DO $$
BEGIN
	FOR i IN 201..400 LOOP
		INSERT INTO Matricula VALUES (i, 'GA01CP', '2021', numero(1), i, 8, 8, 8, 8, 80) ON CONFLICT DO NOTHING;
	END LOOP;
END$$;
ANALYZE Aluno;

DO $$
BEGIN
	FOR i IN 401..600 LOOP
		INSERT INTO Matricula VALUES (i, 'LI26LE', '2021', numero(1), i, 6, 7, 6, 6.5, 75) ON CONFLICT DO NOTHING;
	END;
END$$;
ANALYZE Aluno;

DO $$
BEGIN
	FOR i IN 601..800 LOOP
		INSERT INTO Matricula VALUES (i, 'BD27CP', '2021', numero(1), i, 4, 8, 9, 7.5, 82) ON CONFLICT DO NOTHING;
	END LOOP;
END$$;
ANALYZE Aluno;

DO $$
BEGIN
	FOR i IN 801..1000 LOOP
		INSERT INTO Matricula VALUES (i, 'CA30CP', '2021', numero(1), i, 7, 9, 8, 8, 90) ON CONFLICT DO NOTHING;
	END LOOP;
END$$;
ANALYZE Aluno;

---Exer 02----
CREATE UNIQUE INDEX IdxAlunoNNI ON Aluno (Nome, NomeMae, Idade);

EXPLAIN
SELECT RA, Nome, NomeMae, Idade from Aluno where Nome ='ECvbJZYoBSnyDbcfjsEuuQxZQ';

EXPLAIN
select RA, Nome, NomeMae, Idade from Aluno where idade = 29;

--Exer 03
--Sequential Scan

CREATE INDEX IdadeAluno ON Aluno(Idade);
EXPLAIN
SELECT RA, Nome, Cidade, Idade FROM Aluno WHERE idade>22;

--Bitmap Index Scan
CREATE INDEX indPeriodo ON Aluno(periodo);
EXPLAIN
SELECT RA, Nome, NomeMae, Idade FROM Aluno WHERE periodo = 8;

--Index Scan

CREATE INDEX indIdade ON Aluno(RA) WHERE Idade >= 18 AND Idade <= 25 ;
EXPLAIN
SELECT Nome, Cidade, Idade, Curso FROM Aluno WHERE Idade>=20 AND IDADE <=30 ;

--Index-Only Scan

CREATE INDEX indCity ON Aluno(Cidade);
DROP INDEX indCity ;

EXPLAIN ANALYZE
SELECT Cidade FROM Aluno WHERE Cidade = 'Sao Paulo';

--e) Multi-Index
CREATE INDEX PeriodoIdade ON Aluno(periodo, Idade);
CREATE INDEX EstadoIdade ON Aluno(Estado, Idade);

EXPLAIN ANALYZE
SELECT Nome, Idade FROM Aluno WHERE periodo = 8 AND Idade = 42;

--Exer 04
CREATE INDEX MatriculaAluno ON Matricula(RA);
EXPLAIN ANALYZE
SELECT * FROM Aluno NATURAL JOIN Matricula
WHERE RA = 1799;

CREATE INDEX MatriculaDiscip ON Matricula(Sigla);

EXPLAIN ANALYZE
SELECT * FROM Discip NATURAL JOIN Matricula
WHERE Sigla = 'DE32CP';

--Exer 05
CREATE EXTENSION btree_gin;
CREATE INDEX idBitmap_periodo ON Aluno USING gin (periodo);

EXPLAIN ANALYZE
SELECT RA, Nome, periodo
FROM Aluno
WHERE Periodo = 8

--Exer 06

CREATE INDEX indCluster on Aluno(RA);
EXPLAIN ANALYZE
SELECT RA, Nome, periodo FROM Aluno WHERE RA = 700 and Cidade = 'Buenos Aires';

CLUSTER Aluno USING indCluster;
ANALYZE Aluno;
CLUSTER Aluno;

EXPLAIN ANALYZE
SELECT RA, Nome, periodo FROM Aluno WHERE RA = 700 and Cidade = 'Buenos Aires';

--Exer 07
ALTER TABLE Aluno ADD COLUMN informacoesExtras json;

DO $$
DECLARE
	vartype varchar[] = '{"Sao Paulo", "Real Madrid", "Juventus" , "Barcelona", "Tottenham", "Boca Juniors", "River Plate", "Shaktar Donetsk", "Chapecoense", "Cruzeiro", "Azures"}';
BEGIN
	FOR i IN 0..1800 LOOP
		UPDATE Aluno SET informacoesExtras = ('{"time" : "' || vartype[numero(1) + 1] || '", "telefone" : ' || numero(8) || '}')::json
		WHERE RA = i;
	END LOOP;
END; $$
language plpgsql;
ANALYZE Aluno;

CREATE INDEX Time ON Aluno USING BTREE ((informacoesExtras->>'time'));
EXPLAIN ANALYZE
select * from Aluno where informacoesExtras ->> 'time' = 'Sao Paulo';

