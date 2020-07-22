DROP DATABASE Baza_MJ; 
GO 
 
CREATE DATABASE Baza_MJ; 
GO 
 
USE Baza_MJ; 
GO 
 
 
------------ USUŃ TABELE ------------ 
 
DROP TABLE IF EXISTS Marka; 
DROP TABLE IF EXISTS Model; 
DROP TABLE IF EXISTS Typ_silnika; 
DROP TABLE IF EXISTS Dealer; 
DROP TABLE IF EXISTS Samochod; 
DROP TABLE IF EXISTS Dodatkowe_wyposazenie; 
DROP TABLE IF EXISTS Klient; 
DROP TABLE IF EXISTS Sprzedaz; 
 
DROP TABLE IF EXISTS Model_silnik; 
DROP TABLE IF EXISTS Posiada_wyposazenie; 
DROP TABLE IF EXISTS Ma_w_profilu; 
DROP TABLE IF EXISTS Samochod_Dealer; 
 
DROP TABLE IF EXISTS Samochod_osobowy; 
DROP TABLE IF EXISTS Samochod_ciezarowy; 
 
GO 
 
SET LANGUAGE polski 
GO 
 
------------ CREATE I INSERT ------------ 
 
 
CREATE TABLE Marka 
( 
    nazwa  VARCHAR(30) NOT NULL CONSTRAINT pk_marka_nazwa PRIMARY KEY,     rok_zalozenia  INT, 
) 
GO 
 
CREATE TABLE Model 
(     id INT NOT NULL CONSTRAINT pk_model_id PRIMARY KEY,     rok_wprowadzenia  INT, 
    nazwa_marki  VARCHAR(30) REFERENCES Marka(nazwa) ON DELETE CASCADE,     nazwa_modelu VARCHAR(30),     poprzednik_id INT DEFAULT NULL 
) 
GO 
 
CREATE UNIQUE INDEX poprzednik_NULL 
ON Model(poprzednik_id) 
WHERE Poprzednik_id IS NOT NULL 
GO 
 
CREATE TRIGGER trigger_1 
ON Model 
AFTER INSERT, UPDATE 
AS 
PRINT 'To musi byc samochod osobowy, albo samochod ciezarowy.' 
GO 
 
CREATE TABLE Typ_silnika 
( 
    id INT NOT NULL CONSTRAINT pk_typ_silnika_id PRIMARY KEY,     rodzaj_paliwa  Varchar(30),     opis_parametrow  VARCHAR(30) 
) 
GO 
 
CREATE TABLE Dealer 
( 
    nazwa VARCHAR(30) NOT NULL CONSTRAINT pk_dealer_nazwa PRIMARY KEY,     adres VARCHAR(30) 
) 
GO 
 
CREATE TABLE Samochod 
( 
    VIN VARCHAR(17) NOT NULL CONSTRAINT pk_samochod_vin PRIMARY KEY,     rok_produkcji  INT,     kraj_pochodzenia  VARCHAR(30),     przebieg_KM INT,     skrzynia_biegow VARCHAR(30), 
    id_model INT NOT NULL REFERENCES Model(id) ON DELETE CASCADE,     id_typ_silnika INT NOT NULL REFERENCES Typ_silnika(id),     CONSTRAINT pk_samochod CHECK (VIN LIKE '%%%%%%%%%%%%%%%%%') 
) 
GO 
 
 
CREATE TABLE Dodatkowe_wyposazenie 
( 
   nazwa VARCHAR(30) NOT NULL  CONSTRAINT pk_dodatkowe_wyposazenie_nazwa PRIMARY KEY ) 
GO 
 
CREATE TABLE Klient 
(id INT NOT NULL CONSTRAINT pk_klient_id PRIMARY KEY, imie VARCHAR(30), nazwisko VARCHAR(30), nr_telefonu VARCHAR(11) 
CONSTRAINT pk_nr_telefonu CHECK (nr_telefonu LIKE '%%%%%%%%%%%') 
) 
GO 
 
