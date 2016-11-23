-- phpMyAdmin SQL Dump
-- version 4.6.2
-- https://www.phpmyadmin.net/
--
-- Host: clustermysql04.hosteur.com
-- Generation Time: Jul 21, 2016 at 10:46 AM
-- Server version: 5.5.37
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `goupill`
--

-- --------------------------------------------------------

--
-- Table structure for table `connexionHistory`
--

CREATE TABLE `connexionHistory` (
  `id` int(11) NOT NULL,
  `idUser` int(11) NOT NULL,
  `date` date NOT NULL,
  `heure` time NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_assocFicheExercice`
--

CREATE TABLE `exo_assocEF` (
  `id` int(11) NOT NULL,
  `idE` varchar(6) NOT NULL,
  `options` text NOT NULL,
  `idFiche` int(11) NOT NULL,
  `num` int(11) NOT NULL,
  `coeff` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_assocUF`
--

CREATE TABLE `exo_assocUF` (
  `id` int(11) NOT NULL,
  `idUser` int(11) NOT NULL,
  `idFiche` int(11) NOT NULL,
  `actif` tinyint(1) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_assocUserExercice`
--

CREATE TABLE `exo_assocUE` (
  `id` int(11) NOT NULL,
  `aUF` int(11) NOT NULL COMMENT 'assoc User/Exercice',
  `aEF` int(11) NOT NULL COMMENT 'assoc Exo/Exercice',
  `date` datetime NOT NULL,
  `note` int(11) NOT NULL,
  `inputs` text NOT NULL,
  `answers` text NOT NULL,
  `finished` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_classes`
--

CREATE TABLE `exo_classes` (
  `id` int(11) NOT NULL,
  `nom` text NOT NULL,
  `description` text NOT NULL,
  `idOwner` int(11) NOT NULL,
  `pwd` text NOT NULL,
  `date` date NOT NULL,
  `ouverte` tinyint(1) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_exams`
--

CREATE TABLE `exo_exams` (
  `id` int(11) NOT NULL,
  `idFiche` int(11) NOT NULL,
  `nom` text NOT NULL,
  `date` date NOT NULL,
  `data` text NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `exo_fiches`
--

CREATE TABLE `exo_fiches` (
  `id` int(11) NOT NULL,
  `idOwner` int(11) NOT NULL,
  `nom` text CHARACTER SET utf8 NOT NULL,
  `description` text CHARACTER SET utf8 NOT NULL,
  `date` date NOT NULL,
  `visible` tinyint(1) NOT NULL,
  `actif` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `exo_initKeys`
--

CREATE TABLE `exo_initKeys` (
  `id` int(11) NOT NULL,
  `initKey` text CHARACTER SET utf8 NOT NULL,
  `idUser` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `exo_users`
--

CREATE TABLE `exo_users` (
  `id` int(11) NOT NULL,
  `nom` text NOT NULL,
  `prenom` text NOT NULL,
  `email` text NOT NULL,
  `rank` varchar(10) NOT NULL,
  `pwd` varchar(50) NOT NULL,
  `idClasse` int(11) DEFAULT NULL,
  `date` datetime NOT NULL,
  `locked` tinyint(1) NOT NULL DEFAULT '0',
  `trash` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `exo_users`
--

INSERT INTO `exo_users` (`id`, `nom`, `prenom`, `email`, `rank`, `pwd`, `idClasse`, `date`, `locked`, `trash`) VALUES
(1, 'Root', '', 'root', 'Root', 'b050bd35d8db6d2f514bccd4d0373052', 0, '2016-06-14 22:21:23', 0, 0);

-- --------------------------------------------------------

--
-- Indexes for dumped tables
--

--
-- Indexes for table `connexionHistory`
--
ALTER TABLE `connexionHistory`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_assocEF`
--
ALTER TABLE `exo_assocEF`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_assocUF`
--
ALTER TABLE `exo_assocUF`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_assocUE`
--
ALTER TABLE `exo_assocUE`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_classes`
--
ALTER TABLE `exo_classes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_exams`
--
ALTER TABLE `exo_exams`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_fiches`
--
ALTER TABLE `exo_fiches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_initKeys`
--
ALTER TABLE `exo_initKeys`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `exo_users`
--
ALTER TABLE `exo_users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for table `connexionHistory`
--
ALTER TABLE `connexionHistory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_assocEF`
--
ALTER TABLE `exo_assocEF`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_assocUF`
--
ALTER TABLE `exo_assocUF`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_assocUE`
--
ALTER TABLE `exo_assocUE`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_classes`
--
ALTER TABLE `exo_classes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_fiches`
--
ALTER TABLE `exo_fiches`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `exo_users`
--
ALTER TABLE `exo_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
