%keypoint orientation
img_mat = imread('blob.jpeg');
img_mat = double(rgb2gray(img_mat));
size = size(img_mat);
magnitude = zeros(7,7);
theta = zeros(7,7);
x = 0;
y = 0;
for i = 5 : size(1) - 5
    for j = 5 : size(2) - 5
        for k = i - 3 : i + 3
            y = y + 1;
            for l = j - 3 : j + 3
                x = x + 1;
                magnitude(x,y) = sqrt ( (img_mat(k+1,l) - img_mat(k-1,l))^2 ...
                                    +(img_mat(k,l+1) - img_mat(k,l-1))^2 );
                theta(x,y) = atan ( (img_mat(k,l + 1) - img_mat(k,l - 1)) / ...
                                    (img_mat(k+1,l) - img_mat(k-1,l)));
            end
        end
    end
end

        
        