CREATE TABLE Sprzedaz 
( 
    cena_ZL INT NOT NULL,     daty DATE NOT NULL UNIQUE, 
    nazwa_dealer VARCHAR(30) NOT NULL REFERENCES Dealer(nazwa),     samochod_vin VARCHAR(17) NOT NULL REFERENCES Samochod(VIN),     id_klient INT NOT NULL REFERENCES Klient(id) 
) 
GO 
 
CREATE TABLE Model_silnik 
( 
   model_id INT REFERENCES Model(id) ON DELETE CASCADE, 
   typ_silnika_id INT REFERENCES Typ_silnika(id) ON DELETE CASCADE 
) 
GO 
 
 
CREATE TABLE Posiada_wyposazenie 
( 
   samochod_VIN Varchar(17) REFERENCES Samochod(VIN) ON DELETE CASCADE, 
   wyposazenie_nazwa Varchar(30) REFERENCES Dodatkowe_wyposazenie(nazwa) ON DELETE CASCADE ) 
GO 
 
CREATE TABLE Ma_w_profilu 
( 
   nazwa_dealer Varchar(30) REFERENCES Dealer(nazwa) ON DELETE CASCADE,    model_id INT REFERENCES Model(id) ON DELETE CASCADE 
) 
GO 
 
 
CREATE TABLE Samochod_Dealer 
( 
   Samochod_VIN Varchar(17) REFERENCES Samochod(VIN) ON DELETE CASCADE, 
   Nazwa_dealer Varchar(30) REFERENCES Dealer(nazwa) ON DELETE CASCADE, CONSTRAINT nazwa_s_d PRIMARY KEY (Samochod_VIN) 
) 
GO 
 
CREATE TABLE Samochod_Osobowy 
( 
   Model_id INT REFERENCES Model(id) ON DELETE CASCADE,    liczba_pasazerow INT,    poj_silnika INT 
) 
GO 
 
CREATE TABLE Samochod_Ciezarowy 
( 
   Model_id INT REFERENCES Model(id) ON DELETE CASCADE, 
   Ladownosc_KG INT 
) 
GO 
 
------------ WIDOK ----------- 
 
CREATE VIEW Samochody_z_wyposazeniem(VIN) 
AS 
( 
    SELECT VIN FROM Samochod 
    WHERE VIN IN (SELECT samochod_VIN FROM Posiada_wyposazenie) ); 
GO 
-------------PROCEDURY------------------- 
 
CREATE PROCEDURE liczba_sprzedanych_samochodow_w_danym_roku 
    @rok_sprzedazy  DATE 
AS 
BEGIN 
    DECLARE @liczba_samochodow INT; 
 
    SELECT @liczba_samochodow = COUNT(*) 
    FROM   sprzedaz 
    WHERE  daty >= @rok_sprzedazy; 
 
    PRINT @liczba_samochodow; 
END; 
GO 
 
CREATE PROCEDURE INSERT_Model 
    @id INT, 
    @rok_wprowadzenia INT, 
    @nazwa_marki VARCHAR(30), 
    @nazwa_modelu VARCHAR(30), 
    @poprzednik_id VARCHAR(30) 
AS 
BEGIN 
    INSERT INTO Model(id, rok_wprowadzenia, nazwa_marki, nazwa_modelu, poprzednik_id) VALUES  
(@id, @rok_wprowadzenia, @nazwa_marki, @nazwa_modelu, @poprzednik_id) 
END; 
GO 
 
 
 
CREATE PROCEDURE UPDATE_DATA_Model_PODAJ_ID 
    @rok_wprowadzenia INT, 
    @id INT 
AS 
BEGIN 
UPDATE Model 
SET rok_wprowadzenia = @rok_wprowadzenia 
WHERE id = @id; 
END; 
GO 
 
 
CREATE PROCEDURE DELETE_Model_PODAJ_ID 
    @id INT 
