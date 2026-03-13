---@meta

---Object oriented bounding box
---@class OOBB: ScriptReference
---@field type_name "OOBB"
OOBB = {}

function OOBB:area(...) end

---@return number
function OOBB:center() end

function OOBB:corner(...) end

function OOBB:debug_draw(...) end

function OOBB:distance_to_point(...) end

function OOBB:edge(...) end

function OOBB:grow(...) end

function OOBB:point_inside(...) end

function OOBB:principal_distance(...) end

function OOBB:quad_on_plane(...) end

function OOBB:raycast(...) end

function OOBB:shrink(...) end

---@return { x: number, y: number, z: number }
function OOBB:size() end

function OOBB:to_local(...) end

function OOBB:volume(...) end

---@return number
function OOBB:x() end

---@return number
function OOBB:y() end

---@return number
function OOBB:z() end
