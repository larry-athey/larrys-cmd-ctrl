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
  `volume` tinyint(4) NOT NULL DEFAULT 25,
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

INSERT INTO `commands` (`ID`, `cmd_name`, `cmd_type`, `cmd_class`, `gpio_pin`, `direction`, `speed`, `duration`, `progression`, `steps`, `resolution`, `sound`, `volume`, `replay`, `location_id`, `location_action`, `location_data`, `light`, `red`, `green`, `blue`, `fade`, `scene`) VALUES
(1, 'Forward to 80%, 15 sec progrssion', 1, 1, NULL, 1, 80, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(2, 'Forward to 25%, 15 sec progression', 1, 1, NULL, 1, 25, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(3, 'Forward stop, 10 sec progression', 1, 1, NULL, 1, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(4, 'Reverse to 80%, 15 sec progression', 1, 1, NULL, 0, 80, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(5, 'Reverse to 25%, 15 sec progrssion', 1, 1, NULL, 0, 25, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(6, 'Reverse stop, 10 sec progrssion', 1, 1, NULL, 0, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(7, 'Cab light, white 100%, 5 sec fade', 6, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 255, 255, 255, 5, NULL),
(8, 'Cab light, purple 100%, 5 sec fade', 6, 4, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 255, 0, 255, 5, NULL),
(9, 'Forward to 75%, 10 sec progression', 1, 4, NULL, 1, 75, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(10, 'Forward stop, 10 sec progression', 1, 4, NULL, 1, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(11, 'Reverse to 75%, 10 sec progression', 1, 4, NULL, 0, 75, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(12, 'Reverse stop, 10 sec progrssion', 1, 4, NULL, 0, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(14, 'Forward 1600, 1/8 Step, 50% Speed', 2, 2, NULL, 1, 50, NULL, NULL, 1600, 4, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(15, 'Forward 3200, 1/16 Step, 75% Speed', 2, 2, NULL, 1, 75, NULL, NULL, 3200, 5, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(16, 'Forward 6400, 1/32 Step, 100% Speed', 2, 2, NULL, 1, 100, NULL, NULL, 6400, 6, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(17, 'Reverse 1600, 1/8 Step, 50% Speed', 2, 2, NULL, 0, 50, NULL, NULL, 1600, 4, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(18, 'Reverse 3200, 1/16 Step, 75% Speed', 2, 2, NULL, 0, 75, NULL, NULL, 3200, 5, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(19, 'Reverse 6400, 1/32 Step, 100% Speed', 2, 2, NULL, 0, 100, NULL, NULL, 6400, 6, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(20, 'Port 0 On', 5, 3, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(21, 'Port 0 Off', 5, 3, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(22, 'Run The Plasma Scene', 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, 9),
(23, 'Run The Lava Scene', 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, 4),
(24, 'Set all LEDs on 100%', 6, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 65535, 255, 255, 255, 0, NULL),
(25, 'Set all LEDs off', 6, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 65535, 0, 0, 0, 0, NULL),
(26, 'Forward to 45%, 10 sec progression, 30 sec runtime', 1, 4, NULL, 1, 45, 30, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(27, 'Reverse to 45%, 10 sec progression, 30 sec runtime', 1, 4, NULL, 0, 45, 30, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `devices`
--

CREATE TABLE `devices` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) NOT NULL DEFAULT '00-00-00-00-00-00',
  `dev_name` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `signal_level` varchar(255) NOT NULL DEFAULT 'Unknown',
  `dev_type` tinyint(4) DEFAULT NULL,
  `last_loc` int(11) DEFAULT 0,
  `favorites` text DEFAULT NULL,
  `replay` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `devices`
--

INSERT INTO `devices` (`ID`, `address`, `dev_name`, `status`, `signal_level`, `dev_type`, `last_loc`, `favorites`, `replay`) VALUES
(1, '44-bd-8d-ee-81-34', '1-Brushed Motor Controller', 'cmd://reboot', '<span class=\"text-info\">-63 dBm</span>', 1, 1000, '3|2|1|6|5|4', 1),
(2, 'e4-b3-23-f8-0d-2c', '4-Switching Controller', 'cmd://reboot', '<span class=\"text-info\">-12 dBm</span>', 3, 0, '21|20|23|22|25|24', 1),
(3, '44-b1-76-b0-df-e4', '3-Stepper Motor Controller', 'cmd://reboot', '<span class=\"text-info\">-25 dBm</span>', 2, 0, '14|15|16|17|18|19', 1),
(4, '44-bd-8d-ee-80-24', '2-Model Train Locomotive', 'cmd://reboot', '<span class=\"text-info\">-71 dBm</span>', 4, 1000, '8|7|10|9|12|11', 1);

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
(1, 'Location transponder #1000', 1000);

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

-- --------------------------------------------------------

--
-- Table structure for table `scenes`
--

CREATE TABLE `scenes` (
  `ID` int(11) NOT NULL,
  `scn_name` varchar(255) DEFAULT NULL,
  `source` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scenes`
--

INSERT INTO `scenes` (`ID`, `scn_name`, `source`) VALUES
(1, 'Rainbow', '10 H = 0\r\n100 P = 0\r\n110 C = H + P * 256 / PIXEL\r\n120 SET_HSV P , C , 255 , 170\r\n\r\n130 S = RND 0 , 14\r\n140 IF S == 0 THEN SET P , 255 , 255 , 220\r\n\r\n150 P = P + 1\r\n160 IF P <= PIXEL THEN GOTO 110\r\n\r\n170 WAIT 25\r\n180 H = H + 4\r\n190 IF H > 255 THEN H = H - 256\r\n200 GOTO 100'),
(2, 'Comet', '10 H = 0\r\n20 P = 0\r\n\r\n30 CLEAR\r\n40 V = 160\r\n\r\n50 FOR T = 1 TO 8\r\n60   Q = P - T\r\n70   IF Q >= 0 THEN SET_HSV Q , H , 255 , V\r\n80   V = V * 3 / 4\r\n90 NEXT T\r\n\r\n100 SET P , 255 , 255 , 255\r\n110 WAIT 25\r\n\r\n120 P = P + 1\r\n130 IF P <= PIXEL THEN GOTO 30\r\n\r\n140 CLEAR\r\n150 WAIT 200\r\n160 H = H + 40\r\n170 IF H > 255 THEN H = H - 256\r\n180 GOTO 20'),
(3, 'Pendulum', '10 H = 0\r\n\r\n20 FOR I = 0 TO PIXEL\r\n30   IF I > 0 THEN SET I - 1 , 0 , 0 , 0\r\n40   SET_HSV I , H , 255 , 255\r\n50   WAIT 35\r\n60 NEXT I\r\n\r\n70 FOR I = PIXEL TO 0 STEP -1\r\n80   IF I < PIXEL THEN SET I + 1 , 0 , 0 , 0\r\n90   SET_HSV I , H , 255 , 255\r\n100  WAIT 35\r\n110 NEXT I\r\n\r\n120 H = H + 30\r\n130 IF H > 255 THEN H = H - 256\r\n140 GOTO 20'),
(4, 'Lava', '10 T = 0\r\n20 FOR I = 0 TO PIXEL\r\n30   X = I * 25\r\n40   N = NOISE X , T\r\n50   U = X * 4\r\n60   N = N * 3 + NOISE U , T * 3\r\n70   N = N / 4\r\n80   H = MAP N , 0 , 255 , 0 , 30\r\n90   N = CONSTRAIN N , 0 , 255\r\n100  V = EXP8 N\r\n110  SET_HSV I , H , 255 , V\r\n120 NEXT I\r\n130 WAIT 25\r\n140 T = T + 5\r\n150 IF T > 32000 THEN T = 0\r\n160 GOTO 20'),
(5, 'Ants', '10 Z = 0\r\n11 H = 160\r\n\r\n20 FOR I = 0 TO PIXEL\r\n30   R = I + Z\r\n40   R = R % 8\r\n50   IF R < 4 THEN SET_HSV I , H , 255 , 200\r\n60   IF R >= 4 THEN SET I , 12 , 12 , 12\r\n70 NEXT I\r\n80 WAIT 80\r\n\r\n90 Z = Z + 1\r\n100 IF Z > 7 THEN Z = 0\r\n\r\n110 H = H + 1\r\n120 IF H > 255 THEN H = 0\r\n130 GOTO 20'),
(6, 'Sunset', '10 X = 0\r\n20 B = 255\r\n30 W = 70\r\n\r\n100 P = 0\r\n110 D = X - P\r\n120 IF D < 0 THEN D = P - X\r\n\r\n130 IF D == 0 THEN SET P , B , B , B\r\n131 IF D == 0 THEN GOTO 220\r\n140 IF D == 1 THEN SET P , B , B / 4 * 3 , 0\r\n141 IF D == 1 THEN GOTO 220\r\n150 IF D == 2 THEN SET P , B , B / 3 , 0\r\n151 IF D == 2 THEN GOTO 220\r\n160 IF D == 3 THEN SET P , B , B / 6 , 0\r\n161 IF D == 3 THEN GOTO 220\r\n170 IF D == 4 THEN SET P , B / 2 , 0 , 0\r\n171 IF D == 4 THEN GOTO 220\r\n180 SET P , W / 4 , 0 , W\r\n\r\n220 P = P + 1\r\n230 IF P <= PIXEL THEN GOTO 110\r\n240 WAIT 160\r\n\r\n250 X = X + 1\r\n260 IF X > PIXEL * 3 / 4 THEN B = B - 8\r\n270 IF B < 0 THEN B = 0\r\n280 IF X > PIXEL * 2 / 3 THEN W = W - 2\r\n290 IF W < 3 THEN W = 3\r\n300 IF X <= PIXEL THEN GOTO 100\r\n\r\n400 P = 0\r\n410 SET P , W / 4 , 0 , W\r\n420 P = P + 1\r\n430 IF P <= PIXEL THEN GOTO 410\r\n440 WAIT 80\r\n450 W = W - 3\r\n460 IF W > 0 THEN GOTO 400\r\n\r\n470 CLEAR\r\n480 WAIT 1200\r\n490 GOTO 10'),
(7, 'Police', '10 Z = 0\r\n20 FOR P = 0 TO PIXEL\r\n30   IF P <= PIXEL / 2 THEN GOSUB 200\r\n40   IF P > PIXEL / 2  THEN GOSUB 300\r\n50 NEXT P\r\n60 WAIT 120\r\n70 Z = Z + 1\r\n80 IF Z > 1 THEN Z = 0\r\n90 GOTO 20\r\n200 IF Z == 0 THEN SET P , 0 , 0 , 255\r\n201 IF Z == 1 THEN SET P , 255 , 0 , 0\r\n202 RETURN\r\n300 IF Z == 0 THEN SET P , 255 , 0 , 0\r\n301 IF Z == 1 THEN SET P , 0 , 0 , 255\r\n302 RETURN'),
(8, 'Breathe', '10 T = 0\r\n20 V = SIN8 T\r\n30 FILL 180 , 60 , V\r\n40 WAIT 14\r\n50 T = T + 2\r\n60 IF T > 255 THEN T = T - 256\r\n70 GOTO 20'),
(9, 'Plasma', '10 T = 0\r\n20 FOR I = 0 TO PIXEL\r\n30   X = I % 16\r\n40   Y = I / 16\r\n50   X = X * 16\r\n60   Y = Y * 16\r\n70   A = X + T\r\n80   A = A % 256\r\n90   H = SIN8 A\r\n100  B = Y + 256 - T\r\n110  B = B % 256\r\n120  S = COS8 B\r\n130  H = H + S\r\n140  C = X + Y + T\r\n150  C = C % 256\r\n160  S = SIN8 C\r\n170  H = H + S\r\n180  H = H / 3\r\n190  SET_HSV I , H , 255 , 255\r\n200 NEXT I\r\n210 WAIT 25\r\n220 T = T + 3\r\n230 IF T > 255 THEN T = T - 256\r\n240 GOTO 20'),
(10, 'Noise', '10 T = 0\r\n20 FOR I = 0 TO PIXEL\r\n30   X = I * 32\r\n40   V = NOISE X , T\r\n50   H = V / 4\r\n60   SET_HSV I , H , 255 , V\r\n70 NEXT I\r\n80 WAIT 20\r\n90 T = T + 10\r\n100 GOTO 20');

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
(1, '44-bd-8d-ee-81-34', 'Scheduled Task Test #1', 12, 15, '1|1|1|1|1|1|1', '2026-10-31 18:19:56', 0, 1),
(2, '00-00-00-00-00-00', 'Scheduled Task Test #2', 9, 15, '0|1|1|1|1|1|0', '2026-10-30 19:18:50', 0, 1);

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
(1, 'Command Script Test #1', 1, 1, 2, '1|2|3'),
(2, 'Command Script Test #2', 1, 0, 0, '4|5|6'),
(3, 'Command Script Test #3', 4, 1, 4, '26|9|10'),
(4, 'Command Script Test #4', 4, 0, 0, '27|11|12');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `ID` int(11) NOT NULL,
  `ssid` varchar(32) DEFAULT NULL,
  `wifi_pw` varchar(32) DEFAULT NULL,
  `usb_device` varchar(255) DEFAULT NULL,
  `sound_server` varchar(17) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`ID`, `ssid`, `wifi_pw`, `usb_device`, `sound_server`) VALUES
(1, 'LCC-WLAN', '1a2b3c4d5e', '/dev/ttyACM0', '54-78-c9-3e-a4-0a');

-- --------------------------------------------------------

--
-- Table structure for table `timeline`
--

CREATE TABLE `timeline` (
  `ID` int(11) NOT NULL,
  `cmd_name` varchar(255) DEFAULT NULL,
  `address` varchar(17) DEFAULT NULL,
  `position` float DEFAULT NULL,
  `disabled` tinyint(4) NOT NULL DEFAULT 0,
  `cmd_type` tinyint(4) DEFAULT NULL,
  `gpio_pin` tinyint(4) DEFAULT NULL,
  `direction` tinyint(4) DEFAULT NULL,
  `speed` tinyint(4) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `progression` int(11) DEFAULT NULL,
  `steps` int(11) DEFAULT NULL,
  `resolution` tinyint(4) DEFAULT NULL,
  `sound` int(11) DEFAULT NULL,
  `volume` tinyint(4) NOT NULL DEFAULT 25,
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
-- Dumping data for table `timeline`
--

INSERT INTO `timeline` (`ID`, `cmd_name`, `address`, `position`, `disabled`, `cmd_type`, `gpio_pin`, `direction`, `speed`, `duration`, `progression`, `steps`, `resolution`, `sound`, `volume`, `replay`, `location_id`, `location_action`, `location_data`, `light`, `red`, `green`, `blue`, `fade`, `scene`) VALUES
(1, 'Motor test 1', '44-bd-8d-ee-81-34', 0, 0, 1, 0, 1, 50, 13, 5, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(2, 'Stepper test 1', '44-b1-76-b0-df-e4', 0, 0, 2, 0, 1, 50, 0, 0, 1600, 4, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(3, 'Sound test 1', '44-bd-8d-ee-81-34', 5, 0, 4, 0, 1, 0, 0, 0, 0, 1, 7, 30, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(4, 'Scene test 1', '44-bd-8d-ee-80-24', 5, 0, 7, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 7),
(5, 'Switching test 2', 'e4-b3-23-f8-0d-2c', 5, 0, 5, 1, 1, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(6, 'Switching test 4', 'e4-b3-23-f8-0d-2c', 15, 0, 5, 1, 0, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(7, 'Lights Out', '44-bd-8d-ee-80-24', 15, 0, 6, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 65535, 0, 0, 0, 1, 0),
(8, 'Location test 1', '44-bd-8d-ee-81-34', 8, 0, 3, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 1000, 5, 0, 0, 0, 0, 0, 1, 0),
(10, 'Location test 2', '44-bd-8d-ee-81-34', 11.5, 0, 3, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 1000, 5, 0, 0, 0, 0, 0, 1, 0),
(11, 'Stepper test 2', '44-b1-76-b0-df-e4', 5, 0, 2, 0, 0, 50, 0, 0, 1600, 4, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(12, 'Motor test 2', '44-bd-8d-ee-80-24', 0, 0, 1, 0, 1, 80, 15, 5, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(13, 'Switching test 1', 'e4-b3-23-f8-0d-2c', 0, 0, 5, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(14, 'Switching test 3', 'e4-b3-23-f8-0d-2c', 10, 0, 5, 0, 0, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(15, 'Location test 3', '44-bd-8d-ee-81-34', 15, 0, 3, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 1000, 2, 5, 0, 0, 0, 0, 1, 0),
(16, 'Scene test 2', '44-bd-8d-ee-80-24', 10, 0, 7, 0, 1, 0, 0, 0, 0, 1, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1),
(17, 'Stepper test 3', '44-b1-76-b0-df-e4', 10, 0, 2, 0, 1, 100, 0, 0, 6400, 6, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0),
(18, 'Stepper test 4', '44-b1-76-b0-df-e4', 15, 0, 2, 0, 0, 100, 0, 0, 6400, 6, 0, 25, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `timeline_queue`
--

CREATE TABLE `timeline_queue` (
  `ID` int(11) NOT NULL,
  `address` varchar(17) DEFAULT NULL,
  `msg` varchar(255) DEFAULT NULL,
  `creation` timestamp NULL DEFAULT current_timestamp(),
  `sent` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timeline_queue`
--

INSERT INTO `timeline_queue` (`ID`, `address`, `msg`, `creation`, `sent`) VALUES
(1, '44-bd-8d-ee-81-34', '/motor/1/50/5/13', '2026-10-31 22:48:57', 1),
(2, '44-b1-76-b0-df-e4', '/stepper/1/4/1600/50', '2026-10-31 22:48:57', 1),
(3, '44-bd-8d-ee-80-24', '/motor/1/80/5/15', '2026-10-31 22:48:57', 1),
(4, 'e4-b3-23-f8-0d-2c', '/switch/0/1', '2026-10-31 22:48:57', 1),
(5, '44-bd-8d-ee-81-34', '/sound/7/30/0', '2026-10-31 22:49:02', 1),
(6, '44-bd-8d-ee-80-24', '/scene/7', '2026-10-31 22:49:02', 1),
(7, 'e4-b3-23-f8-0d-2c', '/switch/1/1', '2026-10-31 22:49:02', 1),
(8, '44-b1-76-b0-df-e4', '/stepper/0/4/1600/50', '2026-10-31 22:49:02', 1),
(9, '44-bd-8d-ee-81-34', '/location/1000/5/0', '2026-10-31 22:49:05', 1),
(10, 'e4-b3-23-f8-0d-2c', '/switch/0/0', '2026-10-31 22:49:07', 1),
(11, '44-bd-8d-ee-80-24', '/scene/1', '2026-10-31 22:49:07', 1),
(12, '44-b1-76-b0-df-e4', '/stepper/1/6/6400/100', '2026-10-31 22:49:07', 1),
(13, '44-bd-8d-ee-81-34', '/location/1000/5/0', '2026-10-31 22:49:08', 1),
(14, 'e4-b3-23-f8-0d-2c', '/switch/1/0', '2026-10-31 22:49:12', 1),
(15, '44-bd-8d-ee-80-24', '/light/65535/0/0/0/1', '2026-10-31 22:49:12', 1),
(16, '44-bd-8d-ee-81-34', '/location/1000/2/5', '2026-10-31 22:49:12', 1),
(17, '44-b1-76-b0-df-e4', '/stepper/0/6/6400/100', '2026-10-31 22:49:12', 1);

-- --------------------------------------------------------

--
-- Table structure for table `timeline_scripts`
--

CREATE TABLE `timeline_scripts` (
  `ID` int(11) NOT NULL,
  `scr_name` varchar(255) DEFAULT NULL,
  `last_update` timestamp NULL DEFAULT NULL,
  `script_sql` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `timeline_scripts`
--

INSERT INTO `timeline_scripts` (`ID`, `scr_name`, `last_update`, `script_sql`) VALUES
(1, 'My Test Timeline', '2026-10-31 19:31:23', '/*M!999999\\- enable the sandbox mode */ \n-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (aarch64)\n--\n-- Host: localhost    Database: LCC\n-- ------------------------------------------------------\n-- Server version	11.8.6-MariaDB-0+deb13u1 from Debian\n\n/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;\n/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;\n/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;\n/*!40101 SET NAMES utf8mb4 */;\n/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;\n/*!40103 SET TIME_ZONE=\'+00:00\' */;\n/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;\n/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;\n/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=\'NO_AUTO_VALUE_ON_ZERO\' */;\n/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;\n\n--\n-- Table structure for table `timeline`\n--\n\nDROP TABLE IF EXISTS `timeline`;\n/*!40101 SET @saved_cs_client     = @@character_set_client */;\n/*!40101 SET character_set_client = utf8mb4 */;\nCREATE TABLE `timeline` (\n  `ID` int(11) NOT NULL AUTO_INCREMENT,\n  `cmd_name` varchar(255) DEFAULT NULL,\n  `address` varchar(17) DEFAULT NULL,\n  `position` float DEFAULT NULL,\n  `disabled` tinyint(4) NOT NULL DEFAULT 0,\n  `cmd_type` tinyint(4) DEFAULT NULL,\n  `gpio_pin` tinyint(4) DEFAULT NULL,\n  `direction` tinyint(4) DEFAULT NULL,\n  `speed` tinyint(4) DEFAULT NULL,\n  `duration` int(11) DEFAULT NULL,\n  `progression` int(11) DEFAULT NULL,\n  `steps` int(11) DEFAULT NULL,\n  `resolution` tinyint(4) DEFAULT NULL,\n  `sound` int(11) DEFAULT NULL,\n  `volume` tinyint(4) NOT NULL DEFAULT 25,\n  `replay` tinyint(4) DEFAULT 0,\n  `location_id` int(11) DEFAULT NULL,\n  `location_action` int(11) DEFAULT NULL,\n  `location_data` int(11) DEFAULT NULL,\n  `light` int(11) NOT NULL DEFAULT 0,\n  `red` int(11) NOT NULL DEFAULT 0,\n  `green` int(11) NOT NULL DEFAULT 0,\n  `blue` int(11) NOT NULL DEFAULT 0,\n  `fade` float NOT NULL DEFAULT 1,\n  `scene` int(11) DEFAULT NULL,\n  PRIMARY KEY (`ID`)\n) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;\n/*!40101 SET character_set_client = @saved_cs_client */;\n\n--\n-- Dumping data for table `timeline`\n--\n\nSET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;\nLOCK TABLES `timeline` WRITE;\n/*!40000 ALTER TABLE `timeline` DISABLE KEYS */;\nINSERT INTO `timeline` VALUES\n(1,\'Motor test 1\',\'44-bd-8d-ee-81-34\',0,0,1,0,1,50,13,5,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(2,\'Stepper test 1\',\'44-b1-76-b0-df-e4\',0,0,2,0,1,50,0,0,1600,4,0,25,0,0,1,0,0,0,0,0,1,0),\n(3,\'Sound test 1\',\'44-bd-8d-ee-81-34\',5,0,4,0,1,0,0,0,0,1,7,30,0,0,1,0,0,0,0,0,1,0),\n(4,\'Scene test 1\',\'44-bd-8d-ee-80-24\',5,0,7,0,1,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,7),\n(5,\'Switching test 2\',\'e4-b3-23-f8-0d-2c\',5,0,5,1,1,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(6,\'Switching test 4\',\'e4-b3-23-f8-0d-2c\',15,0,5,1,0,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(7,\'Lights Out\',\'44-bd-8d-ee-80-24\',15,0,6,0,1,0,0,0,0,1,0,25,0,0,1,0,65535,0,0,0,1,0),\n(8,\'Location test 1\',\'44-bd-8d-ee-81-34\',8,0,3,0,1,0,0,0,0,1,0,25,0,1000,5,0,0,0,0,0,1,0),\n(10,\'Location test 2\',\'44-bd-8d-ee-81-34\',11.5,0,3,0,1,0,0,0,0,1,0,25,0,1000,5,0,0,0,0,0,1,0),\n(11,\'Stepper test 2\',\'44-b1-76-b0-df-e4\',5,0,2,0,0,50,0,0,1600,4,0,25,0,0,1,0,0,0,0,0,1,0),\n(12,\'Motor test 2\',\'44-bd-8d-ee-80-24\',0,0,1,0,1,80,15,5,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(13,\'Switching test 1\',\'e4-b3-23-f8-0d-2c\',0,0,5,0,1,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(14,\'Switching test 3\',\'e4-b3-23-f8-0d-2c\',10,0,5,0,0,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,0),\n(15,\'Location test 3\',\'44-bd-8d-ee-81-34\',15,0,3,0,1,0,0,0,0,1,0,25,0,1000,2,5,0,0,0,0,1,0),\n(16,\'Scene test 2\',\'44-bd-8d-ee-80-24\',10,0,7,0,1,0,0,0,0,1,0,25,0,0,1,0,0,0,0,0,1,1),\n(17,\'Stepper test 3\',\'44-b1-76-b0-df-e4\',10,0,2,0,1,100,0,0,6400,6,0,25,0,0,1,0,0,0,0,0,1,0),\n(18,\'Stepper test 4\',\'44-b1-76-b0-df-e4\',15,0,2,0,0,100,0,0,6400,6,0,25,0,0,1,0,0,0,0,0,1,0);\n/*!40000 ALTER TABLE `timeline` ENABLE KEYS */;\nUNLOCK TABLES;\nCOMMIT;\nSET AUTOCOMMIT=@OLD_AUTOCOMMIT;\n/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;\n\n/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;\n/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;\n/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;\n/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;\n/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;\n/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;\n/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;\n\n-- Dump completed on 2026-10-31 13:31:22\n');

-- --------------------------------------------------------

--
-- Table structure for table `timeline_status`
--

CREATE TABLE `timeline_status` (
  `ID` int(11) NOT NULL,
  `current_script` int(11) NOT NULL DEFAULT 0,
  `load_save` tinyint(4) NOT NULL DEFAULT 0,
  `script_modified` tinyint(4) NOT NULL DEFAULT 0,
  `running` tinyint(4) NOT NULL DEFAULT 0,
  `position` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

--
-- Dumping data for table `timeline_status`
--

INSERT INTO `timeline_status` (`ID`, `current_script`, `load_save`, `script_modified`, `running`, `position`) VALUES
(1, 1, 0, 0, 0, 0);

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
  `started` tinyint(4) NOT NULL DEFAULT 0,
  `stop_command` int(11) NOT NULL DEFAULT 0,
  `stopped` tinyint(4) NOT NULL DEFAULT 0
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
-- Indexes for table `timeline`
--
ALTER TABLE `timeline`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `timeline_queue`
--
ALTER TABLE `timeline_queue`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `timeline_scripts`
--
ALTER TABLE `timeline_scripts`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `timeline_status`
--
ALTER TABLE `timeline_status`
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
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `devices`
--
ALTER TABLE `devices`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `inbound`
--
ALTER TABLE `inbound`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

--
-- AUTO_INCREMENT for table `locations`
--
ALTER TABLE `locations`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `outbound`
--
ALTER TABLE `outbound`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

--
-- AUTO_INCREMENT for table `scenes`
--
ALTER TABLE `scenes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `schedule`
--
ALTER TABLE `schedule`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `scripts`
--
ALTER TABLE `scripts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `timeline`
--
ALTER TABLE `timeline`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `timeline_queue`
--
ALTER TABLE `timeline_queue`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `timeline_scripts`
--
ALTER TABLE `timeline_scripts`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `timeline_status`
--
ALTER TABLE `timeline_status`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `timer`
--
ALTER TABLE `timer`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;

COMMIT;