AS 
BEGIN 
   DELETE FROM Model 
WHERE id= @id; 
END; 
GO 
 
CREATE PROCEDURE Sprzedaj_samochod 
    @cena_zl  INT, 
    @daty DATE, 
    @nazwa_dealer VARCHAR(30), 
    @samochod_vin VARCHAR(17), 
    @id_klient INT  
AS 
BEGIN 
INSERT INTO Sprzedaz(cena_zl, daty, nazwa_dealer, samochod_vin, id_klient) VALUES  
(@cena_zl, @daty, @nazwa_dealer, @samochod_vin, @id_klient) 
UPDATE Samochod_Dealer 
    SET Samochod_Dealer.nazwa_dealer = NULL 
    WHERE Samochod_Dealer.samochod_VIN IN (SELECT samochod_vin FROM Sprzedaz) END; 
GO 
 
---------FUNKCJE------------------------- 
 
CREATE FUNCTION ile_lat_ma_samochod 
( 
    @rok_produkcji INT 
) 
    RETURNS INT 
AS 
BEGIN 
    RETURN YEAR(getdate()) - @rok_produkcji; 
END; 
GO 
 
 
CREATE FUNCTION samochody_z_danego_kraju 
( 
    @kraj VARCHAR(30) 
) 
    RETURNS TABLE 
AS 
    RETURN SELECT * 
           FROM   Samochod 
           WHERE  kraj_pochodzenia = @kraj; 
GO 
 
