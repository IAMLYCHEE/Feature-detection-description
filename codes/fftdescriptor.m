

function descriptor = fftdescriptor(filepath,keypoints) 
% 

% 
% map = [0,0,0;
%     0.25,0,0;
%     0.5,0,0;
%     0.75,0,0;
%     1,0,0;
%     1,0.25,0;
%     1,0.5,0;
%     1,0.75,0;
%     1,1,0;
%     1,1,0.25;
%     1,1,0.5;
%     1,1,0.75;
%     1,1,1];

% clear
% % extract the circle region of interest around the keypoints 
img = rgb2gray(imread(filepath));
size_keypoints = size(keypoints);
amount = size_keypoints(1);
img_size = size(img);

for i_d = 1 : amount
    data = keypoints(i_d,:);
    r = ceil(data(3));
    dia = 2*r + 1;
    [X,Y] = meshgrid(1:dia,1:dia);
    % img_ori = rgb2gray(imread('test15X15.png'));
    % extract the square region around the keypoint
    x = keypoints(i_d,1);
    y = keypoints(i_d,2);
    img_sregion = zeros(dia,dia);
    for k = 1 : dia
        for j = 1 : dia 
         if ((x-r +k -1) <= img_size(1)) && ((y - r + j -1) <= img_size(2)) ...
                 && ((x-r+k-1)>0)  && ((y - r + j -1)>0)
             
            img_sregion(k,j) = img(x - r + k - 1,y - r + j - 1);
         else
            img_sregion(k,j) = 0;
         end
        end
    end
    img_ori_cregion = double(img_sregion) .* double((fspecial('disk',r) > 0 ));

    % % extract the frequency data from the region
    f_img_c = fftshift(abs(fft2(img_ori_cregion)));

    % % linear interpolation to extend the information
    if mod(length(1:dia/50:dia),2) == 0
        [Xq,Yq] = meshgrid(1:dia/50:dia+dia/50, 1:dia/50:dia+dia/50);
    else
        [Xq,Yq] = meshgrid(1:dia/50:dia, 1:dia/50:dia);
    end
    f_img_c = interp2(X,Y,f_img_c,Xq,Yq);
    
%     mesh(Xq,Yq,f_img_c);
%     colormap(map);
%     mesh(Xq,Yq,Vq);
    % figure 
    % mesh(X,Y,V);

    %low pass filter
%     f_img_c;
    r = (length(Xq)-1)/2;
    f_img_c_l = f_img_c .* double((fspecial('disk',r) > 0 ));
    f_img_c_l(isnan(f_img_c_l) == 1) = 0;
%     f_img_c_l
    center = r + 1;

    % calculate the sum of f_img_c along diameter
    sum_dia = zeros(1,18);
    theta = 10;
    x = zeros(1,15);
    y = zeros(1,15);
    r = r - 1;
    for i = 0: 17
        for j = 0: 14
            x(j+1) = -(r-j*r/7)*cos(i*theta) + center; 
            x(j+1) = round(x(j+1));
            y(j+1) = (r - j*r/7)*sin(i*theta) + center;
            y(j+1) = round(y(j+1));
            sum_dia(i+1) = sum_dia(i+1) + f_img_c_l(x(j+1),y(j+1)); 
        end
    end
%     f_img_c_l
%     sum
    [y_max,index_ma] = max(sum_dia);
    [y_min,index_mi] = min(sum_dia);
    descriptor(i_d,:) = [sum_dia(index_ma:18),sum_dia(1:index_ma-1)] ./ y_max;
end


