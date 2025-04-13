local oxmysql = exports.oxmysql

lib.callback.register('jobCreator:fetchJobs', function()
    return oxmysql:executeSync('SELECT * FROM jobs')
end)

lib.callback.register('jobCreator:fetchJobGrades', function(_, jobName)
    return oxmysql:executeSync('SELECT * FROM job_grades WHERE job_name = ? ORDER BY grade ASC', { jobName })
end)

RegisterServerEvent('jobCreator:addJob', function(data)
    oxmysql:insert('INSERT INTO jobs (name, label, whitelisted) VALUES (?, ?, ?)', {
        data.name, data.label, data.whitelisted and 1 or 0
    })
end)

RegisterServerEvent('jobCreator:editJob', function(data)
    oxmysql:update('UPDATE jobs SET label = ?, whitelisted = ? WHERE name = ?', {
        data.label, data.whitelisted and 1 or 0, data.name
    })
end)

RegisterServerEvent('jobCreator:removeJob', function(name)
    oxmysql:execute('DELETE FROM jobs WHERE name = ?', { name })
    oxmysql:execute('DELETE FROM job_grades WHERE job_name = ?', { name })
end)

RegisterServerEvent('jobCreator:addGrade', function(data)
    local jobName = data.job_name
    local offJobName = 'off' .. jobName

    oxmysql:insert('INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        jobName, data.grade, data.name, data.label, data.salary, data.skin_male, data.skin_female
    })

    local result = oxmysql:executeSync('SELECT name FROM jobs WHERE name = ?', { offJobName })
    if not result or #result == 0 then
        oxmysql:insert('INSERT INTO jobs (name, label, whitelisted) VALUES (?, ?, ?)', {
            offJobName, '[OFF] ' .. data.job_name, 0
        })
    end

    local gradeExists = oxmysql:executeSync('SELECT id FROM job_grades WHERE job_name = ? AND grade = ?', { offJobName, data.grade })
    if not gradeExists or #gradeExists == 0 then
        oxmysql:insert('INSERT INTO job_grades (job_name, grade, name, label, salary, skin_male, skin_female) VALUES (?, ?, ?, ?, ?, ?, ?)', {
            offJobName, data.grade, data.name, '[OFF] ' .. data.label, 0, data.skin_male, data.skin_female
        })
    end
end)

RegisterServerEvent('jobCreator:editGrade', function(data)
    oxmysql:update('UPDATE job_grades SET name = ?, label = ?, salary = ?, skin_male = ?, skin_female = ? WHERE id = ?', {
        data.name, data.label, data.salary, data.skin_male, data.skin_female, data.id
    })
end)

RegisterServerEvent('jobCreator:removeGrade', function(id)
    oxmysql:execute('DELETE FROM job_grades WHERE id = ?', { id })
end)