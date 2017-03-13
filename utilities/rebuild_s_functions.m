function rebuild_s_functions(show_progress_option)
%rebuild_s_functions  Rebuild the S-Functions required by this project
%
%   Simple utility to rebuild the S-Functions required by this project. 
%   This is implemented as a function, not as a script, to avoid adding
%   unwanted variables to the MATLAB base workspace.

%   Copyright 2011-2014 The MathWorks, Inc.

% Give the user an indication of progress:
if nargin < 1
    show_progress_option = 'show_progress';
end    
i_waitbar(0, 'Building S-Functions...', show_progress_option);

% Use Simulink Project API to get the current project:
project = simulinkproject;
projectRoot = project.RootFolder;

% We keep the source files for this project in $projectroot/src:
sourceFolder = fullfile(projectRoot, 'src');
% We put the compiled binaries in the local "work" folder:
outputFolder = fullfile(projectRoot, 'work');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder)
end
oldFolder = cd(sourceFolder);

% Use onCleanup to ensure we cd back to the current folder:
scopedCleanFuncion = onCleanup(@()cd(oldFolder));

% Since we have just one S-Function we can hard-code its name here.
i_waitbar(0.5, 'Building S-Functions...', show_progress_option);
mexCommand = sprintf('mex timesthree.c -outdir ''%s''', outputFolder);
try
    eval(mexCommand)
catch E
    % Something went wrong with compilation. Report to the user and stop.
    i_waitbar(1, ...
        ['Failed to build S-Functions:', char(10), E.message], ...
        show_progress_option);
    return
end

% Report success and close the progress bar:
i_waitbar(1, 'Successfully built S-Functions', show_progress_option);
i_waitbar(-1, [], show_progress_option);
end

function i_waitbar(progress, message, show_progress)
% Thin wrapper on waitbar
if strcmp(show_progress, 'no_progress_dialog')
    return
end
persistent h
if progress < 0
    % Close the waitbar, if it still exists, after a short pause to give 
    % the user chance to see the last message
    if ~isempty(h) && ishandle(h)
        pause(1.5)
        close(h)
    end
    return
end
if isempty(h) || ~ishandle(h)
    h = waitbar(progress, message, 'name', 'Building S-Functions');
    return
end
waitbar(progress, h, message);
end

