local VORPcore = exports.vorp_core:GetCore()

-- Events

AddEventHandler("vorp:playerJobGradeChange",function(source, newjobgrade,oldjobgrade)
    local src = source
    print('GradeChange')
    TriggerClientEvent('mms-society:client:updateplayerdata',src)
end)

AddEventHandler("vorp:playerJobChange", function(source, newjob,oldjob)
    local src = source
    print('JobChange')
    TriggerClientEvent('mms-society:client:updateplayerdata',src)
end)

---- Get Player Data

RegisterServerEvent('mms-society:server:getplayerdata',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local firstname = Character.firstname
    local lastname = Character.lastname
    local identifier = Character.identifier
    local charidentifier = Character.charIdentifier
    local job = Character.job
    local jobGrade = Character.jobGrade
    local jobLabel = Character.jobLabel
    local group = Character.group
    local societyjobs = MySQL.query.await("SELECT * FROM mms_society", {})
    local societyranks = MySQL.query.await("SELECT * FROM mms_society_ranks", {})
    TriggerClientEvent('mms-society:client:recieveuserdata',src,identifier,charidentifier,firstname,lastname,job,jobGrade,jobLabel,group,societyjobs,societyranks)
end)

---- CREATE JOB WITH JOBCREATOR

RegisterServerEvent('mms-society:server:createjob',function(jobname,joblabel,bossrank)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    if jobname ~= "" and joblabel ~= "" and bossrank ~= "" then
        local result = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = jobname})
        if #result > 0 then
            VORPcore.NotifyRightTip(src, _U('JobAlreadyExist') .. jobname .. ' ' .. joblabel,  5000)
            if Config.EnableWebHook then
                VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, _U('JobAlreadyExist') .. jobname .. ' ' .. joblabel, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
            end
        else
            MySQL.insert('INSERT INTO `mms_society` (name, label, balance,BossPosX,BossPosY,BossPosZ,StoragePosX,StoragePosY,StoragePosZ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {jobname,joblabel,0,0,0,0,0,0,0}, function()end)
            MySQL.insert('INSERT INTO `mms_society_ranks` (name, ranklabel, rank, isboss, canwithdraw, storageaccess) VALUES (?, ?, ?, ?, ?, ?)',
            {jobname,"Boss",bossrank,1,1,1}, function()end)
            VORPcore.NotifyRightTip(src, _U('JobCreated') .. jobname .. ' ' .. joblabel,  5000)
            if Config.EnableWebHook then
                VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, _U('JobCreated') .. jobname .. ' ' .. joblabel, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
            end
        end
    else
        VORPcore.NotifyRightTip(src, 'Wrong Input', 5000)
    end
end)

