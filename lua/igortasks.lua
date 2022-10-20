local M = {}

function M.list_tasks()
    local proc = io.popen([[grep -Poh "\- \[[ xX]\].*" -r data/]])

    local tasks = {}
    local lines = {}
    for line in proc:lines() do
        local _, _, checkmark, text = string.find(line, "%[([xX ])%](.*)")
        local tsk = {
            done = checkmark ~= " ";
            text = text;
        }
        table.insert(tasks, tsk)
        table.insert(lines, line)
    end
    
    return tasks, lines
end

return M