---------------------------------------- 
 
 
INSERT INTO Marka (nazwa, rok_zalozenia) VALUES  
('Audi', 1909), 
('Volkswagen', 1937), 
('Renault', 1899), 
('Peugeot', 1896), 
('Citroen', 1919), 
('Ford', 1903), 
('Opel', 1862), 
('Hyundai', 1963), 
('Skoda', 1895), 
('Volvo', 1927) 
GO 
 
 
INSERT INTO Model (id, rok_wprowadzenia, nazwa_marki, nazwa_modelu, poprzednik_id) VALUES  (1, 1980, 'Audi', 'Quattro', NULL), 
(2, 1990, 'Audi', 'S2', 1), 
(3, 1997, 'Audi', 'A4', 2), 
(4, 1968, 'Ford', 'Escort', NULL), 
(5, 1998, 'Ford', 'Focus', 4), 
(6, 1977, 'Volvo', 'F', NULL), 
(7, 1994, 'Volvo', 'FH', 6), 
(8, 1999, 'Skoda', 'Fabia', NULL), 
(9, 1991, 'Opel', 'Astra', NULL), 
(10, 1975, 'Volkswagen', 'Polo', NULL) 
GO 
 
 
INSERT INTO Typ_silnika (id, rodzaj_paliwa, opis_parametrow) VALUES 
(1, 'benzyna', 'R5 2.1T 200KM'), 
(2, 'benzyna', '2.2 20V'), 
(3, 'benzyna', '1.6l 102KM'), 
(4, 'benzyna', '1.6 16V'), 
(5, 'ropa', '1.9 diesel'), 
(6, 'benzyna', '1.9 DCI F9K'), 
(7, 'ropa', 'D12 diesel'), 
(8, 'benzyna', '1.2l'), 
(9, 'benzyna', '2.0l A16XHT SIDI'), 
(10, 'benzyna', '1.2 12V') 
GO 
 
 
INSERT INTO Dealer (nazwa, adres) VALUES  
('Kozlowski', 'Poznan'), 
('Malinowski', 'Poznan'), 
('Jozwiak', 'Warszawa'), 
('Chlebowski', 'Warszawa'), 
('Fiolkowski', 'Gdynia'), 
('Garlicz', 'Gdansk'), 
('Mazurek', 'Wroclaw'), 
('Gdybala', 'Krakow'), 
('Kowalski', 'Lodz'), 
('Janicki', 'Lodz') 
GO 
 
 
INSERT INTO Samochod (VIN, rok_produkcji, kraj_pochodzenia, przebieg_KM, skrzynia_biegow, id_model, id_typ_silnika) VALUES  
('WAULC68E44A074252', 1999, 'Niemcy', 244000, 'manualna', 3, 3), 
('WAUZZZ8K4BN007284', 2000, 'Niemcy', 235890, 'manualna', 3, 3), 
('WF0PXXGCDP8G34436', 2006, 'Ameryka', 144050, 'automatyczna', 5, 5), 
('WF0PXXGCDP8K89134', 1999, 'Ameryka', 178830, 'manualna', 5, 5), 
('TMBPH16Y21X016302', 2000, 'Czechy', 133098, 'manualna', 8, 8), ('TMBPH16Y21X216709', 2002, 'Czechy', 78098, 'manualna', 8, 8), 
('WVWZZZ6NZ1D024993', 2002, 'Niemcy', 202681, 'manualna', 3, 3), 
('WVWZZZ6NZ1D025614', 2006, 'Niemcy', 176390, 'automatyczna', 10, 10), 
('YV2AS02A97B482637', 1999, 'Szwecja', 324000, 'manualna', 7, 7), 
('WOAZZZ6NZ1D922781', 1992, 'Niemcy', 199890, 'manualna', 9, 9) GO 
 
 
INSERT INTO Dodatkowe_wyposazenie (nazwa) VALUES  
('skorzana tapicerka'), 
('Radio'), 
('Wieksze kola'), 
('Wieksze turbo'), 
('Fotel z pelna regulacja'), 
('Centralny zamek'), 
('Hak holowniczy'), 
('Wspomaganie kierownicy'), 
('Mocniejszy silnik'), 
('Skrzynia 6-biegowa') 
GO 
 
 
 
 
Insert INTO Model_silnik(model_id, typ_silnika_id) VALUES 
(1,1), 
(2,2), 
(3,3), 
(3,2), 
(4,2), 
(4,4), 
(5,5), 
(6,6), 
(7,7), 
(8,8), 
(9,9), 
(10,10) 
GO 
 
 
Insert INTO Posiada_wyposazenie(samochod_VIN, wyposazenie_nazwa) VALUES 
('TMBPH16Y21X016302', 'Centralny zamek'), 
('TMBPH16Y21X016302', 'Radio'), 
('WAULC68E44A074252', 'Mocniejszy silnik'), 
('WVWZZZ6NZ1D024993', 'Centralny zamek'), 
('WVWZZZ6NZ1D024993', 'skorzana tapicerka'), 
('WF0PXXGCDP8K89134', 'Fotel z pelna regulacja'), 
('WOAZZZ6NZ1D922781', 'Radio'), 
('TMBPH16Y21X216709', 'Skrzynia 6-biegowa'), 
('TMBPH16Y21X216709', 'skorzana tapicerka'), 
('TMBPH16Y21X216709', 'Fotel z pelna regulacja') 
GO 
 
 
Insert INTO Ma_w_profilu(model_id, nazwa_dealer) VALUES 
(8, 'Garlicz'), 
(8, 'Jozwiak'), 
(3,'Kozlowski'), 
(3,'Malinowski'), 
(5,'Mazurek'), 
(5,'Mazurek'), 
(9,'Malinowski'), 
(3,'Malinowski') 
GO 
 
 
Insert INTO Samochod_Dealer(samochod_VIN, nazwa_dealer) VALUES  
('TMBPH16Y21X016302', 'Garlicz'), 
('TMBPH16Y21X216709', 'Jozwiak'), 
('WAULC68E44A074252', 'Kozlowski'), 
('WAUZZZ8K4BN007284', 'Malinowski'), 
('WF0PXXGCDP8G34436', 'Mazurek'), 
('WF0PXXGCDP8K89134', 'Mazurek'), 
('WOAZZZ6NZ1D922781', 'Malinowski'), 
('WVWZZZ6NZ1D024993', 'Malinowski') 
GO 
 
