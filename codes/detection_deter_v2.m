function candidate_final = blob_detection_deter_v2(file_path,t_step,t_max)
%usage: blob_detection_deter(file_path,t_step,t_max)
%blob detection with automatic scale selection by trace
%LIACS
%l.y.c.liyicheng@gmail.com

src = rgb2gray(imread(file_path));
src_ori = src;
src = double(src);
img_size = size(src);
hessian_matrix_det = zeros (img_size(1),img_size(2));
% hessian_matrix_trace = zeros (img_size(1),img_size(2));
count = 0; %counter for count the amount of the salient point
for t = 1: t_step : t_max
    
    %start to compute the hessian matrix
    sigma = exp(t);
    radius = 1.5*sigma;
    H = fspecial ( 'gaussian', ceil(6*sigma) , sigma );
    l_src = imfilter ( src, H, 'conv');
%     for i =2 : img_size(1) - 1
%         for j = 2 : img_size(2) - 1
%             Lxx = l_src(i+1,j) + l_src(i-1,j) - 2 * l_src(i,j);
%             Lyy = l_src(i,j+1) + l_src(i,j-1) - 2 * l_src(i,j);
%             Lxy = 1/4 * (l_src(i+1,j+1) + l_src(i-1,j-1) ...
%                           - l_src(i-1,j+1) - l_src(i+1,j-1) );
%             hessian_matrix_det(i,j) = t^2 * (Lxx * Lyy - (Lxy ^ 2));
%             hessian_matrix_trace(i,j) = t * (Lxx + Lyy);
%         end
%     end
    %use dipimage tool box
%     method 1
    hessian_matrix_det = dethessian(l_src);
    hessian_matrix_det = (dip_array(hessian_matrix_det));
    hessian_matrix_det_normal = (hessian_matrix_det .*(sigma^4)).^2;
%     method 2
      dxx_l_src = dxx(l_src);
      dxx_l_src = dip_array(dxx_l_src);
      dyy_l_src = dyy(l_src);
      dyy_l_src = dip_array(dyy_l_src);
      
    hessian_matrix_trace = dxx_l_src + dyy_l_src;
    r = 10;
    edge_responce_constant = (r+1) ^2 /r;
%       dxy_l_src = dxy(l_src);
%       dxy_l_src = dip_array(dxy_l_src);
      
    %finish the computing of the hessian matrix
    
    %start to select the candidate
    for i = 10 : img_size(1) - 10
        for j = 10 : img_size(2) -10
            if hessian_matrix_det(i,j)> hessian_matrix_det(i-1,j-1) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i-1,j) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i-1,j+1) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i,j-1) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i,j+1) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i+1,j-1) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i+1,j) &&...
                hessian_matrix_det(i,j)> hessian_matrix_det(i+1,j+1) &&...
                (hessian_matrix_trace(i,j)^2 / hessian_matrix_det(i,j)) < edge_responce_constant 
                count = count + 1;
                candidate_matrix(count) = 1;
                candidate_vector(count, :) = [i,j,radius,hessian_matrix_det_normal(i,j)];
            end
        end
    end
    %finish to select the candidate
    
    %finish selecting the candidate of all scales
end
% H = candidate_vector;
% scale selection
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
% candidate_vector
index = 0;
for i = 1:count
    if candidate_matrix(i) ~= -1
        index = index + 1;
        candidate_final(index,:) = candidate_vector(i,:);
%         responce = responce + candidate_vector(i,4);
%         index = index + 1;
    end
end
% remove candidate with low contrast
%calculate the average responce
% responce = 0.0;
% index = 1;
% for i = 1:count
%     if candidate_matrix(i,1) ~= -1
%         candidate_final(index,:) = candidate_vector(i,:);
% %         responce = responce + candidate_vector(i,4);
%         index = index + 1;
%     end
% end
% %remove salient point less than the average contrast
% amount = index -1;
% for i = 1 : amount
%     if candidate_final(i,4) < (responce/amount)
%         candidate_final(i,1) = -1;
%     end
% end
% index = 1;
% for i = 1 : amount
%     if candidate_final(i,1) ~= -1
%         candidate_final2(index,:) = candidate_final(i,:);
%         index = index + 1;
%     end
% end
index
candidate_final = sortrows(candidate_final,-4);
candidate_final = candidate_final(1:round(index*0.2),:,:,:);
imshow(src_ori);
candidate_position =[candidate_final(:,2),candidate_final(:,1)];
viscircles(candidate_position(:,:),candidate_final(:,3),'EdgeColor','r','LineWidth',1);
hold on 
% H = SiftKeypointOrientationV2(file_path,candidate_final);
% H = SurfKeypointOrientation(file_path,candidate_final);



                
                
    




            
            