--- Set BossLocation
RegisterServerEvent('mms-society:server:setbosslocation',function(BossPosX,BossPosY,BossPosZ)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local result = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = job})
    if #result > 0 then
        MySQL.update('UPDATE `mms_society` SET BossPosX = ?  WHERE name = ?',{BossPosX, job})
        MySQL.update('UPDATE `mms_society` SET BossPosY = ?  WHERE name = ?',{BossPosY, job})
        MySQL.update('UPDATE `mms_society` SET BossPosZ = ?  WHERE name = ?',{BossPosZ, job})
        VORPcore.NotifyRightTip(src, _U('BossPositionSet'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('BossPositionSet'), Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
        TriggerClientEvent('mms-society:client:updateplayerdata',src)
    end
end)

--- Set Storage
RegisterServerEvent('mms-society:server:setstoragelocation',function(StoragePosX,StoragePosY,StoragePosZ)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local result = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["name"] = job})
    if #result > 0 then
        MySQL.update('UPDATE `mms_society` SET StoragePosX = ?  WHERE name = ?',{StoragePosX, job})
        MySQL.update('UPDATE `mms_society` SET StoragePosY = ?  WHERE name = ?',{StoragePosY, job})
        MySQL.update('UPDATE `mms_society` SET StoragePosZ = ?  WHERE name = ?',{StoragePosZ, job})
        VORPcore.NotifyRightTip(src, _U('StorageSet'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('StorageSet'), Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
        TriggerClientEvent('mms-society:client:updateplayerdata',src)
    end
end)

---- Create Rank

RegisterServerEvent('mms-society:server:bosscreaterank',function(InputRank,InputLabel,IsBoss,CanWithdraw,StorageAccess)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local jobGrade = Character.jobGrade
    local exists = false
    local InputRankNumber = tonumber(InputRank)
    local result = MySQL.query.await("SELECT * FROM mms_society_ranks WHERE name=@name", { ["name"] = job})
    for i,v in ipairs(result) do 
        if v.rank == InputRankNumber then
            exists = true
        end
    end
    if not exists then 
        MySQL.insert('INSERT INTO `mms_society_ranks` (name, ranklabel, rank, isboss, canwithdraw, storageaccess) VALUES (?, ?, ?, ?, ?, ?)',
        {job,InputLabel,InputRank,IsBoss,CanWithdraw,StorageAccess}, function()end)
        VORPcore.NotifyRightTip(src, _U('NewRankCreated'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, _U('NewRankCreated') .. ' ' .. InputRank .. ' ' .. InputLabel, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    else
        VORPcore.NotifyRightTip(src, _U('RankExistsAlready'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('RankExistsAlready'), Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    end
end)

-- Get Employers from DB

RegisterServerEvent('mms-society:server:GetEmployers',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local EmployerResult = MySQL.query.await("SELECT * FROM characters WHERE job=@job", { ["@job"] = job})
    if #EmployerResult > 0 then
        TriggerClientEvent('mms-society:client:ReciveEmployers',src,EmployerResult)
    end
end)

---- Get Ranks from DB

RegisterServerEvent('mms-society:server:getranks',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local jobGrade = Character.jobGrade
    local RankResult = MySQL.query.await("SELECT * FROM mms_society_ranks WHERE name=@name", { ["@name"] = job})
    if #RankResult > 0 then
        TriggerClientEvent('mms-society:client:reciveranks',src,RankResult)
    end
end)

-- Get Ledger from DB

RegisterServerEvent('mms-society:server:getledger',function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local jobGrade = Character.jobGrade
    local LedgerResult = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = job})
    if #LedgerResult > 0 then
        Balance = LedgerResult[1].balance
        TriggerClientEvent('mms-society:client:reciveledger',src,Balance)
    end
end)

--- Delete Rank

RegisterServerEvent('mms-society:server:bossdeleterank',function(InputRank)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local jobGrade = Character.jobGrade
    local NumberInputRank = tonumber(InputRank)
    if NumberInputRank == jobGrade then
        VORPcore.NotifyRightTip(src, _U('CantOwnRankDeleted') .. job .. ' ' .. InputRank,  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('CantOwnRankDeleted') .. job .. ' ' .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    else
        MySQL.execute('DELETE FROM mms_society_ranks WHERE rank = ?', { InputRank }, function()
        end)
        VORPcore.NotifyRightTip(src, _U('RankDeleted') .. job .. ' ' .. InputRank,  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('RankDeleted') .. job .. ' ' .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    end
end)

--- InvitePlayer

RegisterServerEvent('mms-society:server:InvitePlayer',function(InputRank,InputPlayerID)
    local src = source
    if InputRank ~= '' and InputPlayerID ~= '' then
        local Character = VORPcore.getUser(src).getUsedCharacter
        local job = Character.job
        local NumInputPID = tonumber(InputPlayerID)
        local NumInputRank = tonumber(InputRank)
        local firstname = Character.firstname
        local lastname = Character.lastname
        local RankLabel = ''
        local RankResult = MySQL.query.await("SELECT * FROM mms_society_ranks WHERE name=@name", { ["name"] = job})
        
        if #RankResult > 0 then
            for i,v in ipairs(RankResult) do
                if NumInputRank == v.rank then
                    RankLabel = v.ranklabel
                end
            end
        end

        local NewEmployerChar = VORPcore.getUser(NumInputPID).getUsedCharacter
        if NewEmployerChar ~= nil then
            local NewEmployerfirstname = NewEmployerChar.firstname
            local NewEmployerlastname = NewEmployerChar.lastname
            local NewEmployerCharidentifier = NewEmployerChar.charIdentifier
            
            VORPcore.NotifyRightTip(src, _U('PlayerInvited') .. NewEmployerfirstname .. ' ' .. NewEmployerlastname .. '!',  5000)
            VORPcore.NotifyRightTip(NumInputPID, _U('YouGotInvited') .. job .. _U('YourRank') .. InputRank .. '!',  5000)
            NewEmployerChar.setJob(job)
            NewEmployerChar.setJobGrade(NumInputRank)
            NewEmployerChar.setJobLabel(RankLabel)
            MySQL.update('UPDATE `characters` SET job = ? WHERE charidentifier = ?',{job, NewEmployerCharidentifier})
            MySQL.update('UPDATE `characters` SET joblabel = ? WHERE charidentifier = ?',{RankLabel, NewEmployerCharidentifier})
            MySQL.update('UPDATE `characters` SET jobgrade = ? WHERE charidentifier = ?',{NumInputRank, NewEmployerCharidentifier})
            Wait(250)
            TriggerClientEvent('mms-society:client:updateplayerdata',NumInputPID)
            if Config.EnableWebHook == true then
                VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, firstname .. ' ' .. lastname .. _U('Invited') .. NewEmployerfirstname .. ' ' .. NewEmployerlastname .. _U('Jobb') .. job .. _U('Rankk') .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
            end
        else
            VORPcore.NotifyRightTip(src, _U('PlayerNotFound'), 5000)
        end
    else
        VORPcore.NotifyRightTip(src, 'Wrong Input', 5000)
    end
end)


--- Access Storage 

RegisterServerEvent('mms-society:server:OpenStorage', function(job,jobLabel)
    local src = source
    local isregistred = exports.vorp_inventory:isCustomInventoryRegistered(job)
        if isregistred then
            exports.vorp_inventory:closeInventory(src, job)
            exports.vorp_inventory:openInventory(src, job)
        else
            exports.vorp_inventory:registerInventory(
            {
                id = job,
                name = jobLabel,
                limit = Config.StorageSize,
                acceptWeapons = true,
                shared = true,
                ignoreItemStackLimit = true,
            }
            )
            exports.vorp_inventory:openInventory(src, job)
            isregistred = exports.vorp_inventory:isCustomInventoryRegistered(job)
        end
end)

RegisterServerEvent('mms-society:server:Withdraw',function (InputAmount)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local ToNumberAmount = tonumber(InputAmount)
    local LedgerResult = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = job})
    if #LedgerResult > 0 then
        local OldBalance = LedgerResult[1].balance
        local NewBalance = OldBalance - ToNumberAmount
        if OldBalance >= ToNumberAmount then
            Character.addCurrency(0,ToNumberAmount)
            MySQL.update('UPDATE `mms_society` SET balance = ? WHERE name = ?',{NewBalance, job})
            VORPcore.NotifyRightTip(src, ToNumberAmount .. _U('Withdrawn'),  5000)
        else
            VORPcore.NotifyRightTip(src, _U('NotEnoghMoney'),  5000)
        end
    end
end)

RegisterServerEvent('mms-society:server:Deposit',function (InputAmount)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local ToNumberAmount = tonumber(InputAmount)
    local MyMoney = Character.money
    local LedgerResult = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = job})
    if #LedgerResult > 0 then
        local OldBalance = LedgerResult[1].balance
        local NewBalance = OldBalance + ToNumberAmount
        if MyMoney >= ToNumberAmount then
            Character.removeCurrency(0,ToNumberAmount)
            MySQL.update('UPDATE `mms_society` SET balance = ? WHERE name = ?',{NewBalance, job})
            VORPcore.NotifyRightTip(src, ToNumberAmount .. _U('Deposited'),  5000)
        else
            VORPcore.NotifyRightTip(src, _U('NotEnoghMoney'),  5000)
        end
    end
end)


-- LeaveJob

RegisterServerEvent('mms-society:server:LeaveJob', function ()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Job = Character.job
    Character.setJob(Config.DefaultJob)
    Character.setJobGrade(Config.DefaultGrade)
    Character.setJobLabel(Config.DefaultLabel)
    for h,v in ipairs(GetPlayers()) do
        local AllCharacters = VORPcore.getUser(v).getUsedCharacter
        local AllJob = AllCharacters.job
        if AllJob == Job then
            TriggerClientEvent('mms-society:client:updateplayerdata',v)
        end
    end
end)

-- UpRank Employer

RegisterServerEvent('mms-society:server:ChangeRank',function(InputID,InputNewRank)
    local src = source
    if InputID ~= "" and InputNewRank ~= "" then
        local CharID = tonumber(InputID)
        local NewRank = tonumber(InputNewRank)
        local GetEmployerData = MySQL.query.await("SELECT * FROM characters WHERE charidentifier=@charidentifier", { ["@charidentifier"] = CharID})
        if #GetEmployerData > 0 then
            MySQL.update('UPDATE `characters` SET jobgrade = ? WHERE charidentifier = ?',{NewRank, CharID})
            for h,v in ipairs(GetPlayers()) do
                local AllCharacters = VORPcore.getUser(v).getUsedCharacter
                local AllJob = AllCharacters.job
                if AllCharacters.charIdentifier == CharID then
                    AllCharacters.setJobGrade(NewRank)
                end
                if AllJob == CurrentJob then
                    TriggerClientEvent('mms-society:client:updateplayerdata',v)
                end
            end
            VORPcore.NotifyRightTip(src,_U('ChangeedRankEmployer'),5000)
        end
    else
        VORPcore.NotifyRightTip(src, 'Wrong Input', 5000)
    end
end)

RegisterServerEvent('mms-society:server:FireEmplyoer',function(InputID)
    local src = source
    if InputID ~= "" then
        local CharID = tonumber(InputID)
        local GetEmployerData = MySQL.query.await("SELECT * FROM characters WHERE charidentifier=@charidentifier", { ["@charidentifier"] = CharID})
        if #GetEmployerData > 0 then
            MySQL.update('UPDATE `characters` SET job = ? WHERE charidentifier = ?',{Config.DefaultJob, CharID})
            MySQL.update('UPDATE `characters` SET jobgrade = ? WHERE charidentifier = ?',{Config.DefaultGrade, CharID})
            MySQL.update('UPDATE `characters` SET joblabel = ? WHERE charidentifier = ?',{Config.DefaultLabel, CharID})
            for h,v in ipairs(GetPlayers()) do
                local AllCharacters = VORPcore.getUser(v).getUsedCharacter
                local AllJob = AllCharacters.job
                if AllCharacters.charIdentifier == CharID then
                    AllCharacters.setJob(Config.DefaultJob)
                    AllCharacters.setJobGrade(Config.DefaultGrade)
                    AllCharacters.setJobLabel(Config.DefaultLabel)
                end
                if AllJob == CurrentJob then
                    TriggerClientEvent('mms-society:client:updateplayerdata',v)
                end
            end
            VORPcore.NotifyRightTip(src,_U('FiredEmployer'),5000)
        end
    else
        VORPcore.NotifyRightTip(src, 'Wrong Input', 5000)
    end
end)


---- Create Bill

RegisterServerEvent('mms-society:server:CreateBill',function(BillReason,BillAmount,CustomerID)
    local src = source
    if BillReason ~= "" and BillAmount > 0 and CustomerID > 0 then
        local Sender = VORPcore.getUser(src).getUsedCharacter
        local SenderName = Sender.firstname .. ' ' .. Sender.lastname
        local SenderCharID = Sender.charIdentifier
        local SenderJob = Sender.job
        local SenderJobLabel = Sender.jobLabel
        local Customer = VORPcore.getUser(CustomerID).getUsedCharacter
        local CustomerName = Customer.firstname .. ' ' .. Customer.lastname
        local CustomerCharID = Customer.charIdentifier
        MySQL.insert('INSERT INTO `mms_society_bills` (fromchar, fromname, tochar, toname, reason, amount, job, joblabel) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        {SenderCharID,SenderName,CustomerCharID,CustomerName,BillReason,BillAmount,SenderJob,SenderJobLabel}, function()end)
        VORPcore.NotifyRightTip(src,_U('CreatedABill') .. CustomerName,5000)
        VORPcore.NotifyRightTip(CustomerID,_U('RecivedABill') .. SenderName,5000)
    else
        VORPcore.NotifyRightTip(src, 'Wrong Input', 5000)
    end
end)

-- Get Sendet Bills

RegisterServerEvent('mms-society:server:ShowSendedBills',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local CharID = Character.charIdentifier
    local GetSendedBills = MySQL.query.await("SELECT * FROM mms_society_bills WHERE fromchar=@fromchar", { ["@fromchar"] = CharID})
        if #GetSendedBills > 0 then
            TriggerClientEvent('mms-society:client:ReciveSendetBills',src,GetSendedBills)
        else
            VORPcore.NotifyRightTip(src,_U('NoSendetBills'),5000)
        end
end)

-- Delete Bill 

RegisterServerEvent('mms-society:server:ConfirmDelete',function(BillID)
    local src = source
    MySQL.execute('DELETE FROM mms_society_bills WHERE id = ?', { BillID }, function()
    end)
    VORPcore.NotifyRightTip(src,_U('BillDeleted'),5000)
end)

-- Get Recived Bills

RegisterServerEvent('mms-society:server:GetRecivedBills',function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local CharID = Character.charIdentifier
    local ReciveGottenBills = MySQL.query.await("SELECT * FROM mms_society_bills WHERE tochar=@tochar", { ["@tochar"] = CharID})
        if #ReciveGottenBills > 0 then
            TriggerClientEvent('mms-society:client:ReciveGottenBills',src,ReciveGottenBills)
        else
            VORPcore.NotifyRightTip(src,_U('NoRecivedBills'),5000)
        end
end)

-- Pay This Bill

RegisterServerEvent('mms-society:client:PayThisBill',function(BillID,ToCompany,Amount)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local Money = Character.money
    if Money >= Amount then
        local GetCompany = MySQL.query.await("SELECT * FROM mms_society WHERE name=@name", { ["@name"] = ToCompany})
        if #GetCompany > 0 then
            local OldBalance = GetCompany[1].balance
            local NewBalance = OldBalance + Amount
            MySQL.update('UPDATE `mms_society` SET balance = ? WHERE name = ?',{NewBalance, ToCompany})
            MySQL.execute('DELETE FROM mms_society_bills WHERE id = ?', { BillID }, function()
            end)
            Character.removeCurrency(0,Amount)
            VORPcore.NotifyRightTip(src,_U('BillPayed'),5000)
        end
    else
        VORPcore.NotifyRightTip(src,_U('NotEnoghMoney2'),5000)
    end
end)

-- Delete Job Permanently

RegisterServerEvent('mms-society:client:DeleteJobPermanently',function(JobToDelete)
    local src = source
    MySQL.execute('DELETE FROM mms_society WHERE name = ?', { JobToDelete }, function()
    end)
    MySQL.execute('DELETE FROM mms_society_ranks WHERE name = ?', { JobToDelete }, function()
    end)
    MySQL.execute('DELETE FROM mms_society_bills WHERE job = ?', { JobToDelete }, function()
    end)
    local InvetoryExists = exports.vorp_inventory:isCustomInventoryRegistered(JobToDelete)
    if InvetoryExists then
        exports.vorp_inventory:deleteCustomInventory(JobToDelete)
        exports.vorp_inventory:removeInventory(JobToDelete)
    end
end)

-- Get Jobs From DB

RegisterServerEvent('mms-society:server:GetAllJobs',function()
    local src = source
    local AllJobs = MySQL.query.await("SELECT * FROM mms_society", {})
    if AllJobs ~= nil then
        TriggerClientEvent('mms-society:client:ReciveAllJobs',src,AllJobs)
    else
        VORPcore.NotifyRightTip(src, _U('NoJobsFound'),5000)
    end
end)

-- ToggelBlip

RegisterServerEvent('mms-society:server:ToggleBlip',function(job,NewStatus)
    local src = source
    MySQL.update('UPDATE `mms_society` SET blipactive = ? WHERE name = ?',{NewStatus, job})
    for h,v in ipairs(GetPlayers()) do
        TriggerClientEvent('mms-society:client:updateplayerdata',v)
    end
    VORPcore.NotifyRightTip(src, _U('ToggledBlipStatus'),5000)
end)

-- Update Blip

RegisterServerEvent('mms-society:server:UpdateBlip',function(job,InputBlipName,InputBlipSprite,InputBlipColor)
    local src = source
    if InputBlipName ~= "" then
        MySQL.update('UPDATE `mms_society` SET blipname = ? WHERE name = ?',{InputBlipName, job})
    end
    if InputBlipSprite ~= "" then
        MySQL.update('UPDATE `mms_society` SET bliphash = ? WHERE name = ?',{InputBlipSprite, job})
    end
    if InputBlipColor ~= "" then
        MySQL.update('UPDATE `mms_society` SET blipcolor = ? WHERE name = ?',{InputBlipColor, job})
    end
    for h,v in ipairs(GetPlayers()) do
        TriggerClientEvent('mms-society:client:updateplayerdata',v)
    end
    VORPcore.NotifyRightTip(src, _U('ToggledBlipStatus'),5000)
end)