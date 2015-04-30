%function grab_nc(filename, stride, outfile)

lat = ncread(filename, 'latitude');
lon = ncread(filename, 'longitude');

uf = squeeze(ncread(filename, 'uf'));
vf = squeeze(ncread(filename, 'vf'));

s = size(uf);
f_uf = zeros(length(lat)*length(lon),s(3) + 2);
f_vf = zeros(length(lat)*length(lon),s(3) + 2);
nans=0;
index=0;
for i = 1:stride:length(lon)
    for j = 1:stride:length(lat)
        if isnan(uf(i, j, 1))
            % discard
            nans = nans + 1;
        else
            index = index+1;
            
            f_uf(index, :) = [ lon(i) lat(j) reshape(uf(i,j,:), [1, s(3)])];
            f_vf(index, :) = [ lon(i) lat(j) reshape(vf(i,j,:), [1, s(3)])];
%             f_uf(index, 2) = lat(j);
%             f_uf(index, 3:end) = uf(i,j,:);
        end
    end
end

f_uf = f_uf(1:index, :);
f_vf = f_vf(1:index, :);

display(nans)
display(index)

% presumes jsonlab is installed
tic
json = struct('type','FeatureCollection');
json.features = cell(1,index);
for i = 1:index
    json.features{1,i} = struct('type','Feature');
    json.features{1,i}.geometry = struct('type','Point');
    json.features{1,i}.geometry.coordinates = f_uf(i,1:2);
    json.features{1,i}.geometry.uf = f_uf(i,3:end);
    json.features{1,i}.geometry.vf = f_vf(i,3:end);
end
toc
tic
jsonfile = savejson('', json, outfile);
toc

