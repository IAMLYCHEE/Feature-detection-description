function performance_test_v3(file_path1,file_path2,t_step,t_end)
%function performance_test(file_path1,file_path2,t_step,t_end)

keypoints1 = blob_detection_deter_v2(file_path1,t_step,t_end);
descriptors1 = fftdescriptor(file_path1,keypoints1);
size_keypoints1 = size(keypoints1);
amount1 = size_keypoints1(1);

keypoints2 = blob_detection_deter_v2(file_path2,t_step,t_end);
descriptors2 = fftdescriptor(file_path2,keypoints2);
size_keypoints2 = size(keypoints2);
amount2 = size_keypoints2(1);

img1 = rgb2gray(imread(file_path1));
img2 = rgb2gray(imread(file_path2));
size_img = size(img1);
img_cont = [img1,img2];

figure
imshow(img_cont);

amount_set1 = 1;
for i = 1: amount1
    flag = 0;
    SE_min = 1000;
    keypoint1 = keypoints1(i,:);
    responce1 = keypoint1(4);
    for j = 1 : amount2
        keypoint2 = keypoints2(j,:);
        responce2 = keypoint2(4);
        SE = sum((descriptors1(i,:) - descriptors2(j,:)).^2)*abs(responce1 - responce2);
        if SE < SE_min
            index = j;
            SE_min = SE;
            flag = 1;
        end
     end
     if flag == 1       
        x1 = keypoint1(1);
        y1 = keypoint1(2);
        keypoint_match = keypoints2(index,:);
        x2 = keypoint_match(1);
        y2 = keypoint_match(2) + size_img(2);
        match_set1(amount_set1,:) = [x1,y1,x2,y2];
        amount_set1 = amount_set1 + 1; 
     end
end
amount_set1 = amount_set1 -1;
amount_set2 = 1;
for i = 1 : amount2
        flag = 0;
        SE_min = 1000;
        keypoint2 = keypoints2(i,:);
        responce2 = keypoint2(4);
        for j = 1 : amount1
            keypoint1 = keypoints1(j,:);
            responce1 = keypoint1(4);
            SE = sum((descriptors2(i,:) - descriptors1(j,:)).^2)*abs(responce1-responce2);
            if SE < SE_min
                index = j;
                SE_min = SE;
                flag = 1;
            end
        end
        if flag == 1
            keypoint_match = keypoints1(index,:);
            x1 = keypoint_match(1);
            y1 = keypoint_match(2);
            x2 = keypoint2(1);
            y2 = keypoint2(2)+size_img(2);
            match_set2(amount_set2,:) = [x1,y1,x2,y2];
            amount_set2 = amount_set2 + 1;
        end
end
amount_set2 =amount_set2 -1;

% amount_set1
% amount_set2
for group_index = 1 : 10
figure
imshow(img_cont);
title(num2str(group_index))

hold on
for i = floor((group_index-1)*amount_set1/10 +1) : floor(group_index*amount_set1/10)
%     i
    for j = 1 : amount_set2 
        if match_set1(i,:) == match_set2(j,:)
            %         plot part
        color = ceil(rand(1)*7);
        switch color
            case 1
                Color = 'r';
            case 2
                Color = 'g';
            case 3
                Color = 'b';
            case 4
                Color = 'c';
            case 5
                Color = 'm';
            case 6
                Color = 'y';
            case 7
                Color = 'k';
            otherwise
                Color = 'r';
        end
        data = match_set1(i,:);
        x1 = data(1);
        y1 = data(2);
        x2 = data(3);
        y2 = data(4);
        viscircles([y1,x1;y2,x2],[3,3],'EdgeColor',Color,'Linewidth',1);
        hold on 
        plot([y1,y2],[x1,x2],'Color',Color);
        end
    end    
end
hold off
end



     
     