local VORPcore = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local FeatherMenu =  exports['feather-menu'].initiate()


------ LOCALS
local MyJob = nil
local LedgerOpen = false
local RanksManage = false
local PlayerManage = false
local ImBoss = false
local ImStorage = false
local ImCash = false
local SocietyActive = false
local GetSendBills = false
local ConfirmSiteOpen = false
local GetRecivedBills = false
local DeleteJobMenu = false
local BlipActiveText = ''
local SocietyBlips = {}


RegisterNetEvent('vorp:SelectedCharacter')
AddEventHandler('vorp:SelectedCharacter', function()
    Citizen.Wait(5000)
    TriggerServerEvent('mms-society:server:getplayerdata')
end)

if Config.Debug then
    Citizen.CreateThread(function ()
        Citizen.Wait(3000)
        TriggerServerEvent('mms-society:server:getplayerdata')
    end)
end

RegisterNetEvent('mms-society:client:updateplayerdata')
AddEventHandler('mms-society:client:updateplayerdata',function()
    SocietyActive = false
    Citizen.Wait(250)
    for _, blip in ipairs(SocietyBlips) do
        blip:Remove()
    end
    TriggerServerEvent('mms-society:server:getplayerdata')
end)

RegisterNetEvent('mms-society:client:recieveuserdata')
AddEventHandler('mms-society:client:recieveuserdata',function(identifier,charidentifier,firstname,lastname,job,jobGrade,jobLabel,group,societyjobs,societyranks)
    --- CHECK IF ADMIN TO CREATE JOBS
        RegisterCommand(Config.JobCreatorCommand, function()
            if group == Config.AdminGroup then
                JobCreator:Open({
                    startupPage = JobCreatorPage1,
                })
            end
        end)
    ---  Boss Menu To Set Locations and Create Ranks / Invite Player

    RegisterCommand(Config.BossMenuCommand, function()
        for i ,v in ipairs(societyranks) do
            if job == v.name and jobGrade == v.rank and v.isboss == 1 then
                BossMenu:Open({
                startupPage = BossMenuPage1,
                 })
            end
        end
    end)

    TriggerEvent('mms-society:client:CreateMenu',job,jobGrade,jobLabel,societyjobs,societyranks) -- Create Menu Part
    TriggerEvent('mms-society:client:CreateBossAndStorage',job,jobGrade,jobLabel,societyjobs,societyranks)  -- Create BossMenu and Storage
    TriggerEvent('mms-society:client:CreateSocietyBlips',societyjobs)
end)


