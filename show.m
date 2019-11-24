clear;
close all;
fclose all;
%%
load('human_colormap.mat');
data_root_folder = './human/data';
output_mat_folder = fullfile('./human/features/attention/val/fc8_mask');
save_result_folder = fullfile('./human/features/attention/val/results');
if ~exist(save_result_folder, 'dir')
    mkdir(save_result_folder);
end
output_dir = dir(fullfile(output_mat_folder, '*.mat'));
for i = 1 : numel(output_dir)
    if mod(i, 100) == 0
        fprintf(1, 'processing %d (%d)...\n', i, numel(output_dir));
    end
    data = load(fullfile(output_mat_folder, output_dir(i).name));
    raw_result = data.data;
    raw_result = permute(raw_result, [2 1 3]);

    img_fn = output_dir(i).name(1:end-4);
    img_fn = strrep(img_fn, '_blob_0', '');
    image_path = fullfile(data_root_folder, 'images', [img_fn, '.jpg']);
    if exist(image_path, 'file') ~= 2
        image_path = fullfile(data_root_folder, 'images', [img_fn, '.png']);
    end
    assert(exist(image_path, 'file') == 2,...
        ['image does not exist: ' image_path]);
    img = imread(image_path);

    % img_row = size(img, 1);
    % img_col = size(img, 2);

    % XXX: Verify that this makes sense.
    % Use minimum size between labelled image and input image.
    img_size = min(size(img)(1:2), size(raw_result));
    img_row = img_size(1);
    img_col = img_size(2);

    result = raw_result(1:img_row, 1:img_col);
    mask = uint8(result);
    imwrite(mask, colormap, fullfile(save_result_folder, [img_fn, '.png']));
end

      
