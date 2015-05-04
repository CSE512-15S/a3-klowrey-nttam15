function grab_temp(directory, chance, outfile)

filenames=dir(strcat(directory,'*.nc'));
strcat(directory,filenames(1).name)
lat = ncread(strcat(directory,filenames(1).name), 'lat');
lon = ncread(strcat(directory,filenames(1).name), 'lon');

sst = zeros(length(lon), length(lat));
bin = 0;
idx = 1;
% for i = 1:length(filenames)
%     sst = sst + ncread(filenames(i), 'sst');
%     bin = bin + 1;
%     
%     if bin >= 5
%         sst_all(:,:,idx) = sst ./ 5.0;
%         idx = idx + 1;
%         % the 5day average, we hope!
%         sst = zeros(length(lon), length(lat));
%     end
% end

for f=filenames'
    sst_all(:,:,idx) = ncread(strcat(directory,f.name), 'sst');
    idx = idx + 1;
end

display(idx);

nans=0;
index=0;
s = size(sst_all);
t = zeros(length(lat)*length(lon),s(3) + 2);

s1 = 15;
index = 0;
j = 60:s1:(length(lat)-61);
l = length(lon);
mid = j(round(length(j)/2));
func = -abs(j-mid);
func = func - min(func) + 75;
count = 1;
for j = 60:s1:(length(lat)-61)
    skip=round(l/func(count) * 2);
    if skip > 15
        skip = 15;
    end
    count = count + 1;
    for i = 1:skip:l
        if isnan(sst_all(i, j, 1))
            % discard
            nans = nans + 1;
        else
            %if rand < chance
            index = index+1;
            
            t(index,:) = [ lon(i) lat(j) reshape(sst_all(i,j,:), [1, s(3)])];
            
            %end
        end
    end
end

t = t(1:index,:);
addpath('/home/klowrey/Dropbox/utils/jsonlab/');

display(index)

tic
json = struct('type','FeatureCollection');
json.features = cell(1,index);
for i = 1:index
    json.features{1,i} = struct('type','Feature');
    json.features{1,i}.geometry = struct('type','Point');
    json.features{1,i}.geometry.coordinates = t(i,1:2);
    json.features{1,i}.geometry.temp = t(i,3:end);
end
toc
tic
jsonfile = savejson('', json, outfile);
toc


