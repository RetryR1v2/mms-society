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
            VORPcore.NotifyTip(src, _U('JobAlreadyExist') .. jobname .. ' ' .. joblabel,  5000)
            if Config.EnableWebHook then
                VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, _U('JobAlreadyExist') .. jobname .. ' ' .. joblabel, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
            end
        else
            MySQL.insert('INSERT INTO `mms_society` (name, label, balance,BossPosX,BossPosY,BossPosZ,StoragePosX,StoragePosY,StoragePosZ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            {jobname,joblabel,0,0,0,0,0,0,0}, function()end)
            MySQL.insert('INSERT INTO `mms_society_ranks` (name, ranklabel, rank, isboss, canwithdraw, storageaccess) VALUES (?, ?, ?, ?, ?, ?)',
            {jobname,"Boss",bossrank,1,1,1}, function()end)
            VORPcore.NotifyTip(src, _U('JobCreated') .. jobname .. ' ' .. joblabel,  5000)
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
        VORPcore.NotifyTip(src, _U('BossPositionSet'),  5000)
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
        VORPcore.NotifyTip(src, _U('StorageSet'),  5000)
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
        VORPcore.NotifyTip(src, _U('NewRankCreated'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, _U('NewRankCreated') .. ' ' .. InputRank .. ' ' .. InputLabel, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    else
        VORPcore.NotifyTip(src, _U('RankExistsAlready'),  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('RankExistsAlready'), Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
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
        VORPcore.NotifyTip(src, _U('CantOwnRankDeleted') .. job .. ' ' .. InputRank,  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('CantOwnRankDeleted') .. job .. ' ' .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    else
        MySQL.execute('DELETE FROM mms_society_ranks WHERE rank = ?', { InputRank }, function()
        end)
        VORPcore.NotifyTip(src, _U('RankDeleted') .. job .. ' ' .. InputRank,  5000)
        if Config.EnableWebHook then
            VORPcore.AddWebhook(Config.WHTitle, Config.WHLink,_U('RankDeleted') .. job .. ' ' .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
        end
    end
end)

--- InviteClosestPlayer

RegisterServerEvent('mms-society:server:InviteClosestPlayer',function(InputRank)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local job = Character.job
    local jobGrade = Character.jobGrade
    local NumberInputRank = tonumber(InputRank)
    local MyPedId = GetPlayerPed(src)
    local MyCoords =  GetEntityCoords(MyPedId)
    local firstname = Character.firstname
    local lastname = Character.lastname
    local RankLabel = ''
    local RankResult = MySQL.query.await("SELECT * FROM mms_society_ranks WHERE name=@name", { ["name"] = job})
    
    if #RankResult > 0 then
        for i,v in ipairs(RankResult) do
            if NumberInputRank == v.rank then
                RankLabel = v.ranklabel
            end
        end
    end

    for _, player in ipairs(GetPlayers()) do
        local ClosestCharacter = VORPcore.getUser(player).getUsedCharacter
        local PlayerPedId = GetPlayerPed(player)
        local PlayerCoords =  GetEntityCoords(PlayerPedId)
        local Dist = #(MyCoords - PlayerCoords)
        local closestfirstname = ClosestCharacter.firstname
        local closestlastname = ClosestCharacter.lastname
        local closestcharidentifier = ClosestCharacter.charIdentifier
        if Dist > 0.3 and Dist < 1.5 then
            VORPcore.NotifyTip(src, _U('PlayerInvited') .. closestfirstname .. ' ' .. closestlastname .. '!',  5000)
            VORPcore.NotifyTip(player, _U('YouGotInvited') .. job .. _U('YourRank') .. InputRank .. '!',  5000)
            ClosestCharacter.setJob(job)
            ClosestCharacter.setJobGrade(NumberInputRank)
            ClosestCharacter.setJobLabel(RankLabel)
            MySQL.update('UPDATE `characters` SET job = ? WHERE charidentifier = ?',{job, closestcharidentifier})
            MySQL.update('UPDATE `characters` SET joblabel = ? WHERE charidentifier = ?',{RankLabel, closestcharidentifier})
            MySQL.update('UPDATE `characters` SET jobgrade = ? WHERE charidentifier = ?',{NumberInputRank, closestcharidentifier})
            Wait(250)
            TriggerClientEvent('mms-society:client:updateplayerdata',player)
            if Config.EnableWebHook == true then
                VORPcore.AddWebhook(Config.WHTitle, Config.WHLink, firstname .. ' ' .. lastname .. _U('Invited') .. closestfirstname .. ' ' .. closestlastname .. _U('Jobb') .. job .. _U('Rankk') .. InputRank, Config.WHColor, Config.WHName, Config.WHLogo, Config.WHFooterLogo, Config.WHAvatar)
            end
        end
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
            VORPcore.NotifyTip(src, ToNumberAmount .. _U('Withdrawn'),  5000)
        else
            VORPcore.NotifyTip(src, _U('NotEnoghMoney'),  5000)
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
            VORPcore.NotifyTip(src, ToNumberAmount .. _U('Deposited'),  5000)
        else
            VORPcore.NotifyTip(src, _U('NotEnoghMoney'),  5000)
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