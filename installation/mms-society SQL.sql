CREATE TABLE `mms_society` (
	`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb3_general_ci',
	`label` VARCHAR(50) NOT NULL COLLATE 'utf8mb3_general_ci',
	`balance` FLOAT NOT NULL DEFAULT '0',
	`BossPosX` FLOAT NOT NULL DEFAULT '0',
	`BossPosY` FLOAT NOT NULL,
	`BossPosZ` FLOAT NOT NULL,
	`StoragePosX` FLOAT NOT NULL,
	`StoragePosY` FLOAT NOT NULL,
	`StoragePosZ` FLOAT NOT NULL,
	PRIMARY KEY (`name`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
;


CREATE TABLE `mms_society_ranks` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`ranklabel` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb3_general_ci',
	`rank` INT(11) NULL DEFAULT NULL,
	`isboss` INT(11) NULL DEFAULT NULL,
	`canwithdraw` INT(11) NULL DEFAULT NULL,
	`storageaccess` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=19
;


CREATE TABLE `mms_society_bills` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`fromchar` INT(11) NULL DEFAULT NULL,
	`fromname` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`tochar` INT(11) NULL DEFAULT NULL,
	`toname` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`reason` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`amount` FLOAT NULL DEFAULT NULL,
	`job` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	`joblabel` VARCHAR(50) NULL DEFAULT NULL COLLATE 'armscii8_general_ci',
	PRIMARY KEY (`id`) USING BTREE
)
COLLATE='armscii8_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=6
;
