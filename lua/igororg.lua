local M = {}

M.all_projects = {}
local tasks_by_tag = {}
local tasklist = {}

function M.files()
    local proc = io.popen("find data/*.md")

    local f = {}
    for l in proc:lines() do
        table.insert(f, l)
    end

    return f
end

function slugify(text) 
    local t = text:lower()
    t = string.gsub(t, " ", "-")
    return t
end

function parse_task_text(text, project)
    local _, _, date = text:find("(%(%d%d/%d%d%))")
    text = text:gsub("%(%d%d/%d%d%)", "")
    if date == nil then 
        date = ""
    end

    local taglist = {}
    taglist[project] = true

    local tag_pattern = [=[%[%[%s?([%w-_]+)%s?%]%]]=]
    repeat 
        local _, end_data, data = text:find(tag_pattern)
        if data == nil then
            break
        end
        taglist[data] = true
    until true

    text = text:gsub(tag_pattern, "")
    text = text:gsub("%s+", " ")

    return text, date, taglist, project
end

function parse_file(filename)
    local f = io.open(filename, "r")

    local current_project = "(empty)"

    local linenum = 1
    for l in f:lines() do
        local _, _, proj_name = l:find("### (.*)")
        local _, _, checkmark, text = l:find( "%[([xX ])%](.*)")

        if proj_name ~= nil then
            current_project = slugify(proj_name)
        elseif checkmark ~= nil and text ~= nil then
            local descr, date, taglist = parse_task_text(text, current_project)

            local new_task = {
                done = checkmark ~= " ";
                descr = descr;
                date = date;
                origin = filename;
                linenum = linenum;
                taglist = taglist;
            }
            new_task.to_string = M.task_to_string(new_task)

            table.insert(tasklist, new_task)
            M.all_projects[current_project] = true
        end
        linenum = linenum + 1
    end
end

function M.update_file(filename)
    for i=#tasklist,1,-1 do
        if tasklist[i].origin == filename then
            table.remove(tasklist, i)
        end
    end

    parse_file(filename)
end


function M.parse_all_tasks()
    local files = M.files()

    for _, f in pairs(files) do
        parse_file(f)
    end
end

function M.task_to_string(tsk)
    return tsk.descr .. " due " .. tsk.date .. " in " .. tsk.origin
end

function M.get_all_tasks()
    local tasks = {}

    for _, v in pairs(tasklist) do
        table.insert(tasks, M.task_to_string(v))
    end

    return tasks
end

function M.get_tasks_by(filterfunc)
    local tasks = {}

    for _, v in pairs(tasklist) do
        if filterfunc(v) then
            tasks[M.task_to_string(v)] = v
        end
    end

    return tasks
end


function M.get_tasks_from_project(projname, filterfunc)
    local tasks = {}
    projname = slugify(projname)
    
    if filterfunc == nil then
        filterfunc = function(v) return true end
    end

    for _, v in pairs(tasklist) do
        if v.taglist[projname] and filterfunc(v) then
            tasks[M.task_to_string(v)] = v
        end
    end

    return tasks
end



local Menu = require("nui.menu")

function M.ui_choose(options, callback)
    local itens = {}

    if options[1] ~= nil then
        for k, v in pairs(options) do
            table.insert(itens, Menu.item(v, {key = k, value = v}))
        end
    else
        for k, v in pairs(options) do
            table.insert(itens, Menu.item(k, {key = k, value = v}))
        end
    end

    local menu = Menu({
        position = "50%",
        size = {
            width = 75,
            height = 15,
        },
        border = {
            style = "single",
            text = {
                top = "[Choose-Project]",
                top_align = "center",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal,FloatBorder:Normal",
        },
    }, {
        lines = itens,
        max_width = 75,
        keymap = {
            focus_next = { "j", "<Down>", "<Tab>" },
            focus_prev = { "k", "<Up>", "<S-Tab>" },
            close = { "<Esc>", "<C-c>" },
            submit = { "<CR>", "<Space>" },
        },
        on_close = function()
        end,
        on_submit = function(item)
            callback(item)
        end,
    })

    -- mount the component
    menu:mount()    
end

return M