---------------------------------------------------------------------------------------------------------
--------------------------------------- Jobcreator Menü------------------------------------------------
---------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function ()
    JobCreator = FeatherMenu:RegisterMenu('jobcreator', {
        top = '20%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
    --canclose = false
    }, {
        opened = function()
            --print("MENU OPENED!")
        end,
        closed = function()
            --print("MENU CLOSED!")
        end,
        topage = function(data)
            --print("PAGE CHANGED ", data.pageid)
        end
    })

    --- Seite 1 Menu
    JobCreatorPage1 = JobCreator:RegisterPage('seite1')
    JobCreatorPage1:RegisterElement('header', {
        value = _U('JobCreatorHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage1:RegisterElement('button', {
        label =  _U('JobCreatorCreateJobButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreatorPage2.RouteTo()
    end)
    JobCreatorPage1:RegisterElement('button', {
        label =  _U('JobCreatorDeleteJobButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-society:server:GetAllJobs')
    end)
    JobCreatorPage1:RegisterElement('button', {
        label =  _U('CloseJobCreator'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreator:Close({ })
    end)
    JobCreatorPage1:RegisterElement('subheader', {
        value = _U('JobCreatorHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })

-- Seite 2 Job Erstellen
    JobCreatorPage2 = JobCreator:RegisterPage('seite2')
    JobCreatorPage2:RegisterElement('header', {
        value = _U('JobCreatorHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local jobname = ''
    JobCreatorPage2:RegisterElement('input', {
        label = _U('EnterJobName'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        jobname = data.value
    end)
    local joblabel = ''
    JobCreatorPage2:RegisterElement('input', {
        label = _U('EnterJobLabel'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        joblabel = data.value
    end)
    local bossrank = ''
    JobCreatorPage2:RegisterElement('input', {
        label = _U('EnterBossGrade'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        bossrank = data.value
    end)
    JobCreatorPage2:RegisterElement('button', {
        label = _U('CreateJob'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:createjob',jobname,joblabel,bossrank)
    end)
    JobCreatorPage2:RegisterElement('button', {
        label =  _U('JobCreatorBack'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreatorPage1.RouteTo()
    end)
    JobCreatorPage2:RegisterElement('button', {
        label =  _U('CloseJobCreator'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreator:Close({ 
        })
    end)
    JobCreatorPage2:RegisterElement('subheader', {
        value = _U('JobCreatorHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
end)

-- Seite 3

RegisterNetEvent('mms-society:server:GetAllJobs')
AddEventHandler('mms-society:server:GetAllJobs',function(AllJobs)
    if not DeleteJobMenu then
        DeleteJobMenu = true
    elseif DeleteJobMenu then
        JobCreatorPage3:UnRegister()
    end
    JobCreatorPage3 = JobCreator:RegisterPage('seite3')
    JobCreatorPage3:RegisterElement('header', {
        value = _U('JobCreatorHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for h,v in ipairs(AllJobs) do
        local TextData = _U('JobNameToDelte') .. v.name .. _U('SureToDelte')
        JobCreatorPage3:RegisterElement('button', {
            label = TextData,
            style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            local JobToDelete = v.name
            TriggerServerEvent('mms-society:client:DeleteJobPermanently',JobToDelete)
        end)
    end
    JobCreatorPage3:RegisterElement('button', {
        label =  _U('JobCreatorBack'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreatorPage1.RouteTo()
    end)
    JobCreatorPage3:RegisterElement('button', {
        label =  _U('CloseJobCreator'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        JobCreator:Close({ 
        })
    end)
    JobCreatorPage3:RegisterElement('subheader', {
        value = _U('JobCreatorHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    JobCreatorPage3:RouteTo()
end)

---------------------------------------------------------------------------------------------------------
--------------------------------------- Boss Menü -------------------------------------------------------
---------------------------------------------------------------------------------------------------------

RegisterNetEvent('mms-society:client:CreateMenu')
AddEventHandler('mms-society:client:CreateMenu',function (job,jobGrade,jobLabel,societyjobs,societyranks)
    for h,v in ipairs(societyjobs) do
        if job == v.name then
            MyJob = v
        end
    end
    for h,v in ipairs(societyranks) do
        if job == v.name and jobGrade == v.rank then
            if v.isboss == 1 then
                ImBoss = true
                if Config.Debug then
                    print('Ich bin Boss')
                    print(ImBoss)
                end
            end
            if v.canwithdraw == 1 then
                ImCash = true
                if Config.Debug then
                    print('Ich darf Geld')
                    print(ImCash)
                end
            end
            if v.storageaccess == 1 then
                ImStorage = true
                if Config.Debug then
                    print('Ich darf Lager')
                    print(ImStorage)
                end
            end
        end
    end
    BossMenu = FeatherMenu:RegisterMenu('bossmenu', {
        top = '20%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '550px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
    BossMenuPage1 = BossMenu:RegisterPage('seite1')
    BossMenuPage1:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    if ImBoss then
    BossMenuPage1:RegisterElement('button', {
        label = _U('InvitePlayer'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage4.RouteTo()
    end)
    BossMenuPage1:RegisterElement('button', {
        label = _U('ManagePlayers'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:GetEmployers')
    end)
    BossMenuPage1:RegisterElement('button', {
        label = _U('SetBossLocation'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        MyPos = GetEntityCoords(PlayerPedId())
        TriggerEvent('mms-society:client:setbosslocation',MyPos)
    end)
    BossMenuPage1:RegisterElement('button', {
        label =  _U('SetStorage'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        MyPos = GetEntityCoords(PlayerPedId())
        TriggerEvent('mms-society:client:setstoragelocation',MyPos)
    end)
    BossMenuPage1:RegisterElement('button', {
        label =  _U('CreateRank'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage2.RouteTo()
    end)
    BossMenuPage1:RegisterElement('button', {
        label =  _U('ManageRank'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:getranks')
    end)
    BossMenuPage1:RegisterElement('button', {
        label =  _U('BlipManagement'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage7.RouteTo()
    end)
    end
    if ImCash or ImBoss then
        BossMenuPage1:RegisterElement('button', {
            label =  _U('Ledger'),
            style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
            TriggerEvent('mms-society:client:getledger')
        end)
    end
    BossMenuPage1:RegisterElement('button', {
        label =  _U('LeaveCompany'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
    }, function()
        TriggerEvent('mms-society:client:LeaveJob')
        BossMenu:Close({ })
    end)
    BossMenuPage1:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ 
        })
    end)
    BossMenuPage1:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })


    ------------------------------------------------------
    ---------------- Boss Menu Seite 2 -------------------
    ------------------------------------------------------

    BossMenuPage2 = BossMenu:RegisterPage('seite2')
    BossMenuPage2:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local InputRank = ''
    BossMenuPage2:RegisterElement('input', {
        label = _U('EnterRank'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputRank = data.value
    end)
    local InputLabel = ''
    BossMenuPage2:RegisterElement('input', {
        label = _U('EnterRankLabel'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputLabel = data.value
    end)
    BossMenuPage2:RegisterElement("checkbox", {
        label = _U('IsBoss'),
        start = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
    }, function(data)
        IsBoss = data.value
    end)
    BossMenuPage2:RegisterElement("checkbox", {
        label = _U('CanWithdraw'),
        start = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
    }, function(data)
        CanWithdraw = data.value
    end)
    BossMenuPage2:RegisterElement("checkbox", {
        label = _U('StorageAccess'),
        start = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
    }, function(data)
        StorageAccess = data.value
    end)
    BossMenuPage2:RegisterElement('button', {
        label =  _U('CreateRankButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:bosscreaterank',InputRank,InputLabel,IsBoss,CanWithdraw,StorageAccess)
    end)
    BossMenuPage2:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage2:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ 
        })
    end)
    BossMenuPage2:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })

    ------------------------------------------------------
    ---------------- Boss Menu Seite 4 -------------------
    ------------------------------------------------------

    BossMenuPage4 = BossMenu:RegisterPage('seite4')
    BossMenuPage4:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage4:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    InviteText = BossMenuPage4:RegisterElement('textdisplay', {
        value = _U('MakeSureYouCreatedRank'),
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
            
        }
    })
    local InputPlayerID = ''
    BossMenuPage4:RegisterElement('input', {
        label = _U('EnterPlayerID'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputPlayerID = data.value
    end)
    local InputRank = ''
    BossMenuPage4:RegisterElement('input', {
        label = _U('EnterRank'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputRank = data.value
    end)
    BossMenuPage4:RegisterElement('button', {
        label =  _U('InvitePlayerButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:InvitePlayer',InputRank,InputPlayerID)
    end)
    BossMenuPage4:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage4:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ 
        })
    end)
    BossMenuPage4:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage4:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })

    ------------------------------------------------------
    ---------------- Boss Menu Seite 7 -------------------
    ------------------------------------------------------
    if MyJob.blipactive == 1 then
        BlipActiveText = _U('Yes')
    else
        BlipActiveText = _U('No')
    end
    if Config.Debug then
        print(MyJob.blipname)
        print(MyJob.bliphash)
        print(MyJob.blipcolor)
        print(MyJob.blipactive)
    end
    BossMenuPage7 = BossMenu:RegisterPage('seite7')
    BossMenuPage7:RegisterElement('header', {
        value = _U('BlipMenuHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage7:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    InviteText = BossMenuPage7:RegisterElement('textdisplay', {
        value = _U('CurrentBlip') .. BlipActiveText .. _U('BlipSprite') .. MyJob.bliphash .. _U('BlipColor') .. MyJob.blipcolor .. _U('BlipName') .. MyJob.blipname,
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
            
        }
    })
    BossMenuPage7:RegisterElement('button', {
        label =  _U('ToggleBlipButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        local NewStatus = nil
        if MyJob.blipactive == 1 then
            NewStatus = 0
        else
            NewStatus = 1
        end
        TriggerServerEvent('mms-society:server:ToggleBlip',job,NewStatus)
    end)
    local InputBlipName = ''
    BossMenuPage7:RegisterElement('input', {
        label = _U('InputBlipName'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputBlipName = data.value
    end)
    local InputBlipSprite = ''
    BossMenuPage7:RegisterElement('input', {
        label = _U('InputBlipSprite'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputBlipSprite = data.value
    end)
    local InputBlipColor = ''
    BossMenuPage7:RegisterElement('input', {
        label = _U('InputBlipColor'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputBlipColor = data.value
    end)
    BossMenuPage7:RegisterElement('button', {
        label =  _U('UpdateBlipButton'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-society:server:UpdateBlip',job,InputBlipName,InputBlipSprite,InputBlipColor)
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage7:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage7:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({})
    end)
    BossMenuPage7:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage7:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })

end)

-- Leave Job

RegisterNetEvent('mms-society:client:LeaveJob')
AddEventHandler('mms-society:client:LeaveJob',function ()
    TriggerServerEvent('mms-society:server:LeaveJob')
end)

-- Get Ledger from DB

RegisterNetEvent('mms-society:client:getledger')
AddEventHandler('mms-society:client:getledger',function ()
    TriggerServerEvent('mms-society:server:getledger')
end)

RegisterNetEvent('mms-society:client:reciveledger')
AddEventHandler('mms-society:client:reciveledger',function (Balance)
    ------------------------------------------------------
    ---------------- Boss Menu Seite 6 -------------------
    ------------------------------------------------------
    if not LedgerOpen then
        LedgerOpen = true
    elseif LedgerOpen then
        BossMenuPage6:UnRegister()
    end
    BossMenuPage6 = BossMenu:RegisterPage('seite6')
    BossMenuPage6:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage6:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    LedgerAmount = BossMenuPage6:RegisterElement('textdisplay', {
        value = _U('LedgerAmountText') .. Balance .. ' $',
        style = {
            ['font-size'] = '20px',
            ['font-weight'] = 'bold',
            ['color'] = 'orange',
        }
    })
    local InputAmount = ''
    BossMenuPage6:RegisterElement('input', {
        label = _U('EnterAmount'),
        placeholder = "0 $",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputAmount = data.value
    end)
    BossMenuPage6:RegisterElement('button', {
        label =  _U('Deposit'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:Deposit',InputAmount)
    end)
    BossMenuPage6:RegisterElement('button', {
        label =  _U('Withdraw'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:Withdraw',InputAmount)
    end)
    BossMenuPage6:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage6:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ })
    end)
    BossMenuPage6:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage6:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage6:RouteTo()
end)

--- Get Ranks from DB

RegisterNetEvent('mms-society:client:getranks')
AddEventHandler('mms-society:client:getranks',function ()
    TriggerServerEvent('mms-society:server:getranks')
end)

RegisterNetEvent('mms-society:client:reciveranks')
AddEventHandler('mms-society:client:reciveranks',function (RankResult)
    ------------------------------------------------------
    ---------------- Boss Menu Seite 3 -------------------
    ------------------------------------------------------
    if not RanksManage then
        RanksManage = true
    elseif RanksManage then
        BossMenuPage3:UnRegister()
    end
    BossMenuPage3 = BossMenu:RegisterPage('seite3')
    BossMenuPage3:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for i,v in ipairs(RankResult) do
        local Boss = ""
        if v.isboss == 1 then Boss = _U('Yes') else Boss = _U('No') end
        local Ledger = ""
        if v.canwithdraw == 1 then Ledger = _U('Yes') else Ledger = _U('No') end
        local Storage = ""
        if v.storageaccess == 1 then Storage = _U('Yes') else Storage = _U('No') end
        local displaydata = _U('JobLabelLabel') .. v.ranklabel .. _U('JobRankLabel') .. v.rank .. _U('IsRankBoss') .. Boss .. _U('CanRankLedged') .. Ledger .. _U('CanRankStorage') .. Storage
        v.rank = BossMenuPage3:RegisterElement('textdisplay', {
            value = displaydata,
            style = {
                ['font-size'] = '20px',
                ['font-weight'] = 'bold',
                ['color'] = 'orange',
                
            }
        })
    end
    local InputRank = ''
    BossMenuPage3:RegisterElement('input', {
        label = _U('EnterRank'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputRank = data.value
    end)
    BossMenuPage3:RegisterElement('button', {
        label =  _U('DeleteRank'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerEvent('mms-society:client:bossdeleterank',InputRank)
        BossMenu:Close({ })
    end)
    BossMenuPage3:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage3:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ })
    end)
    BossMenuPage3:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage3:RouteTo()
end)

RegisterNetEvent('mms-society:client:ReciveEmployers')
AddEventHandler('mms-society:client:ReciveEmployers',function (EmployerResult)

    ------------------------------------------------------
    ---------------- Boss Menu Seite 5 -------------------
    ------------------------------------------------------
    if not PlayerManage then
        PlayerManage = true
    elseif PlayerManage then
        BossMenuPage5:UnRegister()
    end
    BossMenuPage5 = BossMenu:RegisterPage('seite5')
    BossMenuPage5:RegisterElement('header', {
        value = _U('BossMenu'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage5:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for i,v in ipairs(EmployerResult) do
        local displaydata = _U('EmployedID') .. v.charidentifier .. _U('Employer') .. v.firstname .. ' ' .. v.lastname .. _U('HasRank') .. v.jobgrade
        v.charidentifier = BossMenuPage5:RegisterElement('textdisplay', {
            value = displaydata,
            style = {
                ['font-size'] = '20px',
                ['font-weight'] = 'bold',
                ['color'] = 'orange',
                
            }
        })
    end
    local InputID = ''
    BossMenuPage5:RegisterElement('input', {
        label = _U('EnterID'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputID = data.value
    end)
    local InputNewRank = ''
    BossMenuPage5:RegisterElement('input', {
        label = _U('NewRank'),
        placeholder = "",
        persist = false,
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function(data)
        InputNewRank = data.value
    end)
    BossMenuPage5:RegisterElement('button', {
        label =  _U('ChangeRank'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-society:server:ChangeRank',InputID,InputNewRank)
        BossMenu:Close({ })
    end)
    BossMenuPage5:RegisterElement('button', {
        label =  _U('FireEmployer'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-society:server:FireEmplyoer',InputID)
        BossMenu:Close({ })
    end)
    BossMenuPage5:RegisterElement('button', {
        label =  _U('Back'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenuPage1:RouteTo()
    end)
    BossMenuPage5:RegisterElement('button', {
        label =  _U('CloseBossMenu'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BossMenu:Close({ })
    end)
    BossMenuPage5:RegisterElement('subheader', {
        value = _U('BossMenu'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage5:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BossMenuPage5:RouteTo()
end)

-- Get Employers

RegisterNetEvent('mms-society:client:GetEmployers')
AddEventHandler('mms-society:client:GetEmployers',function()
    TriggerServerEvent('mms-society:server:GetEmployers')
end)

--- Create Job

RegisterNetEvent('mms-society:client:createjob')
AddEventHandler('mms-society:client:createjob',function(jobname,joblabel,bossrank)
    TriggerServerEvent('mms-society:server:createjob',jobname,joblabel,bossrank)
end)

--- Set BossLocation

RegisterNetEvent('mms-society:client:setbosslocation')
AddEventHandler('mms-society:client:setbosslocation',function(MyPos)
    local BossPosX = MyPos.x
    local BossPosY = MyPos.y
    local BossPosZ = MyPos.z
    TriggerServerEvent('mms-society:server:setbosslocation',BossPosX,BossPosY,BossPosZ)
end)

--- Set Storage

RegisterNetEvent('mms-society:client:setstoragelocation')
AddEventHandler('mms-society:client:setstoragelocation',function(MyPos)
    local StoragePosX = MyPos.x
    local StoragePosY = MyPos.y
    local StoragePosZ = MyPos.z
    TriggerServerEvent('mms-society:server:setstoragelocation',StoragePosX,StoragePosY,StoragePosZ)
end)

--- Create Rank

RegisterNetEvent('mms-society:client:bosscreaterank')
AddEventHandler('mms-society:client:bosscreaterank',function (InputRank,InputLabel,IsBoss,CanWithdraw,StorageAccess)
    TriggerServerEvent('mms-society:server:bosscreaterank',InputRank,InputLabel,IsBoss,CanWithdraw,StorageAccess)
end)

--- Delete Rank

RegisterNetEvent('mms-society:client:bossdeleterank')
AddEventHandler('mms-society:client:bossdeleterank',function (InputRank)
    TriggerServerEvent('mms-society:server:bossdeleterank',InputRank)
end)

--- Invite Player

RegisterNetEvent('mms-society:client:InvitePlayer')
AddEventHandler('mms-society:client:InvitePlayer',function(InputRank,InputPlayerID)
    TriggerServerEvent('mms-society:server:InvitePlayer',InputRank,InputPlayerID)
end)

--- Create Menü and Storage


RegisterNetEvent('mms-society:client:CreateBossAndStorage',function(job,jobGrade,jobLabel,societyjobs,societyranks)
    SocietyActive = true
    local OpenBossGroup = BccUtils.Prompts:SetupPromptGroup()
    local OpenBossGroupPrompt = OpenBossGroup:RegisterPrompt(_U('OpenBossMenuPrompt'), 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})

    local OpenStorageGroup = BccUtils.Prompts:SetupPromptGroup()
    local OpenStorageGroupPrompt = OpenStorageGroup:RegisterPrompt(_U('OpenStoragePrompt'), 0x27D1C284, 1, 1, true, 'hold', {timedeventhash = 'MEDIUM_TIMED_EVENT'})

    for h,v in ipairs (societyjobs)do
        if job == v.name then
            if Config.ShowStorageBlip then 
                local StorageBlip = BccUtils.Blips:SetBlip(v.label, Config.BlipSpriteStorage, 0.8, v.StoragePosX,v.StoragePosY,v.StoragePosZ)
                SocietyBlips[#SocietyBlips + 1] = StorageBlip
            end
        end
    end
    while SocietyActive do
        Wait(5)
        local PlayerPos = GetEntityCoords(PlayerPedId())
        for h,v in ipairs(societyjobs) do
            if job == v.name then
                local DistanceBoss =  GetDistanceBetweenCoords(PlayerPos.x,PlayerPos.y,PlayerPos.z,v.BossPosX,v.BossPosY,v.BossPosZ,false)
                local DistanceStorage =  GetDistanceBetweenCoords(PlayerPos.x,PlayerPos.y,PlayerPos.z,v.StoragePosX,v.StoragePosY,v.StoragePosZ,false)
                Citizen.InvokeNative(0x2A32FAA57B937173,0x94FDAE17,v.BossPosX,v.BossPosY,v.BossPosZ -1,0,0,0,0,0,0,1.0,1.0,0.2,250,250,100,250,0, 0, 2, 0, 0, 0, 0)
                Citizen.InvokeNative(0x2A32FAA57B937173,0x94FDAE17,v.StoragePosX,v.StoragePosY,v.StoragePosZ -1,0,0,0,0,0,0,1.0,1.0,0.2,250,250,100,250,0, 0, 2, 0, 0, 0, 0)



                if DistanceBoss < 2 then
                    OpenBossGroup:ShowGroup(jobLabel)
                    if OpenBossGroupPrompt:HasCompleted() then
                        BossMenu:Open({
                            startupPage = BossMenuPage1,
                        })
                    end
                end
                if DistanceStorage < 2 then
                    OpenStorageGroup:ShowGroup(jobLabel)
                    if OpenStorageGroupPrompt:HasCompleted() then
                        for h,v in ipairs (societyranks) do
                            if jobGrade == v.rank and v.storageaccess == 1 then 
                                TriggerServerEvent('mms-society:server:OpenStorage',job,jobLabel)
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('mms-society:client:CreateSocietyBlips')
AddEventHandler('mms-society:client:CreateSocietyBlips',function(societyjobs)
    for h,v in ipairs(societyjobs) do
        if v.blipactive == 1 then
            local CompanyBlip = BccUtils.Blips:SetBlip(v.blipname, v.bliphash, 0.8, v.BossPosX, v.BossPosY, v.BossPosZ)
            local blipModifier = BccUtils.Blips:AddBlipModifier(CompanyBlip, v.blipcolor)
            blipModifier:ApplyModifier()
            SocietyBlips[#SocietyBlips + 1] = CompanyBlip
        end
    end
end)


RegisterNetEvent('mms-society:client:Deposit')
AddEventHandler('mms-society:client:Deposit',function(InputAmount)
    TriggerServerEvent('mms-society:server:Deposit',InputAmount)
    BossMenuPage1:RouteTo()
end)

RegisterNetEvent('mms-society:client:Withdraw')
AddEventHandler('mms-society:client:Withdraw',function(InputAmount)
    TriggerServerEvent('mms-society:server:Withdraw',InputAmount)
    BossMenuPage1:RouteTo()
end)


----------------------------------------------------------------------------------------------------------------------
---------------------------------------------- BILL MENU -------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

RegisterCommand(Config.SocietyBillsCommand, function()
	Bills:Open({
        startupPage = BillsPage1,
    })
end)

Citizen.CreateThread(function ()
    Bills = FeatherMenu:RegisterMenu('SocietyBills', {
        top = '20%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '700px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '800px',
        style = {
            ['border'] = '5px solid orange',
            -- ['background-image'] = 'none',
            ['background-color'] = '#FF8C00'
        },
        contentslot = {
            style = {
                ['height'] = '550px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
    --canclose = false
}, {
    opened = function()
        --print("MENU OPENED!")
    end,
    closed = function()
        --print("MENU CLOSED!")
    end,
    topage = function(data)
        --print("PAGE CHANGED ", data.pageid)
    end
})
    BillsPage1 = Bills:RegisterPage('seite1')
    BillsPage1:RegisterElement('header', {
        value = _U('BillsBoardHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage1:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    local InputID = ''
    BillsPage1:RegisterElement('input', {
    label = _U('EnterPlayerID'),
    placeholder = "",
    persist = false,
    style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
    },
    }, function(data)
        InputID = data.value
    end)
    local Amount = ''
    BillsPage1:RegisterElement('input', {
    label = _U('BillAmount'),
    placeholder = "",
    persist = false,
    style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
    },
    }, function(data)
        Amount = data.value
    end)
    local Reason = ''
        BillsPage1:RegisterElement('input', {
        label = _U('BillReason'),
        placeholder = "",
        persist = false,
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function(data)
        Reason = data.value
    end)
    BillsPage1:RegisterElement('button', {
        label = _U('CreateBill'),
        style = {
            ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        local BillReason = Reason
        local BillAmount = tonumber(Amount)
        local CustomerID = tonumber(InputID)
        Bills:Close({})
        TriggerServerEvent('mms-society:server:CreateBill',BillReason,BillAmount,CustomerID)
    end)
    BillsPage1:RegisterElement('button', {
        label = _U('MyCreatedBills'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
            },
        }, function()
        TriggerServerEvent('mms-society:server:ShowSendedBills')
    end)
    BillsPage1:RegisterElement('button', {
        label = _U('MyRecievedBills'),
        style = {
            ['background-color'] = '#FF8C00',
            ['color'] = 'orange',
            ['border-radius'] = '6px'
        },
    }, function()
        TriggerServerEvent('mms-society:server:GetRecivedBills')
    end)
    BillsPage1:RegisterElement('button', {
        label =  _U('CloseBoardBills'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        Bills:Close({
        })
    end)
    BillsPage1:RegisterElement('subheader', {
        value = _U('BillsBoardHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage1:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })

end)

RegisterNetEvent('mms-society:client:ReciveSendetBills')
AddEventHandler('mms-society:client:ReciveSendetBills',function(GetSendedBills)
    if not GetSendBills then
        GetSendBills = true
    elseif GetSendBills then
        BillsPage2:UnRegister()
    end
    BillsPage2 = Bills:RegisterPage('seite2')
    BillsPage2:RegisterElement('header', {
        value = _U('SendetBillsHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage2:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for h,v in ipairs(GetSendedBills) do
    local ButtonLabel = _U('BillTo') .. v.toname .. _U('BillReason2') .. v.reason .. _U('BillAmount2') .. v.amount .. '$ ' .. _U('Company') .. v.joblabel
        BillsPage2:RegisterElement('button', {
            label = ButtonLabel,
            style = {
                ['background-color'] = '#FF8C00',
                ['color'] = 'orange',
                ['border-radius'] = '6px'
                },
            }, function()
            local BillID = v.id
            TriggerEvent('mms-society:client:ConfirmDelete',BillID)
        end)
    end
    BillsPage2:RegisterElement('button', {
        label =  _U('BillsBack'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BillsPage1:RouteTo()
    end)
    BillsPage2:RegisterElement('button', {
        label =  _U('CloseBoardBills'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        Bills:Close({})
    end)
    BillsPage2:RegisterElement('subheader', {
        value = _U('BillsBoardHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage2:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage2:RouteTo()
end)

-- Confirm Page

RegisterNetEvent('mms-society:client:ConfirmDelete')
AddEventHandler('mms-society:client:ConfirmDelete',function(BillID)
    if not ConfirmSiteOpen then
        ConfirmSiteOpen = true
    elseif ConfirmSiteOpen then
        BillsPage3:UnRegister()
    end
    BillsPage3 = Bills:RegisterPage('seite3')
    BillsPage3:RegisterElement('header', {
        value = _U('WannaDeleteThisBill'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage3:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage3:RegisterElement('button', {
        label =  _U('Confirm'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        Bills:Close({})
        TriggerServerEvent('mms-society:server:ConfirmDelete',BillID)
    end)
    BillsPage3:RegisterElement('button', {
        label =  _U('Abort'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BillsPage1:RouteTo()
    end)
    BillsPage3:RegisterElement('subheader', {
        value = _U('WannaDeleteThisBill'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage3:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage3:RouteTo()
end)

RegisterNetEvent('mms-society:client:ReciveGottenBills')
AddEventHandler('mms-society:client:ReciveGottenBills',function(ReciveGottenBills)
    if not GetRecivedBills then
        GetRecivedBills = true
    elseif GetRecivedBills then
        BillsPage4:UnRegister()
    end
    BillsPage4 = Bills:RegisterPage('seite2')
    BillsPage4:RegisterElement('header', {
        value = _U('SendetBillsHeader'),
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage4:RegisterElement('line', {
        slot = 'header',
        style = {
        ['color'] = 'orange',
        }
    })
    for h,v in ipairs(ReciveGottenBills) do
    local ButtonLabel = _U('BillFrom') .. v.fromname .. _U('BillReason2') .. v.reason .. _U('BillAmount2') .. v.amount .. '$ ' .. _U('Company') .. v.joblabel
        BillsPage4:RegisterElement('button', {
            label = ButtonLabel,
            style = {
                ['background-color'] = '#FF8C00',
                ['color'] = 'orange',
                ['border-radius'] = '6px'
                },
            }, function()
            local BillID = v.id
            local ToCompany = v.job
            local Amount = v.amount
            TriggerServerEvent('mms-society:client:PayThisBill',BillID,ToCompany,Amount)
        end)
    end
    BillsPage4:RegisterElement('button', {
        label =  _U('BillsBack'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        BillsPage1:RouteTo()
    end)
    BillsPage4:RegisterElement('button', {
        label =  _U('CloseBoardBills'),
        style = {
        ['background-color'] = '#FF8C00',
        ['color'] = 'orange',
        ['border-radius'] = '6px'
        },
    }, function()
        Bills:Close({})
    end)
    BillsPage4:RegisterElement('subheader', {
        value = _U('BillsBoardHeader'),
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage4:RegisterElement('line', {
        slot = 'footer',
        style = {
        ['color'] = 'orange',
        }
    })
    BillsPage4:RouteTo()
end)