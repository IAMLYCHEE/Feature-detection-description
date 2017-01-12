function H = SurfKeypointOrientation(filepath, data_vector)
%evaluate the key point orientation using the method mentioned in SURF paper
%Li Yicheng LIACS
% l.y.c.liyicheng@gmail.com
%2016/05/02

%load the image matrix, get some basic data
src = double(rgb2gray(imread(filepath)));
img_size = size(src);
datasize = size(data_vector);
count = datasize(1);
orientationResult = zeros ( count , 4 );

%generate the orientation for each keypoint
for j = 1 : count
    sigma = data_vector(j,3);
    H = fspecial ( 'gaussian',ceil(6*sigma) , sigma);
    l_src = imfilter(src, H , 'conv');
    x = data_vector(j,1); %abscissa for the keypoint
    y = data_vector(j,2); %ordinate for the keypoint
    radius = floor( 6* sigma);
    
    %extract the pixels around the keypoint
    aroundKeypoint = zeros (2*radius+1);
    for k = - radius : radius
        for l = -radius : radius 
            if (x + k ) >0 && (y + l)>0 ...
                && (x + k) < img_size(1) && (y + l) < img_size(2)...  %make sure in the range of the source_image
                && (k^2 + l^2 <= radius^2) %make sure in the circle
                aroundKeypoint(k + radius + 1, l + radius + 1) = l_src(x+k,y+l);
            else
                aroundKeypoint(k + radius + 1, l + radius + 1) = 0;
            end
        end
    end
    %gaussian weight
    H = fspecial ( 'gaussian', 2*radius + 1 , 1.5*sigma);
    aroundKeypoint = aroundKeypoint .* H;
    %wavelet haar transformation
    [c,l] = wavedec2( aroundKeypoint, 1 , 'haar');
    n = length(c);
    Vh = c(n/4 + 1 : n/2);
    Vv = c(n/2 + 1 : n/4 * 3);
    data = zeros(n/4,3);
    %generate the angle for each responce
    for i = 1 : n/4
        data(i,1) = Vh(i);
        data(i,2) = Vv(i);
        temp_angle = atan(Vv(i) / Vh(i));
        if Vh(i) >= 0 && Vv(i) >= 0
            data(i,3) = temp_angle;
        else if Vv(i) < 0 && Vh(i) >=0
                data(i,3) = 2 * pi + temp_angle;
            else
                data(i,3) = pi + temp_angle;
            end
        end
    end
    
    %generate a sliding window
    index = 0;
    horizon_responce  = zeros(62,1);
    vertical_responce = zeros(62,1);
    for angle = 0 : 0.1 : 2*pi - 0.1
        index = index + 1;
        for i = 1 : n/4
            if data(i,3) > angle - pi/12 && data(i,3) < angle + pi/12
                horizon_responce(index) = data(i,1) + horizon_responce(index);
                vertical_responce(index) = data(i,2) + vertical_responce(index);
            end
        end
    end
    
    %get the longest vector
    vector_length = horizon_responce(:).^2 + vertical_responce(:).^2 ;
    [anything ,index] = ismember ( max (vector_length),vector_length);
    orientationResult(j,:) = [x,y,(index-1) * 0.1,exp(sigma)*1.5];
end
H = orientationResult;
for i = 1 : count 
    r_length = orientationResult(i,4);
    x1 = orientationResult(i,1);
    y1 = orientationResult(i,2);
    angle = orientationResult(i,3);
    x2 = x1 + r_length * cos (angle);
    y2 = y1 + r_length * sin (angle);
    plot([y1,y2],[x1,x2],'Color','r','LineWidth',2);
    hold on
end
        
    
    
    