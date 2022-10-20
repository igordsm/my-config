local M = {}

function M.list_tags()
    local proc = io.popen([[grep -Poh "\[\[ [\w\d\-]+ \]\]" -r data/]])

    local tagset = {}
    for line in proc:lines() do
        if tagset[line] == nil then
            tagset[line] = true
        end
    end
    
    table.sort(tagset)

    tags = {}
    for k, _ in pairs(tagset) do
        table.insert(tags, k)
    end


    return tags
end

return M
