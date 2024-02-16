classdef OpeningCharacteristics < int32
% Enumeration class for the orifice opening characteristics options.

% Copyright 2022 The MathWorks, Inc.

enumeration
    Linear(1)
    Tabulated(2)
end

methods (Static, Hidden)
    function map = displayText()
        map = containers.Map;
        map('Linear')    = 'Linear';
        map('Tabulated') = 'Tabulated';
    end
end
end