clear all; close all; clc

dataFileName = "shakeFlaskData";
dataSheetName = "Exp2";
% dataSheetNames = {'Exp1', 'Exp2', 'Exp3'};
% 
% % Initialize an empty matrix to store the concatenated data
% createdExpData2Table = [];
% 
% % Iterate over each sheet
% for i = 1:numel(dataSheetNames)
%     % Read the data from the current sheet
%     data = readtable(dataFileName, 'Sheet', dataSheetNames{i});
%     
%     % Concatenate the data vertically
%     createdExpData2Table = vertcat(createdExpData2Table, data);
% end
createdExpData2Table = readtable(dataFileName,"Sheet",dataSheetName);

% Extract variable name from the table. If a column deos not have a name, corresponding column number is assigned!
% Get the number of columns in the table
numOfColumns = size(createdExpData2Table, 2);
% Assign names to columns without names and use existing names for others
for i = 1:numOfColumns
    if isempty(createdExpData2Table.Properties.VariableNames{i})
        createdExpData2Table.Properties.VariableNames{i} = ['column' num2str(i)];
    end
end
columnNames = createdExpData2Table.Properties.VariableNames;

% Separate time table name from variable table names from columnNames%Extract names for variables (that is, remove time)
timeColumnName = columnNames{1};
timeColumnUnit = 'h';
variableColumnNames = columnNames(2:end);%{columnNames{2:end}};
variableColumnNames = cell2mat(variableColumnNames);
variableColumnUnits = ['g/L','g/L','g/L']; % {'g/L','g/L','g/L'};

% Create the xlabel and ylabel using the extracted values
xlabelStr = sprintf('%s (%s)', timeColumnName, timeColumnUnit);
ylabelStr = sprintf('%s (%s)', variableColumnNames, variableColumnUnits);

% State variables considered here are:
% c(1) = Biomass concentration, g/L
% c(2) = First substrate concentration, g/L
% c(3) = Second substrate concentration, g/L

% tExpData = createdExpData2Table{timeColumnName};%columnNames{1};
% cExpDataBiomass = createdExpData2Table{variableColumnNames};%columnNames{2:end};
tExpData = createdExpData2Table.Time;%{timeColumnName};%columnNames{1};
cExpDataBiomass = createdExpData2Table.Biomass;
cExpDataSubstrate1 = createdExpData2Table.Substrate1;
cExpDataSubstrate2 = createdExpData2Table.Substrate2;
cExpData = [cExpDataBiomass,cExpDataSubstrate1,cExpDataSubstrate2];

% Supply Ks1 and Ks2 model supposedly known parameter
Ks1 = 1e-1;
Ks2 = 5e5;

% Define initial condition
cinit = cExpData(1,:);

% Define inputs to lsqcurvefit:
simFun = @(theta,t)mySim(theta,t,cinit,Ks1,Ks2);
theta0 = [1,1,1,1];
lb = zeros(1,length(theta0));
ub = ones(1,length(theta0));
optionsOptim = [];

tic
[theta,Rsdnrm,Rsd,ExFlg,OptmInfo,Lmda,Jmat] = lsqcurvefit(simFun,theta0,tExpData,cExpData,lb,ub,optionsOptim);
toc

% Simulate with optimal theta
tSimData = (linspace(min(tExpData), max(tExpData)))'; % This forms my tspan
%tSimData = (linspace(min(tExpData), 20))'; % This forms my tspan
tspan = tSimData;
cSimData = mySim(theta,tspan,cinit,Ks1,Ks2);

% Plot results
for i = 1:size(cSimData,2)
    subplot(1,3,i)
    plot(tExpData,cExpData(:,i),'o',tSimData,cSimData(:,i))
    xlabel(xlabelStr);%xlabel(timeColumnName, timeColumnUnit)
    ylabel(ylabelStr(i));%ylabel(variableColumnNames{i}, variableColumnUnits{i})
end

% Simulation function here:
function c = mySim(theta,t,cinit,Ks1,Ks2)
odeFun = @(t,c,theta)shakeFlaskModel(t,c,theta,Ks1,Ks2);
optionsSim = [];
[~,c] = ode45(odeFun,t,cinit,optionsSim,theta);
end