INSERT INTO Samochod_osobowy (Model_id, liczba_pasazerow, poj_silnika) VALUES  
(1, 5, 2.1), 
(2, 5, 2.2), 
(3, 5, 1.6), 
(4, 5, 1.6), 
(5, 5, 1.9), 
(8, 5, 1.2), 
(9, 5, 2.0), 
(10, 5, 1.2) 
GO 
 
 
INSERT INTO Samochod_ciezarowy (Model_id, ladownosc_KG) VALUES  
(6, 8050), 
(7, 8960) 
GO  
create trigger trigger_2 on Samochod for insert  as  if (select count(*)  
    from Model_silnik, inserted      where model_silnik.model_id = 
inserted.id_model AND model_silnik.typ_silnika_id = inserted.id_typ_silnika) != 
    @@rowcount  
   begin 
    rollback transaction      print 
'Ten model samochodu nie moze miec takiego silnika.'   end    else 
  print 'Dodane! Ten model samochodu moze miec taki silnik.' 
GO 
 
 
------------ SELECT ----------- 
 
SELECT * FROM Marka; 
SELECT * FROM Model; 
SELECT * FROM Typ_silnika; 
SELECT * FROM Dealer; 
SELECT * FROM Samochod; 
SELECT * FROM Dodatkowe_wyposazenie; 
SELECT * FROM Model_silnik; 
SELECT * FROM Posiada_wyposazenie; SELECT * FROM Ma_w_profilu; 
SELECT * FROM Samochod_Dealer; 
 
------------ Wstawienie zainteresowanych klientow----------- 
 
INSERT INTO Klient (id, imie, nazwisko, nr_telefonu) VALUES  
(1, 'Michal', 'Ogrodnik', '723 653 111'), 
(2, 'Marcin', 'Kowalczyk', '863 193 222'), 
(3, 'Pawel', 'Milczyk', '831 442 333'); 
 
 
---- Procedury wywolanie (Raport, INSERT, UPDATE, DELETE)--------  
EXECUTE liczba_sprzedanych_samochodow_w_danym_roku '01-01-2018'; 
 
EXECUTE INSERT_Model 11, 1996, 'Citroen', 'A1', NULL; 
 
EXECUTE UPDATE_DATA_Model_PODAJ_ID 2000, 11; 
 
EXECUTE DELETE_Model_PODAJ_ID 11; 
 
---- Procedura sprzedajaca samochod -------------------------- 
 
EXECUTE Sprzedaj_samochod 5700, '02-05-2018', 'Mazurek', 'WF0PXXGCDP8G34436', 1; 
EXECUTE Sprzedaj_samochod 4200, '03-06-2018', 'Mazurek', 'WF0PXXGCDP8K89134', 2; 
EXECUTE Sprzedaj_samochod 5700, '07-03-2018', 'Kozlowski', 'WAULC68E44A074252', 3;  
SELECT * FROM Samochod_Dealer; 
 
------------ FUNKCJE wywolanie ----------- 
 
SELECT VIN,  
       dbo.ile_lat_ma_samochod(rok_produkcji) AS 'ile ma lat' 
FROM   Samochod; 
 
 
SELECT *  
FROM   dbo.samochody_z_danego_kraju('Niemcy'); 
 
------------ Wstawienie samochodu ze złym silnikiem ----------- 
 
---INSERT INTO Samochod(VIN, rok_produkcji, kraj_pochodzenia, przebieg_KM, 
skrzynia_biegow, id_model, id_typ_silnika) VALUES ('WOAZZZ6NZ1D999999', 1992, 'Niemcy', 
19900, 'manualna', 9, 1); 
