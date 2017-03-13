function report = runUnitTest(file)
%runUnitTest   Simulink Project batch job for running MATLAB unit tests
%
% Input arguments:
%  file - string - The absolute path to a MATLAB unit test.
%  When you run this function as a batch job, the Simulink Project Tool 
%  provides the file input for each selected file. 
%
% Output arguments:
%  report - string - A summary report of the test results. The Simulink 
%  Project Tool displays this result in the Batch Job Results panel.
%
% Copyright 2013 The MathWorks, Inc.


project = slproject.getCurrentProject;
projectFile = project.findFile(file);

% Check that the file is labelled as a test.
if isempty(projectFile.findLabel('Classification', 'Test'))
    report = 'Not labelled as a test';
else
    report = runTest(file);
end

end

function report = runTest(file)
% Run the MATLAB unit test and create a summary report.

report = ['<b>Test:</b> ' file '<br>'];
test = matlab.unittest.TestSuite.fromFile(file);
results = test.run();

passed = results([results.Passed]);
report = [report createReport('Passed', 'green', passed)];

incomplete = results([results.Incomplete]);
report = [report createReport('Incomplete', 'blue', incomplete)];

failed = results([results.Failed]);
report = [report createReport('Failed', 'red', failed)];

report = [report '<br>Total time = ' num2str(sum([results.Duration])) 's'];

end

function report = createReport(status, color, results)
% Create a report for a set of test results.

if ~isempty(results)
    report = ['<br><b><font color="' color '">' status ':</font></b><br>'];
    for n=1:length(results)
        report = [report results(n).Name ' (' num2str(results(n).Duration) 's)<br>'];  %#ok<AGROW>
    end
else
    report = '';
end

end
