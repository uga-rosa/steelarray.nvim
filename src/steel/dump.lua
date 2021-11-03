local inspect = require("inspect")

function _G.dump(...)
    for _, ctx in ipairs({ ... }) do
        print(inspect(ctx))
    end
end
