
DROP USER IF EXISTS 'lccdbuser'@'localhost';
DROP DATABASE IF EXISTS `LCC`;
CREATE DATABASE `LCC`;
CREATE USER lccdbuser@localhost IDENTIFIED BY 'LoRaCmdCtrl';
USE `LCC`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, EXECUTE, CREATE ROUTINE, ALTER ROUTINE, TRIGGER ON `LCC`.* TO 'lccdbuser'@'localhost';
FLUSH PRIVILEGES;

-- --------------------------------------------------------
--
-- Table structure for table `sound_server`
--

CREATE TABLE `sound_server` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `sound` int(11) DEFAULT NULL,
  `volume` tinyint(4) DEFAULT NULL,
  `replay` tinyint(4) DEFAULT NULL,
  `last_update` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `sound_server`
--
ALTER TABLE `sound_server`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `sound_server`
--
ALTER TABLE `sound_server`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

COMMIT;
