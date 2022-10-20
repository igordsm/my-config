local M = {}

local all_projects = {}
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

    return text, date, taglist, project
end

function parse_file(filename)
    local f = io.open(filename, "r")

    local current_project = "(empty)"

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
                taglist = taglist;
            }

            table.insert(tasklist, new_task)
            all_projects[current_project] = true
        end

    end
end

function M.parse_all_tasks()
    local files = M.files()

    for _, f in pairs(files) do
        parse_file(f)
    end
end

function task_to_string(tsk)
    return "" .. tsk.descr .. " due " .. tsk.date .. " in " .. tsk.origin
end

function M.get_all_tasks()
    local tasks = {}

    for _, v in pairs(tasklist) do
        table.insert(tasks, task_to_string(v))
    end

    return tasks
end

function M.get_tasks_from_project(projname)
    local tasks = {}
    projname = slugify(projname)

    for _, v in pairs(tasklist) do
        if v.taglist[projname] then
            table.insert(tasks, task_to_string(v))
        end
    end

    return tasks
end



local Menu = require("nui.menu")

function M.ui_choose_project(callback)
    local itens = {}

    for k, _ in pairs(all_projects) do
        table.insert(itens, Menu.item(k))
    end

    local menu = Menu({
        position = "50%",
        size = {
            width = 55,
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
        max_width = 40,
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
