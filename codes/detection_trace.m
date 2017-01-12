function H = blob_detection_trace(file_path,t_step,t_max)
% usage: blob_detection_trace(file_path)
% blob detection with automatic scale selection by trace
% l.y.c.liyicheng@gmail.com

src = imread(file_path);
src = rgb2gray(src);
src_ori = src;
% src = imread('dot.png');
src = double(src);
img_size = size(src);
% candidate_matrix = zeros(size(1) , size(2));
count = 0;



for t = 1: t_step : t_max
    sigma = exp(t);
    H = fspecial('log',ceil(7*sigma),exp(t));
    src_LoG = (imfilter(src, H*(sigma^2), 'conv')).^2;
    
%  -----------------------------------    
% edge response
    sigma = exp(t);
    radius = 1.5*sigma;
    H = fspecial ( 'gaussian', ceil(6*sigma) , sigma );
    l_src = imfilter ( src, H, 'conv');
    hessian_matrix_det = dethessian(l_src);
    hessian_matrix_det = (dip_array(hessian_matrix_det));
%     hessian_matrix_det_normal = (hessian_matrix_det .*(sigma^4)).^2;
    dxx_l_src = dxx(l_src);
    dxx_l_src = dip_array(dxx_l_src);
    dyy_l_src = dyy(l_src);
    dyy_l_src = dip_array(dyy_l_src);
    hessian_matrix_trace = dxx_l_src + dyy_l_src;
    r = 10;
    edge_responce_constant = (r+1) ^2 /r;
    
%     -------------------------------
    for i = 10 : img_size(1) - 10
        for j = 10: img_size(2) -10
            if src_LoG(i,j)> src_LoG(i-1,j-1) &&...
                src_LoG(i,j)> src_LoG(i-1,j) &&...
                src_LoG(i,j)> src_LoG(i-1,j+1) &&...
                src_LoG(i,j)> src_LoG(i,j-1) &&...
                src_LoG(i,j)> src_LoG(i,j+1) &&...
                src_LoG(i,j)> src_LoG(i+1,j-1) &&...
                src_LoG(i,j)> src_LoG(i+1,j) &&...
                src_LoG(i,j)> src_LoG(i+1,j+1) &&...
                (hessian_matrix_trace(i,j)^2 / hessian_matrix_det(i,j)) < edge_responce_constant 
                count = count + 1;
                candidate_matrix(count) = 1;
                candidate_vector(count,:) = [i,j,radius,src_LoG(i,j)];
            end
        end
    end
end
%remove overlapped circles
for i = 1 : count - 1
    for j = i + 1 : count
%         if candidate_matrix(i,1) ~= -1 && candidate_matrix(j,1)~= -1
            if sum((candidate_vector(i,1:2) - candidate_vector(j,1:2)).^2)...
                < max(candidate_vector(i,3),...
                   candidate_vector(i,3))^2
                if candidate_vector(i,4) <= candidate_vector(j,4)
                    candidate_matrix(i)= -1;
                else
                    candidate_matrix(j)= -1;
                end
            end
                
%         end
    end
end
% responce = 0.0;
index = 1;
for i = 1:count
    if candidate_matrix(i) ~= -1
        index = index + 1;
        candidate_final(index,:) = candidate_vector(i,:);
%         responce = responce + candidate_vector(i,4);
    end
end


%remove low contrast point
% for i = 1 : amount
%     if candidate_final(i,4) < (responce/amount)
%         candidate_final(i,1) = -1;
%     end
% end
% index = 0;
% for i = 1 : amount
%     if candidate_final(i,1) ~= -1
%         candidate_final2(index,:) = candidate_final(i,:);
%         index = index + 1;
%     end
% end
index
candidate_final = sortrows(candidate_final,-4);
candidate_final = candidate_final(1:round(index*0.2),:,:,:);
H = candidate_final;
% H = SiftKeypointOrientationV2(file_path,candidate_final);
figure
imshow(src_ori);
candidate_position =[candidate_final(:,2),candidate_final(:,1)];
viscircles(candidate_position(:,:),candidate_final(:,3),'EdgeColor','r','LineWidth',1);
hold on 
% candidate_final;
% H = SiftKeypointOrientationV2(file_path,candidate_final);
% H = SurfKeypointOrientation(file_path,candidate_final);

