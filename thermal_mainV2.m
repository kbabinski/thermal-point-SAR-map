%% 
%***************************************************************************************
%    Title: Thermal Image SAR Map Algorithm
%    Author: Kristina Babinski
%    Date: 2017
%    Organization: University of Maryland UAS Test Site
%**************************************************************************************/
%% 
close all;
clear variables;
clc;
format long; format compact;
%% Read in ALL data

% The file form the Bad Elf GPS logger goes below
fileID = fopen('06302017_UMD1.gpx','r');
% The folder where the images are is referenced below with
% " 'C:\Users\sherrita\Desktop\20170630_UMD1' " format
myFolder = 'C:\Users\sherrita\Desktop\20170630_UMD1';


%% Read in all of the image files, write the images to an image array, binarize images, true/false POI, and write 'Time' of image and ID to tables

% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(myFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.JPG'); % Change to whatever pattern you need.
theFiles = dir(filePattern);
for j = 1 : length(theFiles)
  baseFileName = theFiles(j).name;
  fullFileName = fullfile(myFolder, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Read in image array 
  imageArray = imread(fullFileName);
  Igray= rgb2gray(imageArray);
  level = .90;
  Ibinary = imbinarize (Igray, level);
  %imshow (Ibinary);
  B = bwboundaries(Ibinary);
  A = bwarea (Ibinary);
    if (A > 100)
        ID = 1;
        disp ('There is a point of interest in this image');
    else 
        disp ('There is NO point of interest in this image');
        ID = 0;
    end
    info = imfinfo(fullFileName);
    imageDate = info.FileModDate;
    % Image time needs to be changed to zulu time to correspond with GPS info
    imageDateLocal = datetime(imageDate,'TimeZone','America/New_York');
    imageDateLocal.TimeZone = 'Atlantic/Reykjavik'; %This line changes it to zulu time to correspond with .gpx data
    %Time zone may need to be altered based on daylight savings. Confirm
    %change in "imageDateLocal" variable in workspace. To search for other
    %variables type timezones ('America') or timezones ('Atlantic') etc.
    %into command window
    formatOut = 'HH:MM:SS';
    imageDateZuluFormat = datestr(imageDateLocal,formatOut);
    tableA(j,:) = [imageDateZuluFormat]; %Times when each image was captured
    tableB(j,:) = [ID]; %corresponding 'ID' for each image (1 = POI, 0 = no POI)
  drawnow; % Force display to update immediately.
end

%% Concatenate tables with image 'Time' and 'ID'

str = cellstr(tableA);
tableA1 = table(str)
tableB1 = table(tableB);
tableA1.Properties.VariableNames = {'Time'};
tableB1.Properties.VariableNames = {'ID'};
tableC = horzcat(tableA1, tableB1);

%% Read in .gpx file and place necessary data into cells

%***************************************************************************************
%    Author: Mathew Vaugn
%    Date: 6/20/2017
%**************************************************************************************/
transpose_data = fopen('extracted_data.csv','wt');
line = fgets(fileID);
regex = '^<trkpt lat="(-?\d+\.\d+)" lon="(-?\d+\.\d+)"><ele>\d+\.\d+</ele><time>(\d{4}-\d{2}-\d{2})T(\d+:\d+:\d+).*$'
while(line ~= -1)
    [tokens matches] = regexp(line,regex,'tokens','match')
    %store the info somehow
    if ~isempty(tokens)
        fprintf(transpose_data,'%s,%s,%s,%s\n',tokens{1}{1,:});
    end
    line = fgets(fileID);
end
fclose(fileID);
fclose(transpose_data);

%% Read in extracted_data.csv file, create table with row names

table = readtable('extracted_data.csv');
table.Properties.VariableNames = {'Lat' 'Lon' 'Date' 'Time'};

%% Use a regular expression to pull the row out of a table that contains the same expression as variable imageDateZuluFormat

collected_index = 0;
for m = 1 : size(tableC)
    temp = tableC.Time(m);
    temp2 = tableC.ID(m);
    Lia = ismember(table.Time, temp);
    RowIdx = find(Lia);
    if(not(isempty(RowIdx)))
        collected_index = collected_index + 1;
        rows = RowIdx;
        vars = 'Lat';
        lat = table{rows, vars};
        vars2 = 'Lon';
        lon = table{rows, vars2};
        new_table{collected_index,1} = lat;
        new_table{collected_index,2} = lon;
        new_table{collected_index,3} = temp;
        new_table{collected_index,4} = temp2;
    end
end 

new_table = cell2table(new_table);
toDelete = new_table.new_table4 == 0;
new_table(toDelete,:) = [];
new_table.Properties.VariableNames = {'Lat' 'Lon' 'Time' 'ID'};

%% limLat = [min(Lat) max(Lat)];

latLonCounter = 0;
webmap('Open Street Map');
for d = 1: size(new_table)
    wmmarker(new_table.Lat(d), new_table.Lon(d));
    latLonCounter = latLonCounter + 1;
    %description = sprintf('%f<br>%f</br>', lat, lon);
    %wmmarker(lat, lon, 'Description', description)
end


