function H = SiftKeypointOrientationV2(filepath,data_vector)
%evaluate the key point orientation kusing the method mentiond in SIFT paper
%Li Yicheng LIACS
%l.y.c.liyicheng@gmail.com
%2016/04/24

%lod the image matrix,get some basic data
    src = double(rgb2gray(imread(filepath)));
    dataSize = size(data_vector);
    count = dataSize(1);
    orientationResult = zeros (count, 4);
    imgSize = size(src);
%     magnitude = zeros(7,7);
%     theta = zeros(7,7);
    oriHistogram = zeros(1,36);
        for j = 1 : count 
            sigma = data_vector(j,3);
            H = fspecial ( 'gaussian', ceil(6*sigma) , sigma );
            l_src = imfilter ( src, H , 'conv');
            x = data_vector(j,1);
            y = data_vector(j,2);
            radius = floor ( 6 * sigma);
            magnitude = zeros(2*radius +1);
            theta = zeros(2*radius + 1);
            for k = - radius : radius
                for l = -radius : radius
                    if (x+k-1) >0 && (y+l-1) > 0 ...
                        && (x + k + 1) < imgSize(1) && (y + l + 1) < imgSize(2)
                        magnitude(k+radius + 1,l+radius + 1) = sqrt((l_src((x+k)+1,(y+l)) - l_src((x+k)-1,(y+l)))^2 + ...
                            (l_src((x+k),(y+l)+1) - l_src((x+k),(y+l)-1))^2);
                        deltaY = (l_src((x+k),(y+l)+1) - l_src((x+k),(y+l)-1)); 
                        deltaX = ( l_src((x+k)+1,(y+l)) - l_src((x+k)-1,(y+l)));
                        if deltaY >= 0 && deltaX >= 0
                            if deltaY == 0 && deltaX == 0
                                theta(k+radius+1,l+radius+1) = 0; %avoid NaN
                            else
                                theta(k+radius+1,l+radius+1) = atan ( deltaY / deltaX );
                            end
                        else if deltaY >= 0 && deltaX < 0
                                theta(k+radius+1,l+radius+1) = pi + atan ( deltaY / deltaX );
                            else if deltaY < 0 && deltaX < 0
                                    theta(k+radius+1,l+radius+1) = pi + atan ( deltaY / deltaX );
                                else if deltaY < 0 && deltaX >= 0
                                        theta(k+radius+1,l+radius+1) = 2*pi + atan(deltaY / deltaX);
                                    end
                                end
                            end
                        end
                    else
                        magnitude(k+radius+1,l+radius+1) = 0;
                        theta(k+radius+1,l+radius+1) = 0;
                    end                       
%                         gaussianWeight = fspecial('gaussian',2*radius+1,1.5*sigma);
%                         vectorMatrix = gaussianWeight .* magnitude;
                end
            end
            gaussianWeight = fspecial('gaussian',2*radius+1,1.5*sigma);
            vectorMatrix = gaussianWeight .* magnitude;

            for i = 1 : 2*radius+1
                for p = 1 : 2*radius+1
                    oriHistogram( floor(theta(i,p)/(pi/18) ) + 1 ) = ...
                        oriHistogram( floor(theta(i,p)/(pi/18) ) + 1 ) + vectorMatrix(i,p);
                end
            end
            [anything, index] = ismember(max(oriHistogram),oriHistogram);
            orientationResult(j,:) = [x,y,index-1,exp(data_vector(j,3))*1.5];       
        end
H = orientationResult;
for i = 1 : count
    r_length = orientationResult(i,4);
    x1 = orientationResult(i,1);
    y1 = orientationResult(i,2);
    angle = orientationResult(i,3);
    x2 = x1 + r_length * cos (pi * angle / 18);
    y2 = y1 + r_length * sin (pi * angle / 18);
    plot([y1,y2],[x1,x2],'Color','r','LineWidth',2);
    hold on
end


            
            
            
                        
            