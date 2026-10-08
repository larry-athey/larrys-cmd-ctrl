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
(1, 'Forward stop, 10 second progression', 1, 4, NULL, 1, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(2, 'Forward to 80%, 30 second progression', 1, 4, NULL, 1, 80, 0, 30, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(3, 'Reverse to 80%, 30 second progression', 1, 4, NULL, 0, 80, 0, 30, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(4, 'Forward to 25%, 15 second progression', 1, 4, NULL, 1, 25, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(5, 'Reverse to 25%, 15 second progression', 1, 4, NULL, 0, 25, 0, 15, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(6, 'Reverse stop, 10 second progression', 1, 4, NULL, 0, 0, 0, 10, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(128, 'Forward 25K, 1/8 Step Resolution', 2, 2, NULL, 1, NULL, NULL, NULL, 25000, 4, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(129, 'Reverse 25K, 1/8 Step Resolution', 2, 2, NULL, 0, NULL, NULL, NULL, 25000, 4, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(132, 'Port 0 On', 5, 3, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(133, 'Port 0 Off', 5, 3, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, NULL),
(134, 'Fixture 0, White, Full Brightness', 6, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 255, 255, 255, 1, NULL),
(135, 'Fixture 0, Purple, 50% Brightness', 6, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 127, 0, 127, 1, NULL),
(136, 'Show Fireworks Scene', 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, 4),
(137, 'Show Plasma Scene', 7, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 25, 0, NULL, NULL, NULL, 0, 0, 0, 0, 1, 9);

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
(1, 'e8-06-90-95-ef-90', '1-Model Train Locomotive', 'cmd://motor/1/0/10/0', '<span class=\"text-info\">-68 dBm</span>', 4, 16, '1|4|2', 1),
(2, '44-bd-8d-ee-81-34', '4-Switching Controller', 'cmd://scene/9', '<span class=\"text-info\">-56 dBm</span>', 3, 0, '136|137', 1),
(3, 'e4-b3-23-f8-0d-2c', '3-Stepper Motor Controller', '<span class=\"text-warning\">Runtime has ended</span>', '<span class=\"text-secondary\">Offline</span>', 2, 0, '128|129', 1),
(4, '44-bd-8d-ee-80-24', '2-Brushed Motor Controller', 'cmd://light/0/255/255/255/1', '<span class=\"text-info\">-17 dBm</span>', 1, 0, '135|134', 1);

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
(1, 'Outside track transponder 1', 1234);

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

--
-- Dumping data for table `scenes`
--

INSERT INTO `scenes` (`ID`, `scn_name`, `source`) VALUES
(1, 'Rainbow', '10 H = 0\r\n100 P = 0\r\n110 C = H + P * 256 / PIXEL\r\n120 SET_HSV P , C , 255 , 170\r\n\r\n130 S = RND 0 , 14\r\n140 IF S == 0 THEN SET P , 255 , 255 , 220\r\n\r\n150 P = P + 1\r\n160 IF P <= PIXEL THEN GOTO 110\r\n\r\n170 WAIT 25\r\n180 H = H + 4\r\n190 IF H > 255 THEN H = H - 256\r\n200 GOTO 100'),
(2, 'Comet', '10 H = 0\r\n20 P = 0\r\n\r\n30 CLEAR\r\n40 V = 160\r\n\r\n50 FOR T = 1 TO 8\r\n60   Q = P - T\r\n70   IF Q >= 0 THEN SET_HSV Q , H , 255 , V\r\n80   V = V * 3 / 4\r\n90 NEXT T\r\n\r\n100 SET P , 255 , 255 , 255\r\n110 WAIT 25\r\n\r\n120 P = P + 1\r\n130 IF P <= PIXEL THEN GOTO 30\r\n\r\n140 CLEAR\r\n150 WAIT 200\r\n160 H = H + 40\r\n170 IF H > 255 THEN H = H - 256\r\n180 GOTO 20'),
(3, 'Fire', '10 I = RND 0 , 7\r\n11 J = RND 0 , 7\r\n12 K = RND 0 , 7\r\n13 L = RND 0 , 7\r\n14 N = RND 0 , 7\r\n15 O = RND 0 , 7\r\n16 Q = RND 0 , 7\r\n17 R = RND 0 , 7\r\n18 A = RND 180 , 255\r\n19 B = RND 180 , 255\r\n20 C = RND 180 , 255\r\n21 D = RND 180 , 255\r\n22 E = RND 180 , 255\r\n23 F = RND 180 , 255\r\n24 G = RND 180 , 255\r\n25 H = RND 180 , 255\r\n\r\n100 CLEAR\r\n110 V = A\r\n111 P = I\r\n112 GOSUB 600\r\n120 V = B\r\n121 P = J\r\n122 GOSUB 600\r\n130 V = C\r\n131 P = K\r\n132 GOSUB 600\r\n140 V = D\r\n141 P = L\r\n142 GOSUB 600\r\n150 V = E\r\n151 P = N\r\n152 GOSUB 600\r\n160 V = F\r\n161 P = O\r\n162 GOSUB 600\r\n170 V = G\r\n171 P = Q\r\n172 GOSUB 600\r\n180 V = H\r\n181 P = R\r\n182 GOSUB 600\r\n200 I = I + 1\r\n201 J = J + 1\r\n202 K = K + 1\r\n203 L = L + 1\r\n204 N = N + 1\r\n205 O = O + 1\r\n206 Q = Q + 1\r\n207 R = R + 1\r\n210 A = A - RND 5 , 20\r\n211 B = B - RND 5 , 20\r\n212 C = C - RND 5 , 20\r\n213 D = D - RND 5 , 20\r\n214 E = E - RND 5 , 20\r\n215 F = F - RND 5 , 20\r\n216 G = G - RND 5 , 20\r\n217 H = H - RND 5 , 20\r\n220 IF A <= 0 THEN GOSUB 700\r\n221 IF I > 59 THEN GOSUB 700\r\n230 IF B <= 0 THEN GOSUB 710\r\n231 IF J > 59 THEN GOSUB 710\r\n240 IF C <= 0 THEN GOSUB 720\r\n241 IF K > 59 THEN GOSUB 720\r\n250 IF D <= 0 THEN GOSUB 730\r\n251 IF L > 59 THEN GOSUB 730\r\n260 IF E <= 0 THEN GOSUB 740\r\n261 IF N > 59 THEN GOSUB 740\r\n270 IF F <= 0 THEN GOSUB 750\r\n271 IF O > 59 THEN GOSUB 750\r\n280 IF G <= 0 THEN GOSUB 760\r\n281 IF Q > 59 THEN GOSUB 760\r\n290 IF H <= 0 THEN GOSUB 770\r\n291 IF R > 59 THEN GOSUB 770\r\n300 WAIT 30\r\n310 GOTO 100\r\n\r\n600 IF V <= 0 THEN RETURN\r\n601 IF P > 59  THEN RETURN\r\n602 IF P < 0   THEN RETURN\r\n610 IF V > 200 THEN SET P , 255 , 255 , 255\r\n611 IF V > 200 THEN RETURN\r\n620 IF V > 160 THEN SET P , 255 , V , 0\r\n621 IF V > 160 THEN RETURN\r\n630 IF V > 100 THEN SET P , 255 , V / 4 , 0\r\n631 IF V > 100 THEN RETURN\r\n640 IF V > 40  THEN SET P , V , 0 , 0\r\n650 RETURN\r\n700 I = RND 0 , 7\r\n701 A = RND 200 , 255\r\n702 RETURN\r\n710 J = RND 0 , 7\r\n711 B = RND 200 , 255\r\n712 RETURN\r\n720 K = RND 0 , 7\r\n721 C = RND 200 , 255\r\n722 RETURN\r\n730 L = RND 0 , 7\r\n731 D = RND 200 , 255\r\n732 RETURN\r\n740 N = RND 0 , 7\r\n741 E = RND 200 , 255\r\n742 RETURN\r\n750 O = RND 0 , 7\r\n751 F = RND 200 , 255\r\n752 RETURN\r\n760 Q = RND 0 , 7\r\n761 G = RND 200 , 255\r\n762 RETURN\r\n770 R = RND 0 , 7\r\n771 H = RND 200 , 255\r\n772 RETURN'),
(4, 'Fireworks', '10 GOSUB 900\r\n100 CLEAR\r\n110 V = A\r\n111 W = F\r\n112 GOSUB 800\r\n120 V = B\r\n121 W = G\r\n122 GOSUB 800\r\n130 V = C\r\n131 W = H\r\n132 GOSUB 800\r\n140 V = D\r\n141 W = I\r\n142 GOSUB 800\r\n150 V = E\r\n151 W = J\r\n152 GOSUB 800\r\n\r\n160 WAIT 25\r\n200 A = A - 6\r\n201 B = B - 7\r\n202 C = C - 5\r\n203 D = D - 8\r\n204 E = E - 6\r\n210 IF A <= 0 THEN GOSUB 910\r\n220 IF B <= 0 THEN GOSUB 920\r\n230 IF C <= 0 THEN GOSUB 930\r\n240 IF D <= 0 THEN GOSUB 940\r\n250 IF E <= 0 THEN GOSUB 950\r\n260 GOTO 100\r\n800 IF V <= 0 THEN RETURN\r\n801 IF W < 0   THEN RETURN\r\n802 IF W > PIXEL THEN RETURN\r\n810 IF V > 180 THEN SET W , 255 , 255 , 255\r\n811 IF V > 180 THEN RETURN\r\n820 SET_HSV W , X , 255 , V\r\n830 RETURN\r\n900 GOSUB 910\r\n901 GOSUB 920\r\n902 GOSUB 930\r\n903 GOSUB 940\r\n904 GOSUB 950\r\n905 RETURN\r\n\r\n910 F = RND 0 , PIXEL\r\n911 X = RND 0 , 255\r\n912 A = RND 200 , 255\r\n913 RETURN\r\n920 G = RND 0 , PIXEL\r\n921 X = RND 0 , 255\r\n922 B = RND 200 , 255\r\n923 RETURN\r\n930 H = RND 0 , PIXEL\r\n931 X = RND 0 , 255\r\n932 C = RND 200 , 255\r\n933 RETURN\r\n940 I = RND 0 , PIXEL\r\n941 X = RND 0 , 255\r\n942 D = RND 200 , 255\r\n943 RETURN\r\n950 J = RND 0 , PIXEL\r\n951 X = RND 0 , 255\r\n952 E = RND 200 , 255\r\n953 RETURN'),
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
  `usb_device` varchar(255) DEFAULT NULL,
  `sound_server` varchar(17) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`ID`, `usb_device`, sound_server) VALUES
(1, '/dev/ttyACM0', '00-00-00-00-00-00');

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
