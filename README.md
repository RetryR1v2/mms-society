# mms-society

- Society System for VorpCore

# Features

- Create Jobs with /JobCreator  Only UserGroup Admin can Open jobcreator
- Manage your Job and Ranks if you are the Boss with /BossMenu or Open Boss Menu in your JobMenu
- Open Boss Menu
- Job Menu
- Sotarge
- Ledger
- Employer Management ( Only Boss )
- Rank Management ( Only Boss )
- If You Get a Job or Changed a Rank then it should Reload the Script data and Instatly give you the job Premissions without Relogging
- JobBills to CreateBills for your Job.
- Webhook ( Everything is Logged easy Support your Players there will be Errors aswell ) Barley Included

 
# Changelog

- Initial Release Version 1.1.0
- 1.1.1 Added Leave Job Option
- 1.1.2 Changed Invite Player Method from ClosestPlayer to PlayerID if More Players Next to you you cant Invite the wrong now.
- 1.1.3
- Added Employer Management
- Optimized Menu Code
- Optimized Rank Management you now see what the rank can do the Rights
- 1.1.4
- Added Bill System
- Create Company Bills
- Delete Created Bills if you Done a Mistake
- Payed Bills Money goes to Company Account
- Updated SQL File
- Updated Employer Management
- 1.1.5 Minor Bug Fix
- 1.1.6 Reworked JobCreator
- Added Fuction to Delete the Job from Database
- Carefull Deleting an Job Deletes All Ranks and Cleares the Storage and Created Bills.
- 1.1.7 
- Added Blip Management.
- Removed BossMenu Blip from Config.
- Option to Toggle Blip
- Everything can be set Ingame by Boss
- Blip Colors = BLIP_MODIFIER_MP_COLOR_1 - BLIP_MODIFIER_MP_COLOR_32

# installation 

- Run the SQL files to add Tables in your DB

- if You Update from Version 1.1.3 or Lower then Run SQL Code
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

- if you Update from 1.1.6 or Lower Run SQL code

ALTER TABLE `mms_society`
ADD COLUMN `blipactive` INT(11) NULL DEFAULT NULL,
ADD COLUMN `bliphash` VARCHAR(50) NULL DEFAULT 'Keiner' COLLATE 'utf8mb3_general_ci',
ADD COLUMN `blipname` VARCHAR(50) NULL DEFAULT 'Keiner' COLLATE 'utf8mb3_general_ci',
ADD COLUMN `blipcolor` VARCHAR(50) NULL DEFAULT 'Keiner' COLLATE 'utf8mb3_general_ci';


# Required
- Vorp_Core 
- Feather Menu by BCC
- bcc-utils


# CREDITS
- Discord https://discord.gg/Hua9DFXZYN
- https://github.com/RetryR1v2 