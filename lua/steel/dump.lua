local inspect = require("inspect")

function _G.dump(...)
    for _, ctx in pairs({ ... }) do
        print(inspect(ctx))
    end
end
