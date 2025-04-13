RegisterCommand('jobmenu', function()
    openJobList()
end)

function openJobList()
    lib.callback('jobCreator:fetchJobs', false, function(jobs)
        local options = {}

        for _, job in pairs(jobs) do
            table.insert(options, {
                title = job.label,
                icon = 'briefcase',
                metadata = {
                    {label = 'Job', value = job.name},
                    {label = 'Whitelisted', value = job.whitelisted == 1 and 'Ya' or 'Tidak'}
                },
                menu = 'job_manage_' .. job.name,
                arrow = true
            })

            lib.registerContext({
                id = 'job_manage_' .. job.name,
                title = 'Kelola Job: ' .. job.label,
                menu = 'job_list_menu',
                options = {
                    {
                        title = 'Edit Job',
                        icon = 'pen',
                        onSelect = function() editJob(job) end
                    },
                    {
                        title = 'Hapus Job',
                        icon = 'trash',
                        onSelect = function() deleteJob(job.name) end
                    },
                    {
                        title = 'Kelola Grade',
                        icon = 'list',
                        onSelect = function() openGradesForJob(job.name) end
                    }
                }
            })
        end

        table.insert(options, {
            title = 'Tambah Job Baru',
            icon = 'plus',
            onSelect = addJob
        })

        lib.registerContext({
            id = 'job_list_menu',
            title = 'Daftar Job',
            options = options
        })

        lib.showContext('job_list_menu')
    end)
end

function addJob()
    local input = lib.inputDialog('Tambah Job Baru', {
        {type = 'input', label = 'Job Name (lowercase)', required = true},
        {type = 'input', label = 'Label', required = true},
        {type = 'checkbox', label = 'Whitelisted'}
    })

    if input then
        TriggerServerEvent('jobCreator:addJob', {
            name = input[1],
            label = input[2],
            whitelisted = input[3]
        })
    end
end

function editJob(job)
    local input = lib.inputDialog('Edit Job: ' .. job.label, {
        {type = 'input', label = 'Label', required = true, default = job.label},
        {type = 'checkbox', label = 'Whitelisted', checked = job.whitelisted == 1}
    })

    if input then
        TriggerServerEvent('jobCreator:editJob', {
            name = job.name,
            label = input[1],
            whitelisted = input[2]
        })
    end
end

function deleteJob(name)
    local confirm = lib.alertDialog({
        header = 'Hapus Job',
        content = 'Yakin ingin menghapus job ini?',
        cancel = true
    })

    if confirm == 'confirm' then
        TriggerServerEvent('jobCreator:removeJob', name)
    end
end

function openGradesForJob(jobName)
    lib.callback('jobCreator:fetchJobGrades', false, function(grades)
        local options = {}

        for _, grade in pairs(grades) do
            table.insert(options, {
                title = ('%d - %s'):format(grade.grade, grade.label),
                icon = 'star',
                metadata = {
                    {label = 'Name', value = grade.name},
                    {label = 'Salary', value = grade.salary}
                },
                menu = 'grade_manage_' .. grade.id,
                arrow = true
            })

            lib.registerContext({
                id = 'grade_manage_' .. grade.id,
                title = 'Kelola Grade',
                menu = 'job_grade_menu_' .. jobName,
                options = {
                    {
                        title = 'Edit Grade',
                        icon = 'pen',
                        onSelect = function() editGrade(jobName, grade) end
                    },
                    {
                        title = 'Hapus Grade',
                        icon = 'trash',
                        onSelect = function() deleteGrade(grade) end
                    }
                }
            })
        end

        table.insert(options, {
            title = 'Tambah Grade Baru',
            icon = 'plus',
            onSelect = function() addGrade(jobName) end
        })

        lib.registerContext({
            id = 'job_grade_menu_' .. jobName,
            title = 'Grade untuk: ' .. jobName,
            menu = 'job_list_menu',
            options = options
        })

        lib.showContext('job_grade_menu_' .. jobName)
    end, jobName)
end

function addGrade(jobName)
    local input = lib.inputDialog('Tambah Grade untuk: ' .. jobName, {
        {type = 'number', label = 'Grade', required = true},
        {type = 'input', label = 'Name', required = true},
        {type = 'input', label = 'Label', required = true},
        {type = 'number', label = 'Gaji', required = true}
    })

    if input then
        TriggerServerEvent('jobCreator:addGrade', {
            job_name = jobName,
            grade = input[1],
            name = input[2],
            label = input[3],
            salary = input[4],
            skin_male = '{}',
            skin_female = '{}'
        })
    end
end

function editGrade(jobName, grade)
    local input = lib.inputDialog('Edit Grade: ' .. grade.label, {
        {type = 'input', label = 'Name', required = true, default = grade.name},
        {type = 'input', label = 'Label', required = true, default = grade.label},
        {type = 'number', label = 'Gaji', required = true, default = grade.salary}
    })

    if input then
        TriggerServerEvent('jobCreator:editGrade', {
            id = grade.id,
            name = input[1],
            label = input[2],
            salary = input[3],
            skin_male = grade.skin_male,
            skin_female = grade.skin_female
        })
    end
end

function deleteGrade(grade)
    local confirm = lib.alertDialog({
        header = 'Hapus Grade',
        content = 'Yakin ingin menghapus grade ini?',
        cancel = true
    })

    if confirm == 'confirm' then
        TriggerServerEvent('jobCreator:removeGrade', grade.id)
    end
end