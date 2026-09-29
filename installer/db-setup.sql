DROP USER IF EXISTS 'lccdbuser'@'localhost';
DROP DATABASE IF EXISTS `LCC`;
CREATE DATABASE `LCC`;
CREATE USER lccdbuser@localhost IDENTIFIED BY 'LoRaCmdCtrl';
USE `LCC`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES, EXECUTE, CREATE ROUTINE, ALTER ROUTINE, TRIGGER ON `LCC`.* TO 'lccdbuser'@'localhost';
FLUSH PRIVILEGES;

-- --------------------------------------------------------

--
-- Table structure for table `commands`
--

CREATE TABLE `commands` (
  `ID` int(11) NOT NULL,
  `cmd_name` varchar(255) DEFAULT NULL,
  `cmd_type` tinyint(4) DEFAULT NULL,
  `cmd_class` tinyint(4) DEFAULT NULL,
  `gpio_pin` tinyint(4) DEFAULT NULL,
  `direction` tinyint(4) DEFAULT NULL,
  `speed` tinyint(4) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `progression` int(11) DEFAULT NULL,
  `steps` int(11) DEFAULT NULL,
  `resolution` tinyint(4) DEFAULT NULL,
  `sound` int(11) DEFAULT NULL,
  `replay` tinyint(4) DEFAULT 0,
  `location_id` int(11) DEFAULT NULL,
  `location_action` int(11) DEFAULT NULL,
  `location_data` int(11) DEFAULT NULL,
  `light` int(11) NOT NULL DEFAULT 0,
  `red` int(11) NOT NULL DEFAULT 0,
  `green` int(11) NOT NULL DEFAULT 0,
  `blue` int(11) NOT NULL DEFAULT 0,
  `fade` float NOT NULL DEFAULT 1,
  `scene` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `commands`
--

INSERT INTO `commands` (`ID`, `cmd_name`, `cmd_type`, `cmd_class`, `gpio_pin`, `direction`, `speed`, `duration`, `progression`, `steps`, `resolution`, `sound`, `replay`, `location_id`, `location_action`, `location_data`, `light`, `red`, `green`, `blue`, `fade`, `scene`) VALUES
(1, 'Forward stop, 10 second progression', 1, 4, NULL, 1, 0, 0, 10, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(2, 'Forward to 80%, 30 second progression', 1, 4, NULL, 1, 80, 0, 30, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(3, 'Reverse to 80%, 30 second progression', 1, 4, NULL, 0, 80, 0, 30, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(4, 'Forward to 25%, 15 second progression', 1, 4, NULL, 1, 25, 0, 15, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(5, 'Reverse to 25%, 15 second progression', 1, 4, NULL, 0, 25, 0, 15, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(6, 'Reverse stop, 10 second progression', 1, 4, NULL, 0, 0, 0, 10, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `devices`
--

CREATE TABLE `devices` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `dev_name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `dev_type` tinyint(4) DEFAULT NULL,
  `last_loc` int(11) DEFAULT 0,
  `favorites` text DEFAULT NULL,
  `replay` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `devices`
--

INSERT INTO `devices` (`ID`, `address`, `dev_name`, `status`, `dev_type`, `last_loc`, `favorites`, `replay`) VALUES
(1, 'e8-06-90-95-ef-90', '1-Model Train Locomotive', 'cmd://motor/1/0/10/0', 4, 16, '1|4|2', 1),
(2, 'aa-bb-cc-dd-ee-ff', '4-Switching Controller', '<span class=\"text-success\">Sent GPIO switch command</span>', 3, 0, '', 1),
(3, '11-22-33-44-55-66', '3-Stepper Motor Controller', '<span class=\"text-success\">Sent stepper control command</span>', 2, 0, '', 1),
(4, '1a-2b-3c-4d-5e-6f', '2-Brushed Motor Controller', '<span class=\"text-success\">Sent RGB LED command</span>', 1, 0, '', 1);

-- --------------------------------------------------------

--
-- Table structure for table `inbound`
--

CREATE TABLE `inbound` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `msg` varchar(255) DEFAULT NULL,
  `creation` timestamp NULL DEFAULT current_timestamp(),
  `rcvd` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inbound`
--

INSERT INTO `inbound` (`ID`, `address`, `msg`, `creation`, `rcvd`) VALUES
(7050, 'e8-06-90-95-ef-90', '/700a57fb217054e09e638f5857ef7960/motor/1/0/10/0', '2026-09-28 18:15:26', 1),
(7051, 'e8-06-90-95-ef-90', '/exec/700a57fb217054e09e638f5857ef7960', '2026-09-28 18:15:27', 1);

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

CREATE TABLE `locations` (
  `ID` int(11) NOT NULL,
  `loc_name` varchar(255) DEFAULT NULL,
  `pin` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `locations`
--

INSERT INTO `locations` (`ID`, `loc_name`, `pin`) VALUES
(1, 'Outside track transponder 1', 16);

-- --------------------------------------------------------

--
-- Table structure for table `outbound`
--

CREATE TABLE `outbound` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `msg` varchar(255) DEFAULT NULL,
  `creation` timestamp NULL DEFAULT current_timestamp(),
  `sent_time` timestamp NULL DEFAULT NULL,
  `ack_time` timestamp NULL DEFAULT NULL,
  `exec_time` timestamp NULL DEFAULT NULL,
  `sent` tinyint(4) DEFAULT 0,
  `ack` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `outbound`
--

INSERT INTO `outbound` (`ID`, `address`, `msg`, `creation`, `sent_time`, `ack_time`, `exec_time`, `sent`, `ack`) VALUES
(3306, 'e8-06-90-95-ef-90', '/ef821598211640877b054dff59b115ea/motor/1/80/30/0', '2026-09-28 18:15:08', '2026-09-28 18:15:08', NULL, NULL, 1, 0),
(3307, 'e8-06-90-95-ef-90', '/1cd4ef21471eed9de6160b4859ef080a/motor/1/25/15/0', '2026-09-28 18:15:08', '2026-09-28 18:15:09', NULL, NULL, 1, 0),
(3308, 'e8-06-90-95-ef-90', '/700a57fb217054e09e638f5857ef7960/motor/1/0/10/0', '2026-09-28 18:15:08', '2026-09-28 18:15:11', '2026-09-28 18:15:26', '2026-09-28 18:15:27', 1, 2),
(3309, 'e8-06-90-95-ef-90', '/02589ed423df91782295f6d6dfd77562/replay/scr/2', '2026-09-28 18:15:08', '2026-09-28 18:15:12', NULL, NULL, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `scenes`
--

CREATE TABLE `scenes` (
  `ID` int(11) NOT NULL,
  `scn_name` varchar(255) DEFAULT NULL,
  `source` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `schedule`
--

CREATE TABLE `schedule` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `task_name` varchar(255) DEFAULT NULL,
  `start_hour` tinyint(4) DEFAULT NULL,
  `start_min` tinyint(4) DEFAULT NULL,
  `days` varchar(13) DEFAULT NULL,
  `last_run` timestamp NULL DEFAULT current_timestamp(),
  `disabled` tinyint(4) DEFAULT 0,
  `script` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `schedule`
--

INSERT INTO `schedule` (`ID`, `address`, `task_name`, `start_hour`, `start_min`, `days`, `last_run`, `disabled`, `script`) VALUES
(1, 'e8-06-90-95-ef-90', 'Scheduled Motor Test', 12, 15, '1|1|1|1|1|1|1', '2026-09-28 18:15:08', 0, 1);

-- --------------------------------------------------------

--
-- Table structure for table `scripts`
--

CREATE TABLE `scripts` (
  `ID` int(11) NOT NULL,
  `scr_name` varchar(255) DEFAULT NULL,
  `cmd_class` tinyint(4) DEFAULT NULL,
  `replay` tinyint(4) DEFAULT 0,
  `replay_id` int(11) NOT NULL DEFAULT 0,
  `commands` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scripts`
--

INSERT INTO `scripts` (`ID`, `scr_name`, `cmd_class`, `replay`, `replay_id`, `commands`) VALUES
(1, 'Forward test 80% down to 0%', 4, 1, 2, '2|4|1'),
(2, 'Reverse test 80% down to 0%', 4, 0, 0, '3|5|6');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `ID` int(11) NOT NULL,
  `usb_device` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`ID`, `usb_device`) VALUES
(1, '/dev/ttyACM0');

-- --------------------------------------------------------

--
-- Table structure for table `timer`
--

CREATE TABLE `timer` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `stop_time` timestamp NULL DEFAULT NULL,
  `start_command` int(11) NOT NULL DEFAULT 0,
  `stop_command` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `commands`
--
ALTER TABLE `commands`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `inbound`
--
ALTER TABLE `inbound`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `outbound`
--
ALTER TABLE `outbound`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `scenes`
--
ALTER TABLE `scenes`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `schedule`
--
ALTER TABLE `schedule`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `scripts`
--
ALTER TABLE `scripts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `timer`
--
ALTER TABLE `timer`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `commands`
--
ALTER TABLE `commands`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=94;

--
-- AUTO_INCREMENT for table `devices`
--
ALTER TABLE `devices`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `inbound`
--
ALTER TABLE `inbound`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7052;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `outbound`
--
ALTER TABLE `outbound`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3310;

--
-- AUTO_INCREMENT for table `scenes`
--
ALTER TABLE `scenes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `scripts`
--
ALTER TABLE `scripts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `timer`
--
ALTER TABLE `timer`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

COMMIT;
