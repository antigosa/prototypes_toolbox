function similarity=img_similarity(img1, img2, sim_type)
% function similarity=img_similarity(img1, img2, sim_type)

if nargin<3
    sim_type='corr'; % means use 'corr' function
end

n_subjects = size(img1, 3);
similarity = zeros(1, n_subjects);

for s = 1:n_subjects
    
    subj_img1 = img1(:,:,s);
    subj_img2 = img2(:,:,s);
    
    %     switch sim_type
    %         case 'euclidean'
    %             subj_img1 = imresize(subj_img1, 1);
    %             subj_img2 = imresize(subj_img2, 1);
    
    if strcmp(sim_type, 'corr')~=1
        subj_img1 = imresize(subj_img1, 1);
        subj_img2 = imresize(subj_img2, 1);
    end
    
    
    
    subj_img1 = reshape(subj_img1, [], 1);
    subj_img2 = reshape(subj_img2, [], 1);
    
    subj_img1(isnan(subj_img1))=0;
    subj_img2(isnan(subj_img2))=0;
    
    
    switch sim_type
        case 'corr'
            similarity(s) = corr(subj_img1, subj_img2);
            
            %         case 'euclidean'
        otherwise
            X =[subj_img1, subj_img2];
            similarity(s) = pdist(X', sim_type); %'euclidean'
    end
end