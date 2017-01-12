function junction_test_v2(file_name,t_step,t_max)
%usage : junction_test(file_name,t_step,t_max)
% input: file_name  the file_path to locate the image
%        t_step   the step between two selected gaussian sigma, the step would be (exp(t_step))
%        t_max    the maximum t for scale_selection
%l.y.c.liyicheng@gmail.com

src = imread(file_name);
src_ori = src;
src = double(src);
img_size = size(src);
count = 0;
for t = 0.5 : t_step : t_max
    %construct the junction response from the image
    sigma = exp(t);
    H = fspecial ( 'gaussian', ceil(6*sigma) , sigma );
    l_src = imfilter ( src, H , 'conv');
%     l_src = imfilter ( src, H , 'conv');
    l_src_dx = dx (l_src);
    l_src_dx = dip_array(l_src_dx);
    l_src_dy = dy (l_src);
    l_src_dy = dip_array(l_src_dy);
    l_src_dxx = dxx (l_src);
    l_src_dxx = dip_array(l_src_dxx);
    l_src_dyy = dyy (l_src); 
    l_src_dyy = dip_array(l_src_dyy);
    l_src_dxy = dxy (l_src);
    l_src_dxy = dip_array(l_src_dxy);
    l_junc_resp = (l_src_dyy ) .* (l_src_dx).^2 + ...
                (l_src_dxx ) .* (l_src_dy).^2 - ...
                2  * (l_src_dx) .* (l_src_dy) .* (l_src_dxy);
    l_junc_resp = (l_junc_resp.*sigma^4).^2;
%     imshow(uint8(l_junc_resp))
%     pause(0.5)
    %start to select the candidate
    for i = 15 : img_size(1) - 15
        for j = 15 : img_size(2) -15
            if l_junc_resp(i,j)> l_junc_resp(i-1,j-1) &&...
                l_junc_resp(i,j)> l_junc_resp(i-1,j) &&...
                l_junc_resp(i,j)> l_junc_resp(i-1,j+1) &&...
                l_junc_resp(i,j)> l_junc_resp(i,j-1) &&...
                l_junc_resp(i,j)> l_junc_resp(i,j+1) &&...
                l_junc_resp(i,j)> l_junc_resp(i+1,j-1) &&...
                l_junc_resp(i,j)> l_junc_resp(i+1,j) &&...
                l_junc_resp(i,j)> l_junc_resp(i+1,j+1)
                count = count + 1;
                candidate_matrix(count) = 1;
                candidate_vector(count, :) = [i,j,sigma,l_junc_resp(i,j)];
            end
        end
    end
end

count
% for i = 1 : count
%     if candidate_vector(i,1) < 20 || candidate_vector(i,1)> img_size(1)-20 ...
%             || candidate_vector(i,2) < 20 || candidate_vector(i,2) > img_size(2) - 20
%        candidate_matrix(i) = -1;
%     end
% end
% % candidate_vector_temp = candidate_vector;
% index = 0;
% for i = 1 : count
%     if candidate_matrix(i) ~= -1
%         index = index + 1;
%         candidate_vector_2(index,:) = candidate_vector(i,:);
%         candidate_matrix_2(index) = 1;
%     end
% end
% H = candidate_vector_2;


% count = index

candidate_vector = sortrows(candidate_vector,-4);
candidate_vector = candidate_vector(1:1000,:);
count = 1000
%scale selection
for i = 1 : count - 1
    for j = i + 1 : count
%         if candidate_matrix(i,1) ~= -1 && candidate_matrix(j,1)~= -1
            if sum((candidate_vector(i,1:2) - candidate_vector(j,1:2)).^2)...
                < max(0.8*candidate_vector(i,3),...
                   0.8*candidate_vector(j,3))^2
                if candidate_vector(i,4) <= candidate_vector(j,4)
                    candidate_matrix(i)= -1;
                else
                    candidate_matrix(j)= -1;
                end
            end
                
%         end
    end
end
index = 0;
for i = 1:count
    if candidate_matrix(i) ~= -1
        index = index + 1;
        candidate_final(index,:) = candidate_vector(i,:);
%         responce = responce + candidate_vector_2(i,4);
%         index = index + 1;
    end
end
%--------------------------------------------------------------

% candidate_final = candidate_vector;
% count = index

candidate_final = sortrows(candidate_final,-4);
if count < 100
candidate_final = candidate_final(1:round(count),:,:,:);
else 
candidate_final = candidate_final(1:100,:,:,:);
end

imshow(src_ori);
candidate_position =[candidate_final(:,2),candidate_final(:,1)];
viscircles(candidate_position(:,:),0.8*candidate_final(:,3),'EdgeColor','r');